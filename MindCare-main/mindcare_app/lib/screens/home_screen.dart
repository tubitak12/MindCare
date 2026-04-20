import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare_app/screens/activities/activities_screen.dart';
import 'package:mindcare_app/screens/tests/tests_category_screen.dart';
import 'daily_screen.dart';
import 'analytics_screen.dart';
import 'sounds_screen.dart';

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
  List<String> _motivationalMessages = [];
  bool _isLoadingMessages = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTitle;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadMotivationalMessages();
  }

  Future<void> _loadMotivationalMessages() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('motivations').get();
      List<String> messages = [];
      for (var doc in querySnapshot.docs) {
        String? messageText = doc.get('text') as String?;
        if (messageText != null && messageText.isNotEmpty) {
          messages.add(messageText);
        }
      }
      if (messages.isEmpty) {
        messages = ["Bugün senin günün! ✨", "Kendine güven 🌿", "Zihnini dinlendir 🧘"];
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
          _motivationalMessages = ["Bugün senin günün! ✨"];
          _isLoadingMessages = false;
        });
      }
    }
  }

  String _getRandomMessage() {
    if (_motivationalMessages.isEmpty) return "Bugün kendine iyi bak! 🌟";
    return _motivationalMessages[DateTime.now().millisecondsSinceEpoch % _motivationalMessages.length];
  }

  void _breakCookie() {
    if (_isCookieBroken) return;
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
    setState(() => _selectedIndex = index);
    if (index == 0) _resetCookie();
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0: return _buildHomeContent();
      case 1: return SoundsScreen(onSoundTap: _toggleMusic, playingTitle: _playingTitle);
      case 2: return const ActivitiesScreen();
      case 3: return const TestsCategoryScreen();
      case 4: return const DailyScreen();
      case 5: return const AnalyticsScreen();
      default: return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildMoodCard(),
          const SizedBox(height: 20),
          _buildCookieCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Ruh Haline Özel Sesler'),
          const SizedBox(height: 10),
          
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('sounds').limit(4).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text("Henüz ses eklenmemiş.");
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _buildMusicItem(
                    data['name'] ?? 'İsimsiz Ses',
                    'Rahatlatıcı Ambiyans',
                    'Dinle', 
                    data['url'] ?? '',
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMoodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Text("🍪 Günün Kurabiyesi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Icon(_isCookieBroken ? Icons.cookie_outlined : Icons.cookie, size: 60, color: const Color(0xFF72B01D)),
            const SizedBox(height: 10),
            Text(_cookieMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
      ],
    );
  }

  Widget _buildMusicItem(String title, String subtitle, String trailing, String path) {
    bool isPlaying = _playingTitle == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () => _toggleMusic(path, title),
        leading: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          color: const Color(0xFF72B01D),
          size: 30,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(trailing),
      ),
    );
  }

  Future<void> _toggleMusic(String path, String title) async {
    try {
      if (_playingTitle == title) {
        await _audioPlayer.stop();
        setState(() => _playingTitle = null);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        
        if (path.startsWith('http')) {
          await _audioPlayer.play(UrlSource(path));
        } else {
          await _audioPlayer.play(AssetSource('sounds/$path'));
        }
        
        setState(() => _playingTitle = title);
      }
    } catch (e) {
      debugPrint("Müzik çalma hatası: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF72B01D),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Hoş Geldin, ${widget.userName}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(child: _getPage()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF72B01D),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Sesler"),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: "Aktivite"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Testler"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Günlük"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Analiz"),
        ],
      ),
    );
  }
}