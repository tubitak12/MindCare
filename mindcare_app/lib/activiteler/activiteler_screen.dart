// filepath: c:\Users\Tamer\Desktop\MindCare\mindcare_app\lib\activiteler\activiteler_screen.dart
import 'package:flutter/material.dart';

class ActivitelerScreen extends StatelessWidget {
  const ActivitelerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activities = const [
      {
        'title': 'Meditasyon',
        'subtitle': '10 dakikalık nefes egzersizi',
        'icon': Icons.self_improvement,
        'color': Color(0xFF7BAEFF)
      },
      {
        'title': 'Egzersiz',
        'subtitle': 'Hafif bir yürüyüş veya yoga',
        'icon': Icons.fitness_center,
        'color': Color(0xFF00C853)
      },
      {
        'title': 'Nefes Egzersizi',
        'subtitle': '4‑7‑8 nefes tekniği',
        'icon': Icons.air,
        'color': Color(0xFFFF4081)
      },
      {
        'title': 'Yaratıcılık',
        'subtitle': 'Resim, müzik veya yazı',
        'icon': Icons.brush,
        'color': Color(0xFF7C4DFF)
      },
      {
        'title': 'Farkındalık',
        'subtitle': 'An’da kalma pratikleri',
        'icon': Icons.visibility,
        'color': Color(0xFFFFAB00)
      },
      {
        'title': 'Okuma',
        'subtitle': 'İlham verici bir kitap oku',
        'icon': Icons.book,
        'color': Color(0xFF2979FF)
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Aktiviteler'),
        backgroundColor: const Color(0xFF7B61FF),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final a = activities[index];
          return Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: a['color'] as Color,
                child: Icon(a['icon'] as IconData, color: Colors.white),
              ),
              title: Text(a['title'] as String),
              subtitle: Text(a['subtitle'] as String),
              onTap: () {
                // buraya tıklama işlevi ekleyebilirsin
              },
            ),
          );
        },
      ),
    );
  }
}