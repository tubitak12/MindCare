import 'package:flutter/material.dart';
import 'breathing_exercise_screen.dart' as be;
import 'box_breathing_screen.dart' as bb;
import 'diaphragm_breathing_screen.dart' as db;
import 'color_focus_game.dart';
import 'deep_body_scan_screen.dart';

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
              const Color(0xFF10B981),
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
                  'duration': '10 dk',
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
              const Color(0xFF10B981),
              [
                {
                  'title': '4-7-8 Nefesi',
                  'duration': '2 dk',
                  'description': 'Rahatlatıcı nefes tekniği'
                },
                {
                  'title': 'Kutu Nefesi',
                  'duration': '3 dk',
                  'description': 'Odaklanma için'
                },
                {
                  'title': 'Diyafram Nefesi',
                  'duration': '5 dk',
                  'description': 'Derin nefes alma'
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
                        color: Color(0xFF064E3B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
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
          color: Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.play_circle_fill,
          color: Color(0xFF10B981),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF064E3B),
        ),
      ),
      subtitle: Text(
        description,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          duration,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF10B981),
          ),
        ),
      ),
      onTap: () {
        switch (title) {
          case '4-7-8 Nefesi':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const be.BreathingExerciseScreen(),
              ),
            );
            break;

          case 'Kutu Nefesi':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const bb.BoxBreathingScreen(),
              ),
            );
            break;

          case 'Diyafram Nefesi':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const db.DiaphragmBreathingScreen(),
              ),
            );
            break;

          case '10 Dakika Farkındalık': // ✅ EKLENDİ
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ColorFocusGame(),
              ),
            );
            break;

          case 'Vücut Taraması':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DeepBodyScanScreen(totalDuration: 300),
              ),
            );
            break;

          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title yakında eklenecek 🧘'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
        }
      },
    );
  }
}