import 'package:flutter/material.dart';
import 'package:factify/models/chat_message.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isTyping) {
      return _buildTypingIndicator();
    }

    return Padding(
      padding: EdgeInsets.only(
        left: message.isUser ? 50 : 16,
        right: message.isUser ? 16 : 50,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                _buildAvatar(),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                          )
                        : LinearGradient(
                            colors: [
                              const Color(0xFF2D2D44).withOpacity(0.8),
                              const Color(0xFF2D2D44).withOpacity(0.6),
                            ],
                          ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 16),
                    ),
                    border: Border.all(
                      color: message.isUser
                          ? Colors.transparent
                          : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: message.isUser
                            ? const Color(0xFF4ECDC4).withOpacity(0.3)
                            : Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: MarkdownBody(
                    data: message.text,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      strong: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                      listBullet: const TextStyle(
                        color: Colors.white,
                      ),
                      h1: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      h2: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      h3: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      h4: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      h5: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      h6: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      tableHead: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      tableBody: const TextStyle(color: Colors.white),
                      tableBorder: TableBorder.all(color: Colors.white24, width: 1),
                      blockquote: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                      code: const TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.white12,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                _buildAvatar(),
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: message.isUser ? 0 : 48,
              right: message.isUser ? 48 : 0,
            ),
            child: Text(
              DateFormat('HH:mm').format(message.timestamp),
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: message.isUser
            ? const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
              )
            : const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (message.isUser
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFF6C5CE7))
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: message.isUser
          ? const Icon(
              Icons.person,
              color: Colors.white,
              size: 18,
            )
          : ClipOval(
              child: Transform.scale(
                scale: 1.2,
                child: Image.asset(
                  'assets/images/CHATBOT.webp', 
                  fit: BoxFit.cover,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 50, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2D2D44).withOpacity(0.8),
                  const Color(0xFF2D2D44).withOpacity(0.6),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const TypingIndicator(),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3 + (opacity * 0.7)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}