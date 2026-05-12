import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userEmoji;

  const ChatScreen({
    required this.userName,
    required this.userEmoji,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  // Google Generative Language API anahtarı
  static const String _apiKey = String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');

  String get _systemPrompt =>
      'Sen MindCare uygulamasının yapay zeka asistanısın. '
      'Adın "MindCare Asistan". '
      'Kullanıcının adı "${widget.userName}" ve bugünkü ruh hali "${widget.userEmoji}". '
      'Türkçe konuş. Empatik, sıcak ve destekleyici ol. '
      'Ruh sağlığı, stres yönetimi, motivasyon ve kişisel gelişim konularında yardımcı ol. '
      'Kısa ve anlaşılır cevaplar ver. Emoji kullan ama abartma. '
      'Tıbbi tavsiye verme, gerektiğinde profesyonel destek almayı öner.';

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Merhaba ${widget.userName}! 🌿 Ben MindCare Asistanı. '
          'Bugün sana nasıl yardımcı olabilirim?',
      isUser: false,
    ));
  }

  Future<String> _generateReply(String userText) async {
    final promptText = '$_systemPrompt\n\nKullanıcı: $userText\nAsistan:';

    if (_apiKey.isEmpty) {
      throw 'Lütfen GOOGLE_API_KEY ile geçerli bir API anahtarı sağlayın.';
    }

    final url = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta1/models/text-bison-001:generateText',
      {'key': _apiKey},
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': {'text': promptText},
        'temperature': 0.7,
        'maxOutputTokens': 256,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      final output = candidates?.isNotEmpty == true
          ? (candidates!.first as Map<String, dynamic>)['output'] as String?
          : null;

      if (output != null && output.isNotEmpty) {
        return output.trim();
      }
    }

    throw 'Yanıt alınamadı. Lütfen tekrar deneyin.';
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Save chat interaction to Firebase to count as activity
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final dateKey = DateFormat('yyyy-MM-dd').format(now);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chats')
            .add({
          'dateKey': dateKey,
          'timestamp': FieldValue.serverTimestamp(),
          'message': text,
        });
      }

      final reply = await _generateReply(text);

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: reply, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: 'Bir hata oluştu: $e\n\nLütfen tekrar deneyin. 😔',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Text('🤖', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MindCare Asistan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Yapay Zeka Destekli',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mesaj listesi
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Mesaj yazma alanı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: const Color(0xFFF0FDF4),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isLoading ? null : _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xFF10B981),
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF10B981) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF064E3B),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF064E3B),
              child: Text(
                widget.userEmoji,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFF10B981),
            child: Text('🤖', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                SizedBox(width: 4),
                _TypingDot(delay: 200),
                SizedBox(width: 4),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.4 + _animation.value * 0.6),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
