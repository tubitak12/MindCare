import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        title: const Text(
          'Ruh Halin',
          style: TextStyle(color: Color(0xFF1B4332)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF72B01D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    'Bugün Nasıl Hissediyorsun?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kendini en iyi ifade eden seçeneği seç',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
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
                            ? const Color(0xFF72B01D).withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF72B01D)
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(mood['emoji']!,
                              style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            mood['label']!,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF1B4332)
                                  : Colors.grey,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedMood == null
                    ? null
                    : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                              userName: widget.userName,
                              userEmoji: selectedEmoji!,
                            ),
                          ),
                        );
                      },
                child: Text(
                    selectedMood == null ? 'Seçim Yap' : 'Ana Sayfaya Git'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
