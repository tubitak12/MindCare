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
  final _titleController = TextEditingController();
  final _entryController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();

  final EncryptionService _encryptionService = EncryptionService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tasarımda emoji yok, ancak veritabanı yapısını bozmamak için varsayılan bir değer atıyoruz
  final String _selectedMood = '😐'; 
  final bool _isPrivate = true; // Tasarımda switch yok, her şeyi private sayalım
  bool _isFirstTime = false; // İlk kez mi giriliyor?
  bool _isPasswordScreen = true; // Şifre ekranında mı?
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  @override
  void dispose() {
    _titleController.dispose();
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
      _showSnackBar('Lütfen bir içerik yazın! 📝');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        _showSnackBar('Kullanıcı bulunamadı!');
        return;
      }

      final diaryPassword = await _encryptionService.getDiaryPassword();
      if (diaryPassword == null) {
        _showSnackBar('Şifre bulunamadı!');
        return;
      }

      // İçerikleri şifrele
      final encryptedContent = _encryptionService.encryptText(
        _entryController.text.trim(),
        diaryPassword,
      );
      
      final titleText = _titleController.text.trim().isNotEmpty 
          ? _titleController.text.trim() 
          : 'İsimsiz Günlük';
          
      final encryptedTitle = _encryptionService.encryptText(
        titleText,
        diaryPassword,
      );

      final now = DateTime.now();
      // Rastgele ID oluştur (Aynı gün birden fazla günlük atılabilir diye)
      final docId = _firestore.collection('users').doc(userId).collection('diaries').doc().id;
      final dateKey = DateFormat('yyyy-MM-dd').format(now);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('diaries')
          .doc(docId)
          .set({
        'title': encryptedTitle, // Yeni eklenen başlık
        'content': encryptedContent,
        'mood': _selectedMood,
        'isPrivate': _isPrivate,
        'date': Timestamp.fromDate(now),
        'dateKey': dateKey,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _entryController.clear();
      _showSnackBar('Günlük kaydedildi! 📝✨', isError: false);
    } catch (e) {
      _showSnackBar('Kayıt hatası: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _lockDiary() {
    setState(() {
      _isPasswordScreen = true;
      _passwordController.clear();
      if (_isFirstTime) {
        _confirmPasswordController.clear();
      }
    });
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Şifre ekranı (mevcut tasarımı koruyoruz)
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
                  color: const Color(0xFF10B981),
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _isFirstTime ? 'Günlük Şifresi Oluştur' : 'Günlük Şifresi',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isFirstTime
                    ? 'Günlüklerinizi korumak için bir şifre belirleyin'
                    : 'Günlüklerinizi görüntülemek için şifrenizi girin',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
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
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
                  decoration: InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF10B981)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
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
                const CircularProgressIndicator(color: Color(0xFF10B981))
              else
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isFirstTime ? _savePassword : _verifyPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      _isFirstTime ? 'Şifre Oluştur' : 'Giriş Yap',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Yeni Tasarım: Günlük Ana Ekranı
  Widget _buildDiaryScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özel Başlık Alanı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Günlüğüm',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF064E3B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Düşüncelerinizi özgürce yazın',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _lockDiary,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_outline, color: Color(0xFF064E3B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Yeni Kayıt Kartı
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.menu_book, color: Color(0xFF10B981)),
                    SizedBox(width: 8),
                    Text(
                      'Yeni Kayıt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF064E3B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                const Text(
                  'Başlık',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Bugünün başlığı...',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'İçerik',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _entryController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Bugün neler oldu? Nasıl hissediyorsunuz?',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveDiary,
                    icon: _isLoading 
                        ? const SizedBox() 
                        : const Icon(Icons.save_outlined, color: Colors.white, size: 20),
                    label: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Kaydet',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF76D7C4), // Resimdeki buton rengine yakın bir mint/teal
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          const Text(
            'Önceki Kayıtlar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 16),

          // Önceki Kayıtlar Listesi
          _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const SizedBox();

    return FutureBuilder<String?>(
      future: _encryptionService.getDiaryPassword(),
      builder: (context, passSnapshot) {
        if (!passSnapshot.hasData) return const SizedBox();
        final diaryPassword = passSnapshot.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .doc(userId)
              .collection('diaries')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Henüz günlük kaydı bulunmuyor.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ),
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final date = (data['date'] as Timestamp).toDate();
                final encryptedContent = data['content'] ?? '';
                final encryptedTitle = data['title'] ?? '';

                String decryptedTitle = 'Başlık Çözülemedi';
                String decryptedContent = 'İçerik Çözülemedi';

                try {
                  if (encryptedTitle.isNotEmpty) {
                    decryptedTitle = _encryptionService.decryptText(encryptedTitle, diaryPassword);
                  } else {
                    decryptedTitle = 'İsimsiz Günlük';
                  }
                  decryptedContent = _encryptionService.decryptText(encryptedContent, diaryPassword);
                } catch (e) {
                  decryptedTitle = '🔒 Şifreli Başlık';
                  decryptedContent = '🔒 Şifreli içerik';
                }

                return _buildHistoryCard(decryptedTitle, decryptedContent, date);
              }).toList(),
            );
          },
        );
      }
    );
  }

  Widget _buildHistoryCard(String title, String content, DateTime date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF064E3B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMMM yyyy', 'tr').format(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4), // Hafif mint arkaplan
      // AppBar'ı tamamen kaldırdık çünkü başlık kısmı gövdeye entegre edildi.
      body: SafeArea(
        child: _isPasswordScreen ? _buildPasswordScreen() : _buildDiaryScreen(),
      ),
    );
  }
}
