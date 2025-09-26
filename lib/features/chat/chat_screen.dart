import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:care_shield/core/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool fromUser;
  final DateTime timestamp;
  final MessageType type;

  Message(this.text, this.fromUser, {this.type = MessageType.text})
    : timestamp = DateTime.now();
}

enum MessageType { text, typing, system }

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Message> _messages = [
    Message(
      '👋 Hello! I\'m your CareShield health assistant. How can I help you today?',
      false,
    ),
  ];
  final _ctrl = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;
  bool _isTyping = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _slideController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _send() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty || _sending) return;

    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(Message(txt, true));
      _sending = true;
      _isTyping = true;
      _ctrl.clear();
    });

    _scrollToBottom();

    // Show typing indicator
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate realistic response time
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isTyping = false;
      _messages.add(Message(_generateResponse(txt), false));
      _sending = false;
    });

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

  String _generateResponse(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('pain') ||
        lower.contains('hurt') ||
        lower.contains('fever') ||
        lower.contains('sick')) {
      return '🏥 I\'m sorry to hear you\'re not feeling well. Can you describe your symptoms and how long you\'ve been experiencing them? This will help me provide better guidance.';
    }

    if (lower.contains('med') ||
        lower.contains('medicine') ||
        lower.contains('refill') ||
        lower.contains('prescription')) {
      return '💊 For product orders, please visit the Products tab to browse our catalog and place an order. If this is urgent, you can contact your health center directly or book an emergency consultation.';
    }

    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('hey')) {
      return '😊 Hello! I\'m here to support you with any health-related questions or concerns. What would you like to discuss today?';
    }

    if (lower.contains('appointment') ||
        lower.contains('book') ||
        lower.contains('schedule')) {
      return '📅 You can book appointments through the Care tab. Would you like me to guide you through the booking process?';
    }

    if (lower.contains('emergency') ||
        lower.contains('urgent') ||
        lower.contains('help')) {
      return '🚨 If this is a medical emergency, please call 911 immediately. For urgent but non-emergency health concerns, I can help connect you with a healthcare provider right away.';
    }

    if (lower.contains('test') ||
        lower.contains('result') ||
        lower.contains('lab')) {
      return '🔬 Test results are typically available in the Health tab. If you have concerns about recent results, I can help you understand what to do next.';
    }

    if (lower.contains('thank') || lower.contains('thanks')) {
      return '💙 You\'re very welcome! Remember, I\'m here 24/7 to support your health journey. Is there anything else I can help you with?';
    }

    return '💭 Thank you for sharing that with me. A healthcare professional will review your message and respond within 24 hours. In the meantime, is there anything else I can help you with?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildMessagesList(),
                ),
              ),
              _buildMessageInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.support_agent_outlined,
              color: AppColors.secondaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Health Assistant',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.background, AppColors.background.withOpacity(0.5)],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        itemCount: _messages.length + (_isTyping ? 1 : 0),
        itemBuilder: (context, index) {
          if (_isTyping && index == _messages.length) {
            return _buildTypingIndicator();
          }

          final message = _messages[index];
          return _buildMessageBubble(message, index);
        },
      ),
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final isUser = message.fromUser;
    final isLast = index == _messages.length - 1;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 8 : 16,
        left: isUser ? 60 : 0,
        right: isUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryBlue : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser
                    ? const Radius.circular(20)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? AppColors.primaryBlue.withOpacity(0.3)
                      : AppColors.text.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: AppColors.text.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 60, bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.text.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.text.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.text.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.text.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _ctrl,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.text,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: AppColors.text.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.text.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: _ctrl.text.trim().isEmpty || _sending
                    ? AppColors.text.withOpacity(0.1)
                    : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: _ctrl.text.trim().isEmpty || _sending
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _sending ? null : _send,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    child: _sending
                        ? Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.text.withOpacity(0.5),
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: _ctrl.text.trim().isEmpty
                                ? AppColors.text.withOpacity(0.5)
                                : Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
