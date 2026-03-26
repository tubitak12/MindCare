import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    {'emoji': '😢', 'label': 'Üzgün'},
    {'emoji': '😔', 'label': 'Kötü'},
    {'emoji': '😐', 'label': 'Normal'},
    {'emoji': '🙂', 'label': 'İyi'},
    {'emoji': '😊', 'label': 'Mutlu'},
    {'emoji': '😁', 'label': 'Harika'},
  ];

  Future<void> _saveAndGo() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateTime.now().toIso8601String().split('T')[0];
    
    await prefs.setString('last_mood_date', today);
    await prefs.setString('last_emoji', selectedEmoji!);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          userName: widget.userName,
          userEmoji: selectedEmoji!,
          showWelcome: true, // Mesaj ana sayfada çıksın diye true gönderiyoruz
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
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
                        color: isSelected ? const Color(0xFF72B01D).withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFF72B01D) : Colors.grey.shade200, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood['emoji']!, style: const TextStyle(fontSize: 40)),
                          Text(mood['label']!, style: TextStyle(color: isSelected ? const Color(0xFF1B4332) : Colors.grey)),
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