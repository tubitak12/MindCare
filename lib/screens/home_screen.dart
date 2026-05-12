import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mindcare_app/screens/activities/activities_screen.dart';
import 'package:mindcare_app/screens/tests/tests_category_screen.dart';
import 'daily_screen.dart';
import 'analytics_screen.dart';
import 'sounds_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmoji;
  final bool showWelcome;

  const HomeScreen({
    required this.userName,
    required this.userEmoji,
    this.showWelcome = false,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  bool _isCookieBroken = false;
  String _cookieMessage = "Kurabiyeyi kır ve günün mesajını al!";

  bool _isPlayerVisible = false;        
  String? _lastPlayedTitle;      
  String? _lastPlayedUrl;

  List<String> _motivationalMessages = [];
  bool _isLoadingMessages = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTitle;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadMotivationalMessages();
    _checkDailyCookieReset();
  }

  Future<void> _checkDailyCookieReset() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final lastBreakDate = userDoc.data()?['last_cookie_break_date'] as String?;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Eğer tarih farklıysa, kurabiye sıfırla
      if (lastBreakDate != today) {
        setState(() {
          _isCookieBroken = false;
          _cookieMessage = "Kurabiyeyi kır ve günün mesajını al!";
        });
      } else {
        // Aynı gün ve kırıldıysa, state'i güncelleyin
        setState(() {
          _isCookieBroken = true;
        });
      }
    } catch (e) {
      debugPrint('Kurabiye tarihi kontrol edilirken hata: $e');
    }
  }

  Future<void> _loadMotivationalMessages() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('motivations').get();

      List<String> messages = [];

      for (var doc in querySnapshot.docs) {
        String? messageText = doc.get('text') as String?;
        if (messageText != null && messageText.isNotEmpty) {
          messages.add(messageText);
        }
      }

      if (messages.isEmpty) {
        messages = [
          "Bugün senin günün! ✨",
          "Kendine güven 🌿",
          "Küçük mutluluklar 🍀",
          "Zihnini dinlendir 🧘",
          "Sevgiyle kal 💚",
        ];
      }

      if (mounted) {
        setState(() {
          _motivationalMessages = messages;
          _isLoadingMessages = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _motivationalMessages = [
            "Bugün senin günün! ✨",
            "Kendine güven 🌿",
            "Küçük mutluluklar 🍀",
            "Zihnini dinlendir 🧘",
            "Sevgiyle kal 💚",
          ];
          _isLoadingMessages = false;
        });
      }
    }
  }

  String _getRandomMessage() {
    if (_motivationalMessages.isEmpty) {
      return "Bugün kendine iyi bak! 🌟";
    }
    return _motivationalMessages[
        DateTime.now().millisecondsSinceEpoch %
            _motivationalMessages.length];
  }

  void _breakCookie() async {
    if (_isCookieBroken) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kurabiye günde sadece 1 kez kırılabilir! Yarın tekrar dene 🍪'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      return;
    }

    final user = _auth.currentUser;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Firebase'e tarih kaydet
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'last_cookie_break_date': today,
          'last_cookie_break_time': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Activity olarak kaydet
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('activities')
            .add({
          'type': 'cookie_break',
          'timestamp': FieldValue.serverTimestamp(),
          'dateKey': today,
        });
      } catch (e) {
        debugPrint('Kurabiye tarihi kaydedilirken hata: $e');
      }
    }

    setState(() {
      _isCookieBroken = true;
      _cookieMessage = _getRandomMessage();
    });
  }

  void _resetCookie() {
    setState(() {
      _isCookieBroken = false;
      _cookieMessage = "Kurabiyeyi kır ve günün mesajını al!";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _resetCookie();
    }
  }

 Widget _getPage() {
  switch (_selectedIndex) {
    case 1:
      return SoundsScreen(
        onSoundTap: (url, title) async {
          if (_playingTitle == title) {
            await _audioPlayer.stop();
            setState(() {
              _playingTitle = null; // Müzik durdu ama isim gitmeyecek
            });
          } else {
            await _audioPlayer.stop();
            await _audioPlayer.setReleaseMode(ReleaseMode.loop);
            await _audioPlayer.play(AssetSource('sounds/$url'));
            setState(() {
              _playingTitle = title;
              _lastPlayedTitle = title; // İsim hafızaya alındı
              _lastPlayedUrl = url;     // URL hafızaya alındı
              _isPlayerVisible = true;  // Bar açıldı
            });
          }
        },
        playingTitle: _playingTitle,
      );
      case 2:
        return const ActivitiesScreen();
      case 3:
        return const TestsCategoryScreen();
      case 4:
        return const DailyScreen();
      case 5:
        return const AnalyticsScreen();
      default:
        return _buildHomeContent();
    }
  }

  // Ruh haline göre dizi/film önerileri (IMDb puanına göre sıralı)
  List<Map<String, dynamic>> _getRecommendations() {
    final mood = widget.userEmoji;
    final Map<String, List<Map<String, dynamic>>> moodMap = {
      '😔': [
        {'title': 'The Pursuit of Happyness', 'type': 'Film', 'imdb': 8.0, 'year': 2006, 'genre': 'Dram', 'poster': '🎬'},
        {'title': 'Good Will Hunting', 'type': 'Film', 'imdb': 8.3, 'year': 1997, 'genre': 'Dram', 'poster': '🎬'},
        {'title': 'Inside Out', 'type': 'Film', 'imdb': 8.1, 'year': 2015, 'genre': 'Animasyon', 'poster': '🎬'},
        {'title': 'Ted Lasso', 'type': 'Dizi', 'imdb': 8.8, 'year': 2020, 'genre': 'Komedi', 'poster': '📺'},
        {'title': 'After Life', 'type': 'Dizi', 'imdb': 8.4, 'year': 2019, 'genre': 'Dram/Komedi', 'poster': '📺'},
      ],
      '😰': [
        {'title': 'The Secret Life of Walter Mitty', 'type': 'Film', 'imdb': 7.3, 'year': 2013, 'genre': 'Macera', 'poster': '🎬'},
        {'title': 'Soul', 'type': 'Film', 'imdb': 8.0, 'year': 2020, 'genre': 'Animasyon', 'poster': '🎬'},
        {'title': 'Forrest Gump', 'type': 'Film', 'imdb': 8.8, 'year': 1994, 'genre': 'Dram', 'poster': '🎬'},
        {'title': 'Schitt\'s Creek', 'type': 'Dizi', 'imdb': 8.5, 'year': 2015, 'genre': 'Komedi', 'poster': '📺'},
        {'title': 'Parks and Recreation', 'type': 'Dizi', 'imdb': 8.6, 'year': 2009, 'genre': 'Komedi', 'poster': '📺'},
      ],
      '😠': [
        {'title': 'Amélie', 'type': 'Film', 'imdb': 8.3, 'year': 2001, 'genre': 'Romantik', 'poster': '🎬'},
        {'title': 'Up', 'type': 'Film', 'imdb': 8.3, 'year': 2009, 'genre': 'Animasyon', 'poster': '🎬'},
        {'title': 'The Office', 'type': 'Dizi', 'imdb': 9.0, 'year': 2005, 'genre': 'Komedi', 'poster': '📺'},
        {'title': 'Brooklyn Nine-Nine', 'type': 'Dizi', 'imdb': 8.4, 'year': 2013, 'genre': 'Komedi', 'poster': '📺'},
        {'title': 'My Neighbor Totoro', 'type': 'Film', 'imdb': 8.1, 'year': 1988, 'genre': 'Animasyon', 'poster': '🎬'},
      ],
      '😃': [
        {'title': 'Inception', 'type': 'Film', 'imdb': 8.8, 'year': 2010, 'genre': 'Bilim Kurgu', 'poster': '🎬'},
        {'title': 'Interstellar', 'type': 'Film', 'imdb': 8.7, 'year': 2014, 'genre': 'Bilim Kurgu', 'poster': '🎬'},
        {'title': 'Stranger Things', 'type': 'Dizi', 'imdb': 8.7, 'year': 2016, 'genre': 'Bilim Kurgu', 'poster': '📺'},
        {'title': 'The Grand Budapest Hotel', 'type': 'Film', 'imdb': 8.1, 'year': 2014, 'genre': 'Komedi', 'poster': '🎬'},
        {'title': 'Arcane', 'type': 'Dizi', 'imdb': 9.0, 'year': 2021, 'genre': 'Animasyon', 'poster': '📺'},
      ],
      '😢': [
        {'title': 'Hachi: A Dog\'s Tale', 'type': 'Film', 'imdb': 8.1, 'year': 2009, 'genre': 'Dram', 'poster': '🎬'},
        {'title': 'Coco', 'type': 'Film', 'imdb': 8.4, 'year': 2017, 'genre': 'Animasyon', 'poster': '🎬'},
        {'title': 'This Is Us', 'type': 'Dizi', 'imdb': 8.7, 'year': 2016, 'genre': 'Dram', 'poster': '📺'},
        {'title': 'The Intouchables', 'type': 'Film', 'imdb': 8.5, 'year': 2011, 'genre': 'Dram/Komedi', 'poster': '🎬'},
        {'title': 'Friends', 'type': 'Dizi', 'imdb': 8.9, 'year': 1994, 'genre': 'Komedi', 'poster': '📺'},
      ],
      '😴': [
        {'title': 'The Shawshank Redemption', 'type': 'Film', 'imdb': 9.3, 'year': 1994, 'genre': 'Dram', 'poster': '🎬'},
        {'title': 'Planet Earth', 'type': 'Dizi', 'imdb': 9.4, 'year': 2006, 'genre': 'Belgesel', 'poster': '📺'},
        {'title': 'WALL-E', 'type': 'Film', 'imdb': 8.4, 'year': 2008, 'genre': 'Animasyon', 'poster': '🎬'},
        {'title': 'Midnight Diner', 'type': 'Dizi', 'imdb': 8.4, 'year': 2009, 'genre': 'Dram', 'poster': '📺'},
        {'title': 'Chef\'s Table', 'type': 'Dizi', 'imdb': 8.5, 'year': 2015, 'genre': 'Belgesel', 'poster': '📺'},
      ],
      '🤩': [
        {'title': 'The Dark Knight', 'type': 'Film', 'imdb': 9.0, 'year': 2008, 'genre': 'Aksiyon', 'poster': '🎬'},
        {'title': 'Breaking Bad', 'type': 'Dizi', 'imdb': 9.5, 'year': 2008, 'genre': 'Dram', 'poster': '📺'},
        {'title': 'Mad Max: Fury Road', 'type': 'Film', 'imdb': 8.1, 'year': 2015, 'genre': 'Aksiyon', 'poster': '🎬'},
        {'title': 'Attack on Titan', 'type': 'Dizi', 'imdb': 9.1, 'year': 2013, 'genre': 'Animasyon', 'poster': '📺'},
        {'title': 'Spider-Man: Into the Spider-Verse', 'type': 'Film', 'imdb': 8.4, 'year': 2018, 'genre': 'Animasyon', 'poster': '🎬'},
      ],
      '😊': [
        {'title': 'La La Land', 'type': 'Film', 'imdb': 8.0, 'year': 2016, 'genre': 'Müzikal', 'poster': '🎬'},
        {'title': 'Modern Family', 'type': 'Dizi', 'imdb': 8.5, 'year': 2009, 'genre': 'Komedi', 'poster': '📺'},
        {'title': 'The Secret Garden', 'type': 'Film', 'imdb': 7.3, 'year': 2020, 'genre': 'Fantastik', 'poster': '🎬'},
        {'title': 'Gilmore Girls', 'type': 'Dizi', 'imdb': 8.1, 'year': 2000, 'genre': 'Komedi/Dram', 'poster': '📺'},
        {'title': 'Begin Again', 'type': 'Film', 'imdb': 7.4, 'year': 2013, 'genre': 'Müzikal', 'poster': '🎬'},
      ],
      '😲': [
        {'title': 'Shutter Island', 'type': 'Film', 'imdb': 8.2, 'year': 2010, 'genre': 'Gerilim', 'poster': '🎬'},
        {'title': 'Black Mirror', 'type': 'Dizi', 'imdb': 8.7, 'year': 2011, 'genre': 'Bilim Kurgu', 'poster': '📺'},
        {'title': 'The Prestige', 'type': 'Film', 'imdb': 8.5, 'year': 2006, 'genre': 'Gerilim', 'poster': '🎬'},
        {'title': 'Dark', 'type': 'Dizi', 'imdb': 8.8, 'year': 2017, 'genre': 'Bilim Kurgu', 'poster': '📺'},
        {'title': 'Memento', 'type': 'Film', 'imdb': 8.4, 'year': 2000, 'genre': 'Gerilim', 'poster': '🎬'},
      ],
    };

    List<Map<String, dynamic>> recs = moodMap[mood] ?? moodMap['😊']!;
    recs.sort((a, b) => (b['imdb'] as double).compareTo(a['imdb'] as double));
    return recs;
  }

  Widget _buildHomeContent() {
    final recommendations = _getRecommendations();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMoodCard(),
          const SizedBox(height: 20),
          _buildCookieCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('🎬 Ruh Haline Göre Dizi & Film'),
          const SizedBox(height: 10),
          ...recommendations.map((r) => _buildMovieItem(r)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMoodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(widget.userEmoji, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 16),
          const Expanded(child: Text("Bugünün Ruh Hali")),
        ],
      ),
    );
  }

  Widget _buildCookieCard() {
    return GestureDetector(
      onTap: _isLoadingMessages ? null : _breakCookie,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Text(
              "🍪 Günün Kurabiyesi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            // Kırılmamış kurabiye gösterimi
            if (!_isCookieBroken) ...[
              Icon(
                Icons.cookie,
                size: 80,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 20),
              Text(
                _cookieMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ]
            // Kırılmış kurabiye - yeşil kart gösterimi
            else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '✨',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _cookieMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '— Bugünün Mesajı',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFD1F4E5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF064E3B),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieItem(Map<String, dynamic> movie) {
    final double imdb = movie['imdb'];
    final Color ratingColor = imdb >= 9.0
        ? const Color(0xFF10B981)
        : imdb >= 8.0
            ? const Color(0xFF059669)
            : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(movie['poster'], style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          movie['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF064E3B),
          ),
        ),
        subtitle: Text(
          '${movie['type']} • ${movie['genre']} • ${movie['year']}',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: ratingColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ratingColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: ratingColor, size: 16),
              const SizedBox(width: 2),
              Text(
                imdb.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: ratingColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        title: Text(
          "Hoş Geldin, ${widget.userName}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(child: _getPage()),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userName: widget.userName,
                  userEmoji: widget.userEmoji,
                ),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Text('🧠', style: TextStyle(fontSize: 28)),
        ),
      ),
      
      bottomSheet: !_isPlayerVisible 
    ? null 
    : Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B4332), 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
              child: const Icon(Icons.music_note, color: Color(0xFF72B01D), size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _playingTitle ?? _lastPlayedTitle ?? "Ses Seçilmedi", // İsim burada çakılı kalır
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text("Zihnini özgür bırak...", style: TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
            ),
            // Oynat / Durdur Butonu
            IconButton(
              icon: Icon(
                _playingTitle == null ? Icons.play_circle_filled : Icons.pause_circle_filled,
                color: Colors.white, size: 42
              ),
              onPressed: () async {
                if (_playingTitle != null) {
                  await _audioPlayer.stop();
                  setState(() => _playingTitle = null);
                } else if (_lastPlayedUrl != null) {
                  // Hafızadaki sesi tekrar başlatır
                  await _audioPlayer.play(AssetSource('sounds/$_lastPlayedUrl'));
                  setState(() => _playingTitle = _lastPlayedTitle);
                }
              },
            ),
            // Kapatma (X) Butonu
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
              onPressed: () async {
                await _audioPlayer.stop();
                setState(() {
                  _playingTitle = null;
                  _isPlayerVisible = false;
                });
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF10B981),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Sesler"),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: "Aktiviteler"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Testler"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Günlük"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analiz"),
        ],
      ),
    );
  }
}