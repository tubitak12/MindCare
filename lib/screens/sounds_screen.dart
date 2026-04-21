import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoundsScreen extends StatelessWidget {
  final Function(String, String) onSoundTap;
  final String? playingTitle;

  const SoundsScreen({required this.onSoundTap, this.playingTitle, super.key});

  // Tam simetri sağlayan 6 ana kategori
  final List<Map<String, dynamic>> categories = const [
    {'title': 'Yağmur Sesleri', 'icon': Icons.umbrella, 'color': Colors.blue},
    {'title': 'Doğa Sesleri', 'icon': Icons.forest, 'color': Colors.green},
    {
      'title': 'Meditasyon',
      'icon': Icons.self_improvement,
      'color': Colors.purple
    },
    {
      'title': 'Gece & Uyku',
      'icon': Icons.nightlight_round,
      'color': Colors.indigo
    },
    {'title': 'Odaklanma', 'icon': Icons.psychology, 'color': Colors.orange},
    {'title': 'ASMR & Günlük', 'icon': Icons.coffee, 'color': Colors.brown},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      body: SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio:
                1.0, // Kutuları tam kare yaparak 6 taneyi sığdırdık
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final Color themeColor = cat['color'];

            return InkWell(
              onTap: () => _showSoundList(context, cat),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // İçerik beyaz
                  borderRadius: BorderRadius.circular(25),
                  // Kenarlık rengi ikon rengiyle aynı, hafif şeffaf
                  border:
                      Border.all(color: themeColor.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icon'], size: 45, color: themeColor),
                    const SizedBox(height: 12),
                    Text(
                      cat['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSoundList(BuildContext context, Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                category['title'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: category['color'],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sounds')
                      .where('category', isEqualTo: category['title'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError)
                      return const Center(child: Text("Hata oluştu"));
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final soundDocs = snapshot.data!.docs;
                    if (soundDocs.isEmpty) {
                      return const Center(
                          child: Text("Bu kategoride henüz ses yok."));
                    }

                    return ListView.builder(
                      itemCount: soundDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            soundDocs[index].data() as Map<String, dynamic>;
                        bool isPlaying = playingTitle == data['name'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isPlaying
                                ? category['color'].withOpacity(0.06)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Icon(
                              isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: category['color'],
                              size: 40,
                            ),
                            title: Text(
                              data['name'] ?? "İsimsiz Ses",
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(data['duration'] ?? "Rahatlatıcı"),
                            onTap: () {
                              onSoundTap(data['url'], data['name']);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
