import 'package:flutter/material.dart';

class SoundsScreen extends StatelessWidget {
  final Function(String, String) onSoundTap;
  final String? playingTitle;

  const SoundsScreen({required this.onSoundTap, this.playingTitle, super.key});

  // Ses kategorileri ve içindeki dosyalar
  final List<Map<String, dynamic>> categories = const [
    {
      'title': 'Yağmur Sesleri',
      'icon': Icons.umbrella,
      'color': Colors.blue,
      'sounds': [
        {'name': 'Hafif Yağmur', 'file': 'rain.mp3', 'duration': '1dk 48sn'},
        {'name': 'Gök Gürültüsü', 'file': 'thunder.mp3', 'duration': '2dk'},
      ]
    },
    {
      'title': 'Doğa Sesleri',
      'icon': Icons.forest,
      'color': Colors.green,
      'sounds': [
        {'name': 'Huzurlu Orman', 'file': 'forest.mp3', 'duration': '1dk 49sn'},
        {'name': 'Kuş Sesleri', 'file': 'birds.mp3', 'duration': '1dk 30sn'},
      ]
    },
    {
      'title': 'Meditasyon',
      'icon': Icons.self_improvement,
      'color': Colors.purple,
      'sounds': [
        {'name': 'Derin Odaklanma', 'file': 'meditation.mp3', 'duration': '5dk'},
        {'name': 'Beyaz Gürültü', 'file': 'whitenoise.mp3', 'duration': '10sn'},
      ]
    },
    {
      'title': 'Gece & Uyku',
      'icon': Icons.nightlight_round,
      'color': Colors.indigo,
      'sounds': [
        {'name': 'Gece Ambiyansı', 'file': 'night.mp3', 'duration': '3dk'},
        {'name': 'Sıcak Şömine', 'file': 'fireplace.mp3', 'duration': '2dk 50sn'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        title: const Text("Ses Kütüphanesi", style: TextStyle(color: Color(0xFF1B4332))),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF72B01D)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return InkWell(
            onTap: () => _showSoundList(context, cat),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'], size: 45, color: cat['color']),
                  const SizedBox(height: 12),
                  Text(cat['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSoundList(BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Divider(),
              ...category['sounds'].map<Widget>((sound) {
                bool isPlaying = playingTitle == sound['name'];
                return ListTile(
                  leading: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: const Color(0xFF72B01D)),
                  title: Text(sound['name']),
                  subtitle: Text(sound['duration']),
                  onTap: () {
                    onSoundTap(sound['file'], sound['name']);
                    Navigator.pop(context); // Listeyi kapat
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}