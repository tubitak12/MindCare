import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tests_screen.dart';

class TestsCategoryScreen extends StatefulWidget {
  const TestsCategoryScreen({super.key});

  @override
  State<TestsCategoryScreen> createState() => _TestsCategoryScreenState();
}

class _TestsCategoryScreenState extends State<TestsCategoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await _firestore.collection('categories').get();

      print('Kategori sayısı: ${snapshot.docs.length}'); // DEBUG

      if (snapshot.docs.isEmpty) {
        setState(() {
          _errorMessage =
              'Henüz kategori eklenmemiş. Firebase konsolundan kategori ekleyin.';
          _isLoading = false;
        });
        return;
      }

      final categories = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Kategori',
          'description': data['description'] ?? '',
          'icon': data['icon'] ?? 'Icons.psychology',
          'color': data['color'] ?? '0xFF72B01D',
          'order': data['order'] ?? 0,
        };
      }).toList();

      categories
          .sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('HATA: $e'); // DEBUG
      setState(() {
        _errorMessage =
            'Bağlantı hatası: $e\n\nFirebase kurallarını kontrol edin.';
        _isLoading = false;
      });
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'Icons.psychology':
        return Icons.psychology;
      case 'Icons.cloud':
        return Icons.cloud;
      case 'Icons.flash_on':
        return Icons.flash_on;
      case 'Icons.star':
        return Icons.star;
      case 'Icons.favorite':
        return Icons.favorite;
      case 'Icons.bedtime':
        return Icons.bedtime;
      default:
        return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ruh Halini Değerlendir',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kendini daha iyi tanımak için bir kategori seç',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF72B01D)),
            SizedBox(height: 16),
            Text('Kategoriler yükleniyor...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadCategories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF72B01D),
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Henüz kategori eklenmemiş'),
            SizedBox(height: 8),
            Text('Firebase konsolundan kategori ekleyin'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final Color categoryColor = Color(
            int.parse(category['color']),
          );
          final IconData icon = _getIconData(category['icon']);

          return _buildCategoryCard(
            icon: icon,
            name: category['name'],
            description: category['description'],
            color: categoryColor,
            categoryId: category['id'],
            categoryName: category['name'],
            categoryColorHex: category['color'],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String name,
    required String description,
    required Color color,
    required String categoryId,
    required String categoryName,
    required String categoryColorHex,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TestsScreen(
              categoryId: categoryId,
              categoryName: categoryName,
              categoryColor: color,
              categoryColorHex: categoryColorHex,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 36,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
