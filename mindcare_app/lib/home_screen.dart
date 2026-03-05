import 'package:flutter/material.dart';
import 'mood_detail_screen.dart';
import 'activiteler/activiteler_screen.dart';
import 'testler/testler_screen.dart';
import 'gunluk/gunluk_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({required this.userName, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String selectedEmoji = "❓";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: _bodyForIndex(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7B61FF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_graph), label: 'Aktiviteler'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Testler'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Günlük'),
        ],
      ),
    );
  }

  Widget _bodyForIndex(int index) {
    switch (index) {
      case 1:
        return ActivitelerScreen();
      case 2:
        return TestlerScreen();
      case 3:
        return const GunlukScreen();
      case 0:
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('İyi günler',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  Text(widget.userName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                    ),
                    child:
                        Text(selectedEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF7B61FF),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Center(
            child: Column(
              children: [
                Text('Bugün nasıl hissediyorsun?',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E))),
                SizedBox(height: 8),
                Text('Ruh halinizi seçin', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.3,
              children: [
                _moodCard("Çok Üzgün", "😢"),
                _moodCard("Üzgün", "😔"),
                _moodCard("Normal", "😐"),
                _moodCard("İyi", "😊"),
                _moodCard("Mutlu", "😁"),
                _moodCard("Çok Mutlu", "🤩"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodCard(String title, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmoji = emoji;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoodDetailScreen(
              userName: widget.userName,
              emoji: emoji,
              moodTitle: title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedEmoji == emoji
                ? const Color(0xFF7B61FF)
                : const Color(0xFFE0E0E0).withOpacity(0.5),
            width: selectedEmoji == emoji ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          ],
        ),
      ),
    );
  }
}