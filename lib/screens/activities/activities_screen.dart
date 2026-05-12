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
    // Testlerdeki gibi soft renkler ve tasarım
    final activities = [
      {
        'title': '4-7-8 Nefesi',
        'description': 'Rahatlatıcı nefes tekniği',
        'icon': Icons.air,
        'color': const Color(0xFF10B981), 
        'screen': 'breathing'
      },
      {
        'title': 'Kutu Nefesi',
        'description': 'Odaklanma için',
        'icon': Icons.air,
        'color': const Color(0xFF3B82F6),
        'screen': 'box'
      },
      {
        'title': 'Diyafram Nefesi',
        'description': 'Derin nefes alma',
        'icon': Icons.air,
        'color': const Color(0xFF8B5CF6),
        'screen': 'diaphragm'
      },
      {
        'title': 'Anı Yaşama Pratiği',
        'description': 'Farkındalık',
        'icon': Icons.self_improvement,
        'color': const Color(0xFFF59E0B),
        'screen': 'mindfulness'
      },
      {
        'title': 'Vücut Taraması',
        'description': 'Farkındalık',
        'icon': Icons.self_improvement,
        'color': const Color(0xFFEC4899),
        'screen': 'bodyscan'
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];

          final String title = activity['title'] as String;
          final String description = activity['description'] as String;
          final IconData icon = activity['icon'] as IconData;
          final Color color = activity['color'] as Color;
          final String screen = activity['screen'] as String;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981), // Testlerle aynı border rengi
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _navigateToActivity(context, screen),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      // Testlerdeki gibi soft ikon container
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1), // Soft arka plan
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 44,
                        ),
                      ),
                      const SizedBox(width: 18),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToActivity(BuildContext context, String screen) {
    switch (screen) {
      case 'breathing':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const be.BreathingExerciseScreen(),
          ),
        );
        break;

      case 'box':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const bb.BoxBreathingScreen(),
          ),
        );
        break;

      case 'diaphragm':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const db.DiaphragmBreathingScreen(),
          ),
        );
        break;

      case 'mindfulness':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ColorFocusGame(),
          ),
        );
        break;

      case 'bodyscan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const DeepBodyScanScreen(totalDuration: 600),
          ),
        );
        break;
    }
  }
}