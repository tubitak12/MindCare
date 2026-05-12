import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tests_screen.dart';

class TestsCategoryScreen extends StatelessWidget {
  const TestsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(0),
        child: SizedBox(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              final data = category.data() as Map<String, dynamic>;

              final String id = category.id;
              final String name = data['name'] ?? 'Kategori';
              final String description = data['description'] ?? '';
              final String iconName = data['icon'] ?? 'spa';
              final Color color = Color(int.parse(
                  data['color']?.toString().replaceAll('0x', '0xFF') ??
                      '0xFF10B981'));

              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('tests')
                    .where('categoryId', isEqualTo: id)
                    .get(),
                builder: (context, testSnap) {
                  final testCount =
                      testSnap.hasData ? testSnap.data!.docs.length : 0;

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestsScreen(
                              categoryId: id,
                              categoryName: name,
                              // ✅ Hata veren parametreler kaldırıldı
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(20),
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
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  _getIcon(iconName),
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
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
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
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.assignment_outlined,
                                            size: 14,
                                            color: Color(0xFF10B981),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '$testCount Test',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ],
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
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'psychology':
        return Icons.psychology;
      case 'cloud':
        return Icons.cloud;
      case 'people':
        return Icons.people;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'bedtime':
        return Icons.bedtime;
      case 'spa':
        return Icons.spa;
      default:
        return Icons.spa;
    }
  }
}
