import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_template/core/cache/hive/hive_methods.dart';
import 'package:my_template/core/custom_widgets/custom_app_bar/custom_app_bar.dart';
import 'package:my_template/core/services/ai_service.dart';
import 'package:my_template/core/theme/app_colors.dart';
import 'package:my_template/core/theme/app_text_style.dart';
import 'package:my_template/core/utils/app_local_kay.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late AiService aiService;
  bool isTyping = false;

  late AnimationController _dotsController;
  late Animation<double> _dotsAnimation;

  late Box chatBox;

  @override
  void initState() {
    super.initState();
    aiService = AiService(apiKey: 'AIzaSyD0ZG-Uzr_BAOvEzv-GdYwm6FMOmmWh6e8');

    _dotsController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _dotsAnimation = Tween<double>(begin: 0, end: 3).animate(_dotsController);

    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    final empId = HiveMethods.getEmpCode();
    chatBox = await Hive.openBox('chat_messages_$empId');
    final storedMessages = chatBox.values.toList();
    setState(() {
      _messages.addAll(
        storedMessages.map((m) {
          final timeString = m['time'] as String?;
          return {
            'role': m['role'] ?? 'bot',
            'text': m['text'] ?? '',
            'time': timeString != null ? DateTime.parse(timeString) : DateTime.now(),
          };
        }).toList(),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();
    final userMessage = {'role': 'user', 'text': text, 'time': now};
    setState(() {
      _messages.add(userMessage);
      isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();
    await chatBox.add({'role': 'user', 'text': text, 'time': now.toIso8601String()});
    final replyText = await aiService.sendMessage(text);
    final botMessage = {'role': 'bot', 'text': replyText, 'time': DateTime.now()};
    setState(() {
      isTyping = false;
      _messages.add(botMessage);
    });
    await chatBox.add({'role': 'bot', 'text': replyText, 'time': DateTime.now().toIso8601String()});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Map<String, dynamic> msg) {
    final isUser = msg['role'] == 'user';
    final time = DateFormat('hh:mm a', 'en').format(msg['time']);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isUser ? AppColor.primaryColor(context) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor(context).withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              msg['text'] ?? '',
              style: TextStyle(
                color: isUser ? AppColor.whiteColor(context) : AppColor.blackColor(context),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              time,
              style: TextStyle(
                color: isUser ? AppColor.whiteColor(context) : AppColor.blackColor(context),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColor.whiteColor(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor(context).withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                double opacity = ((index + 1) - (_dotsAnimation.value % 3)).clamp(0, 1);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(opacity),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotsController.dispose();
    _scrollController.dispose();
    chatBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        context,
        leading: const BackButton(),
        title: Text(
          AppLocalKay.inquiries.tr(),
          style: AppTextStyle.text18MSecond(context, color: AppColor.blackColor(context)),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalKay.chatbot_welcome.tr(),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.text18MSecond(
                              context,
                              color: AppColor.blackColor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalKay.chatbot_hint.tr(),
                            textAlign: TextAlign.center,
                            style: AppTextStyle.text16MSecond(context, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),
                          Image.asset('assets/global_icon/ropt.jpg', height: 200, width: 200),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      itemCount: _messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (isTyping && index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        final msg = _messages[index];
                        return _buildMessage(msg);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !isTyping,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: AppLocalKay.chatbot_hint.tr(),
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: isTyping ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
