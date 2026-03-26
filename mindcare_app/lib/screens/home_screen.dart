import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'activities_screen.dart';
import 'tests_screen.dart';
import 'daily_screen.dart';
import 'settings_screen.dart';
import 'analytics_screen.dart';
import 'sounds_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmoji;
  final bool showWelcome; // Mod seçimi sonrası mesaj için

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

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTitle;

  final List<String> _messages = const [
    "Bugün senin günün! ✨",
    "Kendine güven, her şey güzel olacak 🌿",
    "Küçük mutluluklar seni bekliyor 🍀",
    "Zihnini dinlendir, yenilen 🧘",
    "Sevgiyle kal, mutluluk seni bulacak 💚",
  ];

  @override
  void initState() {
    super.initState();
    // Eğer mod seçiminden geliniyorsa mesajı EKRANIN ÜSTÜNDE gösterir
    if (widget.showWelcome) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showTopWelcomeMessage());
    }
  }

  void _showTopWelcomeMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Hoş geldin ${widget.userName}! ✨ Modun kaydedildi.", textAlign: TextAlign.center),
        backgroundColor: const Color(0xFF72B01D),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100, // Mesajı yukarı taşır
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleMusic(String fileName, String title) async {
    try {
      if (_playingTitle == title) {
        await _audioPlayer.stop();
        setState(() => _playingTitle = null);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/$fileName'));
        setState(() => _playingTitle = title);
      }
    } catch (e) {
      _showSnackBar('Ses dosyası bulunamadı: $fileName');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  void _breakCookie() {
    if (!_isCookieBroken) {
      final randomMessage = _messages[(DateTime.now().millisecond) % _messages.length];
      setState(() {
        _isCookieBroken = true;
        _cookieMessage = randomMessage;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isCookieBroken = false;
            _cookieMessage = "Kurabiyeyi kır ve günün mesajını al!";
          });
        }
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF72B01D),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0: return _buildHomeContent();
      case 1: return SoundsScreen(onSoundTap: _toggleMusic, playingTitle: _playingTitle);
      case 2: return const ActivitiesScreen();
      case 3: return const TestsScreen();
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
          _buildMusicItem('Huzurlu Orman', 'Doğa Sesleri', '1 dk 49sn', 'forest.mp3'),
          _buildMusicItem('Odaklanma', 'Yağmur Sesleri', '1dk 48sn', 'rain.mp3'),
          _buildMusicItem('Derin Meditasyon', 'Beyaz Gürültü', '10sn', 'whitenoise.mp3'),
          _buildMusicItem('Gece Ambiyansı', 'Cırcır Böcekleri', '3dk', 'night.mp3'),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF0F7EE), borderRadius: BorderRadius.circular(15)),
            child: Text(widget.userEmoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bugünün Ruh Hali', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Kendine iyi bak, her şey yolunda.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFF72B01D), size: 16),
        ],
      ),
    );
  }

  Widget _buildCookieCard() {
    return GestureDetector(
      onTap: _breakCookie,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _isCookieBroken ? const Color(0xFF72B01D) : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            const Text('🍪 Günün Kurabiyesi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            Icon(_isCookieBroken ? Icons.auto_awesome : Icons.cookie, size: 60, color: const Color(0xFF72B01D)),
            const SizedBox(height: 10),
            Text(_cookieMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
        TextButton(
          onPressed: () => setState(() => _selectedIndex = 1),
          child: const Text('Tümünü Gör', style: TextStyle(color: Color(0xFF72B01D))),
        ),
      ],
    );
  }

  Widget _buildMusicItem(String title, String subtitle, String duration, String fileName) {
    bool isPlaying = _playingTitle == title;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: isPlaying ? const Color(0xFFF0F7EE) : Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => _toggleMusic(fileName, title),
        leading: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: const Color(0xFF72B01D), size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Text(duration, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Hoş Geldin, ${widget.userName}', style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF72B01D)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
          ),
        ],
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF72B01D),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Sesler'),
          BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: 'Aktiviteler'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Testler'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Günlük'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analiz'),
        ],
      ),
    );
  }
}