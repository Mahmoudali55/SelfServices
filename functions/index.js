const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendChatNotification = functions.firestore
    .document("chats/{messageId}")
    .onCreate(async (snapshot, context) => {
        const messageData = snapshot.data();

        const senderName = messageData.senderName || "رسالة جديدة";
        const messageText = messageData.message || "أرسل لك صورة أو ملفاً";
        const receiverId = messageData.receiverId;

        if (!receiverId) return null;

        try {
            const userDoc = await admin.firestore().collection("users").doc(receiverId.toString()).get();

            if (!userDoc.exists) {
                console.log("User not found or has no token");
                return null;
            }

            const fcmToken = userDoc.data().fcmToken;

            if (!fcmToken) {
                console.log("User has no registered fcmToken");
                return null;
            }

            const payload = {
                notification: {
                    title: senderName,
                    body: messageText,
                },
                data: {
                    senderId: messageData.senderId.toString(),
                    conversationId: messageData.conversationId || "",
                    click_action: "FLUTTER_NOTIFICATION_CLICK"
                }
            };

            const options = {
                priority: "high",
                timeToLive: 60 * 60 * 24
            };

            const response = await admin.messaging().sendToDevice(fcmToken, payload, options);
            console.log("Successfully sent message:", response);
            return response;

        } catch (error) {
            console.error("Error sending notification:", error);
            return null;
        }
    });
