import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorFocusGame extends StatefulWidget {
  const ColorFocusGame({super.key});

  @override
  State<ColorFocusGame> createState() => _ColorFocusGameState();
}

class _ColorFocusGameState extends State<ColorFocusGame> {
  final int baseGridSize = 4;
  int gridSize = 4;

  int level = 1;
  int highestLevel = 1;
  int targetIndex = 0;
  bool _gameStarted = false;
  bool _isPaused = false;
  bool _isLoading = true;

  Color baseColor = Colors.blue;
  Color differentColor = Colors.blue;

  final Random random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Color> softColors = [
    const Color(0xFFA8D5BA),
    const Color(0xFFBFD8D2),
    const Color(0xFFD6EADF),
    const Color(0xFFE2ECE9),
    const Color(0xFFB5C9E2),
    const Color(0xFFC9D6EA),
    const Color(0xFFEADBC8),
    const Color(0xFFF3E9DC),
    const Color(0xFFDAD2BC),
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _loadHighestLevelFromFirebase();
    startGame();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadHighestLevelFromFirebase() async {
    try {
      User? user = _auth.currentUser;
      
      if (user == null) {
        // Kullanıcı giriş yapmamışsa anonim giriş yap
        await _signInAnonymously();
        user = _auth.currentUser;
      }
      
      if (user != null) {
        final docRef = _firestore.collection('gameScores').doc(user.uid);
        final docSnapshot = await docRef.get();
        
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data.containsKey('colorGameHighestLevel')) {
            setState(() {
              highestLevel = data['colorGameHighestLevel'];
            });
            debugPrint('En yüksek seviye Firebase\'den yüklendi: $highestLevel');
          } else {
            // İlk kez kayıt yapılıyor
            await docRef.set({
              'colorGameHighestLevel': 1,
              'lastUpdated': FieldValue.serverTimestamp(),
              'email': user.email ?? 'anonymous',
            });
          }
        } else {
          // Belge yok, oluştur
          await docRef.set({
            'colorGameHighestLevel': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'email': user.email ?? 'anonymous',
          });
        }
      }
    } catch (e) {
      debugPrint('Firebase\'den en yüksek seviye yüklenirken hata: $e');
      // Firebase hatası durumunda local'den yükle
      await _loadHighestLevelFromLocal();
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      debugPrint('Anonim giriş başarılı');
    } catch (e) {
      debugPrint('Anonim giriş hatası: $e');
    }
  }

  Future<void> _saveHighestLevelToFirebase(int newHighestLevel) async {
    try {
      User? user = _auth.currentUser;
      
      if (user != null) {
        await _firestore.collection('gameScores').doc(user.uid).set({
          'colorGameHighestLevel': newHighestLevel,
          'lastUpdated': FieldValue.serverTimestamp(),
          'email': user.email ?? 'anonymous',
        }, SetOptions(merge: true));
        
        debugPrint('✅ En yüksek seviye Firebase\'e kaydedildi: $newHighestLevel');
      }
    } catch (e) {
      debugPrint('❌ Firebase\'e kaydedilirken hata: $e');
      // Firebase'e kaydedilemezse local'e kaydet
      await _saveHighestLevelToLocal(newHighestLevel);
    }
  }

  Future<void> _saveHighestLevelToLocal(int newHighestLevel) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('colorGameHighestLevel', newHighestLevel);
      debugPrint('En yüksek seviye local\'e kaydedildi: $newHighestLevel');
    } catch (e) {
      debugPrint('Local kayıt hatası: $e');
    }
  }

  Future<void> _loadHighestLevelFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        highestLevel = prefs.getInt('colorGameHighestLevel') ?? 1;
      });
      debugPrint('En yüksek seviye local\'den yüklendi: $highestLevel');
    } catch (e) {
      debugPrint('Local yükleme hatası: $e');
    }
  }

  void startGame() {
    // Her 8 seviyeden sonra grid boyutu artar (max 6x6)
    gridSize = baseGridSize + (level ~/ 8);
    if (gridSize > 6) gridSize = 6;

    int total = gridSize * gridSize;
    targetIndex = random.nextInt(total);

    baseColor = getRandomColor();
    differentColor = getSlightlyDifferentColor(baseColor);
  }

  Color getRandomColor() {
    return softColors[random.nextInt(softColors.length)];
  }

  Color getSlightlyDifferentColor(Color base) {
    // Seviye arttıkça fark küçülüyor
    int diff = max(5, 45 - (level - 1));
    
    if (level > 30) diff = max(3, diff);
    if (level > 50) diff = max(2, diff);

    int r = (base.red + random.nextInt(diff) - diff ~/ 2).clamp(0, 255);
    int g = (base.green + random.nextInt(diff) - diff ~/ 2).clamp(0, 255);
    int b = (base.blue + random.nextInt(diff) - diff ~/ 2).clamp(0, 255);

    Color newColor = Color.fromARGB(255, r, g, b);
    if (newColor == base && diff > 1) {
      r = (base.red + 5).clamp(0, 255);
      g = (base.green - 3).clamp(0, 255);
      b = (base.blue + 2).clamp(0, 255);
      return Color.fromARGB(255, r, g, b);
    }
    
    return newColor;
  }

  Future<void> _playErrorSound() async {
    try {
      HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Hata feedback çalınamadı: $e');
    }
  }

  void _resetGame() {
    setState(() {
      level = 1;
      _gameStarted = true;
      _isPaused = false;
      startGame();
    });
  }

  void onTap(int index) {
    if (!_gameStarted || _isPaused) return;

    if (index == targetIndex) {
      // Doğru seçim - seviye artır
      setState(() {
        level++;
        
        // En yüksek seviyeyi güncelle
        if (level > highestLevel) {
          highestLevel = level;
          _saveHighestLevelToFirebase(highestLevel);
        }
        
        startGame();
      });
    } else {
      // Yanlış seçim - oyunu sıfırla ve başa sar
      _playErrorSound();
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sentiment_very_dissatisfied,
                  size: 65,
                  color: Color(0xFFD4183D),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Yanlış Seçim!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Seviye $level'de kaldın",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "🏆 En Yüksek Seviye: $highestLevel",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _resetGame();
                        },
                        child: const Text(
                          "Tekrar Dene",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF10B981),
                            width: 2,
                          ),
                          foregroundColor: const Color(0xFF10B981),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Çık",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _getDifficultyText() {
    if (level <= 10) return "🌟 Kolay";
    if (level <= 20) return "⚡ Orta";
    if (level <= 35) return "🔥 Zor";
    if (level <= 50) return "💀 Uzman";
    return "👑 Efsane";
  }

  @override
  Widget build(BuildContext context) {
    int total = gridSize * gridSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Anı Yaşama Pratiği - Renk Oyunu"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _gameStarted
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF10B981),
              ),
            )
          : !_gameStarted
              ? _buildTutorialScreen()
              : Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Mevcut Seviye",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "$level",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        Column(
                          children: [
                            const Text(
                              "En Yüksek Seviye",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events,
                                  size: 20,
                                  color: Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$highestLevel",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getDifficultyText(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          itemCount: total,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => onTap(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: index == targetIndex
                                      ? differentColor
                                      : baseColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isPaused
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFD1FAE5),
                                foregroundColor: _isPaused
                                    ? Colors.white
                                    : const Color(0xFF047857),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPaused = !_isPaused;
                                });
                              },
                              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                              label: Text(_isPaused ? 'Devam Et' : 'Duraklat'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF047857),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              label: const Text('Çık'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTutorialScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.games,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
                SizedBox(height: 16),
                Text(
                  "Renk Oyunu",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF064E3B),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  "Farkındalık Pratiği",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Oyun Kuralları",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 16),
          _buildRuleItem(
            1,
            "Farklı Rengi Bul",
            "Izgara içinde diğerlerinden farklı olan rengi bul.",
          ),
          _buildRuleItem(
            2,
            "Doğru Seç",
            "Doğru rengi seçersen seviyen artar.",
          ),
          _buildRuleItem(
            3,
            "Dikkatli Ol",
            "Yanlış rengi seçersen oyun başa sarar ve seviyen 1'e düşer.",
          ),
          _buildRuleItem(
            4,
            "Rekorunu Kır",
            "En yüksek seviyen Firebase'de saklanır ve her cihazda aynı kalır!",
          ),
          const SizedBox(height: 32),
          const Text(
            "İpuçları",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 12),
          _buildTipItem("💡 Dikkatle bak, renk farkı çok az olabilir"),
          _buildTipItem("💡 Seviye arttıkça renkler birbirine daha çok yaklaşır"),
          _buildTipItem("💡 Gözlerini kısarak bakmayı dene"),
          _buildTipItem("💡 Acele etme, doğru rengi bulmaya odaklan"),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                setState(() {
                  _gameStarted = true;
                  _isPaused = false;
                  level = 1;
                  startGame();
                });
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text(
                "Oyuna Başla",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRuleItem(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4B5563),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}