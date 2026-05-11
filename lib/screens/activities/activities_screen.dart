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
    const Color primaryGreen = Color(0xFF10B981);
    const Color darkText = Color(0xFF064E3B);

    final activities = [
      {
        'title': '4-7-8 Nefesi',
        'description': 'Rahatlatıcı nefes tekniği',
        'icon': Icons.air,
        'screen': 'breathing'
      },
      {
        'title': 'Kutu Nefesi',
        'description': 'Odaklanma için',
        'icon': Icons.air,
        'screen': 'box'
      },
      {
        'title': 'Diyafram Nefesi',
        'description': 'Derin nefes alma',
        'icon': Icons.air,
        'screen': 'diaphragm'
      },
      {
        'title': 'Anı Yaşama Pratiği',
        'description': 'Farkındalık',
        'icon': Icons.self_improvement,
        'screen': 'mindfulness'
      },
      {
        'title': 'Vücut Taraması',
        'description': 'Farkındalık',
        'icon': Icons.self_improvement,
        'screen': 'bodyscan'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final activity = activities[index];

          final String title = activity['title'] as String;
          final String description = activity['description'] as String;
          final IconData icon = activity['icon'] as IconData;
          final String screen = activity['screen'] as String;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryGreen,
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
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          icon,
                          color: primaryGreen,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: darkText,
                              ),
                            ),

                            if (description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
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