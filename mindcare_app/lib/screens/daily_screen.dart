import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/encryption_service.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final _entryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  final EncryptionService _encryptionService = EncryptionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedMood = '😐';
  bool _isPrivate = false;
  bool _isFirstTime = false; // İlk kez mi giriliyor?
  bool _isPasswordScreen = true; // Şifre ekranında mı?
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _moods = ['😢', '😔', '😐', '🙂', '😊', '😁'];

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // İlk kez girilip girilmediğini kontrol et
  Future<void> _checkIfFirstTime() async {
    final savedPassword = await _encryptionService.getDiaryPassword();
    setState(() {
      _isFirstTime = savedPassword == null;
      _isPasswordScreen = true;
    });
  }

  // Şifre kaydet (ilk kez)
  Future<void> _savePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Şifreler eşleşmiyor!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _encryptionService.saveDiaryPassword(_passwordController.text);
      setState(() {
        _isPasswordScreen = false;
        _isLoading = false;
      });
      _showSnackBar('Şifre başarıyla oluşturuldu! 🔐', isError: false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Şifre kaydedilemedi: $e';
        _isLoading = false;
      });
    }
  }

  // Şifre doğrula (mevcut kullanıcı)
  Future<void> _verifyPassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final savedPassword = await _encryptionService.getDiaryPassword();
      if (savedPassword != null && _passwordController.text == savedPassword) {
        setState(() {
          _isPasswordScreen = false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Şifre hatalı!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  // Günlüğü Firebase'e kaydet
  Future<void> _saveDiary() async {
    if (_entryController.text.trim().isEmpty) {
      _showSnackBar('Lütfen bir şeyler yazın! 📝');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('Kullanıcı bulunamadı!');
        return;
      }

      // Şifreyi al
      final diaryPassword = await _encryptionService.getDiaryPassword();
      if (diaryPassword == null) {
        _showSnackBar('Şifre bulunamadı!');
        return;
      }

      // Günlük içeriğini şifrele
      final encryptedContent = _encryptionService.encryptText(
        _entryController.text.trim(),
        diaryPassword,
      );

      final now = DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(now);

      // Firebase'e kaydet
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(dateKey)
          .set({
        'content': encryptedContent,
        'mood': _selectedMood,
        'isPrivate': _isPrivate,
        'date': Timestamp.fromDate(now),
        'dateKey': dateKey,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _entryController.clear();
      _showSnackBar('Günlük kaydedildi! 📝✨', isError: false);
    } catch (e) {
      _showSnackBar('Kayıt hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Günlükleri göster (şifreli)
  void _showHistory() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final diaryPassword = await _encryptionService.getDiaryPassword();
    if (diaryPassword == null) return;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            const Text(
              'Geçmiş Günlükler',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332)),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('diaries')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Hata: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF72B01D)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book, size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Henüz günlük kaydı yok',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }

                  final diaries = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: diaries.length,
                    itemBuilder: (context, index) {
                      final diary = diaries[index];
                      final data = diary.data() as Map<String, dynamic>;
                      final date = (data['date'] as Timestamp).toDate();
                      final mood = data['mood'] ?? '😐';
                      final encryptedContent = data['content'] ?? '';

                      // Şifreli içeriği çöz
                      String decryptedContent = 'İçerik çözülemedi';
                      try {
                        decryptedContent = _encryptionService.decryptText(
                          encryptedContent,
                          diaryPassword,
                        );
                      } catch (e) {
                        decryptedContent = '🔒 Şifreli içerik';
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading:
                              Text(mood, style: const TextStyle(fontSize: 24)),
                          title: Text(
                            DateFormat('dd MMMM yyyy', 'tr').format(date),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            decryptedContent.length > 100
                                ? '${decryptedContent.substring(0, 100)}...'
                                : decryptedContent,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: data['isPrivate'] == true
                              ? const Icon(Icons.lock,
                                  color: Colors.grey, size: 16)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _showDiaryDetail(date, mood, decryptedContent,
                                data['isPrivate'] ?? false);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Günlük detayını göster
  void _showDiaryDetail(
      DateTime date, String mood, String content, bool isPrivate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(mood, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                DateFormat('dd MMMM yyyy', 'tr').format(date),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            if (isPrivate) const Icon(Icons.lock, color: Colors.grey, size: 16),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Kapat', style: TextStyle(color: Color(0xFF72B01D))),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF72B01D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Şifre ekranı
  Widget _buildPasswordScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _passwordFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFirstTime ? Icons.lock_outline : Icons.lock,
                  color: const Color(0xFF72B01D),
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _isFirstTime ? 'Günlük Şifresi Oluştur' : 'Günlük Şifresi',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isFirstTime
                    ? 'Günlüklerinizi korumak için bir şifre belirleyin'
                    : 'Günlüklerinizi görüntülemek için şifrenizi girin',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre gerekli';
                  if (_isFirstTime && v.length < 4) {
                    return 'Şifre en az 4 karakter olmalı';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon:
                      Icon(Icons.lock_outline, color: Color(0xFF72B01D)),
                ),
              ),
              if (_isFirstTime) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Şifre tekrarı gerekli';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon:
                        Icon(Icons.lock_outline, color: Color(0xFF72B01D)),
                  ),
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ],
              const SizedBox(height: 30),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFF72B01D))
              else
                ElevatedButton(
                  onPressed: _isFirstTime ? _savePassword : _verifyPassword,
                  child: Text(_isFirstTime ? 'Şifre Oluştur' : 'Giriş Yap'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Günlük yazma ekranı
  Widget _buildDiaryScreen() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy, EEEE', 'tr');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(dateFormat, now),
          const SizedBox(height: 24),
          const Text(
            'Ruh Halin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 12),
          _buildMoodSelector(),
          const SizedBox(height: 20),
          _buildEntryField(),
          const SizedBox(height: 16),
          _buildPrivacySwitch(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateFormat format, DateTime now) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF72B01D), Color(0xFF8BC34A)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            format.format(now),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Bugün nasıl hissediyorsun?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _moods.map((mood) {
          final isSelected = _selectedMood == mood;
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = mood),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF72B01D).withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFF72B01D) : Colors.transparent,
                ),
              ),
              child: Text(mood, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEntryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Günlük Girişin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _entryController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText:
                  'Bugün neler yaşadın? Duygularını, düşüncelerini paylaş...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(_isPrivate ? Icons.lock : Icons.lock_open,
              color: const Color(0xFF72B01D)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bu girişi özel yap (sadece ben görebilirim)',
              style: TextStyle(color: Color(0xFF1B4332)),
            ),
          ),
          Switch(
            value: _isPrivate,
            onChanged: (value) => setState(() => _isPrivate = value),
            activeThumbColor: const Color(0xFF72B01D),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveDiary,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Günlüğü Kaydet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        title: const Text(
          'Günlük',
          style: TextStyle(color: Color(0xFF1B4332)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF72B01D)),
        actions: [
          if (!_isPasswordScreen)
            IconButton(
              icon: const Icon(Icons.history, color: Color(0xFF72B01D)),
              onPressed: _showHistory,
            ),
        ],
      ),
      body: _isPasswordScreen ? _buildPasswordScreen() : _buildDiaryScreen(),
    );
  }
}
