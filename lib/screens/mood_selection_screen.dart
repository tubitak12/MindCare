import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class MoodSelectionScreen extends StatefulWidget {
  final String userName;
  const MoodSelectionScreen({required this.userName, super.key});

  @override
  State<MoodSelectionScreen> createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  String? selectedMood;
  String? selectedEmoji;

  final List<Map<String, String>> moods = const [
    {'emoji': '😔', 'label': 'Depresif'},
    {'emoji': '😰', 'label': 'Kaygılı'},
    {'emoji': '😠', 'label': 'Sinirli'},
    {'emoji': '😃', 'label': 'Heyecanlı'},
    {'emoji': '😢', 'label': 'Üzgün'},
    {'emoji': '😴', 'label': 'Yorgun'},
    {'emoji': '🤩', 'label': 'Coşkulu'},
    {'emoji': '😊', 'label': 'Mutlu'},
    {'emoji': '😲', 'label': 'Şaşkın'},
  ];

  Future<void> _saveAndGo() async {
    final String today = DateTime.now().toIso8601String().split('T')[0];
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // Firebase'de last_mood_date ve last_emoji kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
            'last_mood_date': today,
            'last_emoji': selectedEmoji!,
          }, SetOptions(merge: true));
      
      // SharedPreferences'a da kaydet (local cache için)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_mood_date', today);
      await prefs.setString('last_emoji', selectedEmoji!);
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userName: widget.userName,
          userEmoji: selectedEmoji!,
          showWelcome: true,
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(title: const Text('Ruh Halin'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Bugün Nasıl Hissediyorsun?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16),
                itemCount: moods.length,
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  final isSelected = selectedMood == mood['label'];
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedMood = mood['label'];
                      selectedEmoji = mood['emoji'];
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF10B981).withValues(alpha: 26)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFF10B981) : Colors.grey.shade200, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood['emoji']!, style: const TextStyle(fontSize: 40)),
                          Text(mood['label']!, style: TextStyle(color: isSelected ? const Color(0xFF064E3B) : Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMood == null ? null : _saveAndGo,
                child: Text(selectedMood == null ? 'Seçim Yap' : 'Ana Sayfaya Git'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}