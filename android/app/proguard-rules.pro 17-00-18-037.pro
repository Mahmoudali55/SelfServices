# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase & Google Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Prevent shrinking of data models (important for JSON parsing)
-keep class com.example.my_template.**.data.model.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Google ML Kit (Face Detection)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Camera & Photos
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Video/Audio Player rules (if used)
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Common networking libraries
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
