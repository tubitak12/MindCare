import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/encryption_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final EncryptionService _encryptionService = EncryptionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime selectedDate = DateTime.now();
  String? _diaryPassword;
  bool _isAuthenticated = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPassword();
  }

  Future<void> _checkPassword() async {
    String? savedPassword = await _encryptionService.getDiaryPassword();
    if (savedPassword == null) {
      _showPasswordDialog(isFirstTime: true);
    } else {
      _showPasswordDialog(isFirstTime: false);
    }
  }

  void _showPasswordDialog({required bool isFirstTime}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isFirstTime ? 'Günlük Şifresi Belirleyin' : 'Günlük Şifresi'),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Şifrenizi girin',
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (isFirstTime) {
                  // İlk kez şifre belirleme
                  if (_passwordController.text.isNotEmpty) {
                    await _encryptionService
                        .saveDiaryPassword(_passwordController.text);
                    setState(() {
                      _diaryPassword = _passwordController.text;
                      _isAuthenticated = true;
                    });
                    Navigator.pop(context);
                  }
                } else {
                  // Şifre kontrolü
                  String? savedPassword =
                      await _encryptionService.getDiaryPassword();
                  if (_encryptionService.validatePassword(
                      _passwordController.text, savedPassword!)) {
                    setState(() {
                      _diaryPassword = _passwordController.text;
                      _isAuthenticated = true;
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Yanlış şifre!')),
                    );
                  }
                }
              },
              child: Text(isFirstTime ? 'Kaydet' : 'Giriş'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FBFF),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: Text(DateFormat('dd MMMM yyyy', 'tr').format(selectedDate)),
        backgroundColor: const Color(0xFF7B61FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDiaryEntry,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tarih seçici
            ListTile(
              leading:
                  const Icon(Icons.calendar_today, color: Color(0xFF7B61FF)),
              title: Text(
                DateFormat('dd MMMM yyyy, EEEE', 'tr').format(selectedDate),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: _selectDate,
              ),
            ),
            const Divider(),

            // Başlık
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),

            // İçerik
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Bugün neler oldu?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveDiaryEntry,
        backgroundColor: const Color(0xFF7B61FF),
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadExistingEntry();
    }
  }

  Future<void> _loadExistingEntry() async {
    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) return;

    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    var doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(dateKey)
        .get();

    if (doc.exists) {
      String encryptedTitle = doc['title'] ?? '';
      String encryptedContent = doc['content'] ?? '';

      setState(() {
        _titleController.text =
            _encryptionService.decryptText(encryptedTitle, _diaryPassword!);
        _contentController.text =
            _encryptionService.decryptText(encryptedContent, _diaryPassword!);
      });
    } else {
      setState(() {
        _titleController.clear();
        _contentController.clear();
      });
    }
  }

  Future<void> _saveDiaryEntry() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlık ve içerik girin')),
      );
      return;
    }

    String userId = _auth.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş yapmalısınız')),
      );
      return;
    }

    // Şifrele
    String encryptedTitle =
        _encryptionService.encryptText(_titleController.text, _diaryPassword!);
    String encryptedContent = _encryptionService.encryptText(
        _contentController.text, _diaryPassword!);

    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Firestore'a kaydet
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('diary')
        .doc(dateKey)
        .set({
      'title': encryptedTitle,
      'content': encryptedContent,
      'date': dateKey,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Günlük kaydedildi!')),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
