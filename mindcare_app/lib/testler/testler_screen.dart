import 'package:flutter/material.dart';

class TestlerScreen extends StatelessWidget {
  const TestlerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tests = const [
      {
        'title': 'Anksiyete Testi',
        'subtitle': 'GAD‑7 anksiyete değerlendirme ölçeği',
        'icon': Icons.psychology,
        'color': Color(0xFF4A148C)
      },
      {
        'title': 'Depresyon Testi',
        'subtitle': 'PHQ‑9 depresyon değerlendirme ölçeği',
        'icon': Icons.favorite,
        'color': Color(0xFFD81B60)
      },
      {
        'title': 'Stres Seviyesi',
        'subtitle': 'Günlük stres düzeyi değerlendirmesi',
        'icon': Icons.whatshot,
        'color': Color(0xFFFF6F00)
      },
      {
        'title': 'İyi Olma Hali',
        'subtitle': 'Genel yaşam memnuniyeti ölçeği',
        'icon': Icons.sentiment_satisfied,
        'color': Color(0xFF2E7D32)
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Testler'),
        backgroundColor: const Color(0xFF7B61FF),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tests.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == tests.length) {
            // Alt not kutusu
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Önemli Not\n\n'
                'Bu testler sadece bilgilendirme amaçlıdır ve profesyonel '
                'bir tanı yerine geçmez. Ciddi semptomlar yaşıyorsanız '
                'lütfen bir uzmanla görüşün.',
                style: TextStyle(color: Colors.black87),
              ),
            );
          }
          final t = tests[index];
          return Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: t['color'] as Color,
                child: Icon(t['icon'] as IconData, color: Colors.white),
              ),
              title: Text(t['title'] as String),
              subtitle: Text(t['subtitle'] as String),
              onTap: () {
                // test ekranına geçiş ekle
              },
            ),
          );
        },
      ),
    );
  }
}