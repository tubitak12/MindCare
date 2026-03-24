import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'activities_screen.dart';
import 'tests_screen.dart';
import 'daily_screen.dart';
import 'settings_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String userEmoji;

  const HomeScreen({
    required this.userName,
    required this.userEmoji,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCookieBroken = false;
  String _cookieMessage = "Kurabiyeyi kır ve günün mesajını al!";

  // Ses için değişkenler
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingTitle;

  final List<String> _messages = const [
    "Bugün senin günün! ✨",
    "Kendine güven, her şey güzel olacak 🌿",
    "Küçük mutluluklar seni bekliyor 🍀",
    "Zihnini dinlendir, yenilen 🧘",
    "Sevgiyle kal, mutluluk seni bulacak 💚",
  ];

  // Ses çalma fonksiyonu
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
      print('Ses çalma hatası: $e');
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
      final randomMessage = _messages[_messages.length ~/ 2];
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
      case 0:
        return _buildHomeContent();
      case 1:
        return const ActivitiesScreen();
      case 2:
        return const TestsScreen();
      case 3:
        return const DailyScreen();
      case 4:
        return const AnalyticsScreen();
      case 5:
        return const SettingsScreen();
      default:
        return _buildHomeContent();
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
          _buildMusicItem(
              'Huzurlu Orman', 'Doğa Sesleri', '1 dk 49sn', 'forest.mp3'),
          _buildMusicItem(
              'Odaklanma', 'Yağmur Sesleri', '1dk 48sn', 'rain.mp3'),
          _buildMusicItem(
              'Derin Meditasyon', 'Beyaz Gürültü', '10sn', 'whitenoise.mp3'),
          _buildMusicItem(
              'Gece Ambiyansı', 'Cırcır Böcekleri', '3dk', 'night.mp3'),
          _buildMusicItem(
              'Deniz Dalgaları', 'Okyanus Esintisi', '22sn', 'ocean.mp3'),
          _buildMusicItem(
              'Sıcak Şömine', 'Ateş Çatırtısı', '2dk 50sn', 'fireplace.mp3'),
          const SizedBox(height: 20),
          _buildSectionTitle('Hızlı Erişim'),
          const SizedBox(height: 10),
          _buildQuickAccessGrid(),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7EE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(widget.userEmoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugünün Ruh Hali',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Kendine iyi bak, her şey yolunda.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: Color(0xFF72B01D), size: 16),
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
          border: Border.all(
            color:
                _isCookieBroken ? const Color(0xFF72B01D) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const Text(
              '🍪 Günün Kurabiyesi',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Icon(
              _isCookieBroken ? Icons.auto_awesome : Icons.cookie,
              size: 60,
              color: const Color(0xFF72B01D),
            ),
            const SizedBox(height: 10),
            Text(
              _cookieMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text('Tümünü Gör',
              style: TextStyle(color: Color(0xFF72B01D))),
        ),
      ],
    );
  }

  Widget _buildMusicItem(
      String title, String subtitle, String duration, String fileName) {
    bool isPlaying = _playingTitle == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFFF0F7EE) : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: () => _toggleMusic(fileName, title),
        leading: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          color: const Color(0xFF72B01D),
          size: 30,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7EE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(duration, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      children: [
        _buildQuickAccessItem(
          Icons.self_improvement,
          'Meditasyon',
          () => setState(() => _selectedIndex = 1),
        ),
        _buildQuickAccessItem(
          Icons.assignment,
          'Testler',
          () => setState(() => _selectedIndex = 2),
        ),
        _buildQuickAccessItem(
          Icons.book,
          'Günlük',
          () => setState(() => _selectedIndex = 3),
        ),
        _buildQuickAccessItem(
          Icons.analytics,
          'Analiz',
          () => setState(() => _selectedIndex = 4),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF72B01D)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hoş Geldin',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(widget.userEmoji, style: const TextStyle(fontSize: 20)),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF72B01D)),
            onPressed: () {
              setState(() {
                _selectedIndex = 5;
              });
            },
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
          BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement), label: 'Aktiviteler'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assignment), label: 'Testler'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Günlük'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analiz'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
    );
  }
}
