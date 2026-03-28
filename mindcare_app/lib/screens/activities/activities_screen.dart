import 'package:flutter/material.dart';
import 'breathing_exercise_screen.dart' as be; // alias be
import 'box_breathing_screen.dart' as bb;      // alias bb
import 'diaphragm_breathing_screen.dart' as db; // alias db

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
        children: [
          _buildCategoryCard(
            context,
            'Meditasyon',
            'Zihnini dinlendir',
            Icons.self_improvement,
            const Color(0xFF72B01D),
            [
              {
                'title': '5 Dakika Nefes',
                'duration': '5 dk',
                'description': 'Derin nefes egzersizi'
              },
              {
                'title': '10 Dakika Farkındalık',
                'duration': '10 dk',
                'description': 'Anı yaşama pratiği'
              },
              {
                'title': 'Vücut Taraması',
                'duration': '15 dk',
                'description': 'Vücut farkındalığı'
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Nefes Egzersizleri',
            'Derin nefes al',
            Icons.air,
            const Color(0xFF72B01D),
            [
              {
                'title': '4-7-8 Nefesi',
                'duration': '2 dk',
                'description': 'Rahatlatıcı nefes tekniği'
              },
              {
                'title': 'Kutu Nefesi',
                'duration': '3 dk', // 3 dk olarak ayarlandı
                'description': 'Odaklanma için'
              },
              {
                'title': 'Diyafram Nefesi',
                'duration': '5 dk',
                'description': 'Derin nefes alma'
              },
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Motivasyon',
            'Kendine güç ver',
            Icons.bolt,
            const Color(0xFF72B01D),
            [
              {
                'title': 'Günlük Motivasyon',
                'duration': '3 dk',
                'description': 'Pozitif düşünce'
              },
              {
                'title': 'Başarı Hikayeleri',
                'duration': '5 dk',
                'description': 'İlham verici öyküler'
              },
              {
                'title': 'Hedef Belirleme',
                'duration': '7 dk',
                'description': 'Kendine hedef koy'
              },
            ],
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<Map<String, String>> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: (0.1 * 255).toDouble()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _buildActivityItem(
                context,
                item['title']!,
                item['duration']!,
                item['description']!,
              )),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String duration,
    String description,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_circle_fill,
            color: Color(0xFF72B01D), size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: Color(0xFF1B4332)),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7EE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          duration,
          style: const TextStyle(fontSize: 11, color: Color(0xFF72B01D)),
        ),
      ),
      onTap: () {
        switch (title) {
          case '4-7-8 Nefesi':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const be.BreathingExerciseScreen(),
              ),
            );
            break;
          case 'Kutu Nefesi':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const bb.BoxBreathingScreen(),
              ),
            );
            break;
          case 'Diyafram Nefesi':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const db.DiaphragmBreathingScreen(),
              ),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title aktivitesi yakında! 🧘'),
                backgroundColor: const Color(0xFF72B01D),
                behavior: SnackBarBehavior.fixed,
              ),
            );
        }
      },
    );
  }
}