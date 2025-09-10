import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';
import 'package:intl/intl.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> with TickerProviderStateMixin {
  final ChatbotService _chatbot = ChatbotService();
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chatbot.init().then((_) {
      setState(() => _loading = false);
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final now = DateTime.now();
    setState(() {
      _messages.add(
        _ChatMessage(
          text: text.trim(),
          sender: Sender.user,
          timestamp: now,
          animationController: AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 300),
          )..forward(),
        ),
      );
    });
    _controller.clear();
    _scrollToBottom();

    // Simulate bot typing delay
    Future.delayed(const Duration(milliseconds: 600), () {
      final response = _chatbot.getResponse(text);
      final botMsg = _ChatMessage(
        text: response,
        sender: Sender.bot,
        timestamp: DateTime.now(),
        animationController: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        ),
      );
      setState(() {
        _messages.add(botMsg);
      });
      botMsg.animationController.forward();
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    for (var msg in _messages) {
      msg.animationController.dispose();
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return SizeTransition(
                  sizeFactor: CurvedAnimation(
                    parent: msg.animationController,
                    curve: Curves.easeOut,
                  ),
                  axisAlignment: 0.0,
                  child: _ChatBubble(message: msg),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.blueAccent,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(_controller.text),
                    tooltip: 'Send',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum Sender { user, bot }

class _ChatMessage {
  final String text;
  final Sender sender;
  final DateTime timestamp;
  final AnimationController animationController;

  _ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.animationController,
  });
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == Sender.user;
    final bgColor = isUser ? Colors.blueAccent : Colors.grey.shade300;
    final textColor = isUser ? Colors.white : Colors.black87;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          );

    final timeString = DateFormat.jm().format(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: isUser
                ? const EdgeInsets.only(right: 12)
                : const EdgeInsets.only(left: 12),
            child: Text(
              timeString,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
