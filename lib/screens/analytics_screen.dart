import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedFilter = 'Tümü'; // Tümü, Son 7 Gün, Son 30 Gün

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Center(
        child: Text('Lütfen giriş yapın'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analiz ve Raporlar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Test sonuçlarınız ve ruh hali analiziniz',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Filtre butonları
          _buildFilterButtons(),
          const SizedBox(height: 20),

          // İstatistik kartları
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('users')
                .doc(userId)
                .collection('test_results')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Hata: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF72B01D)),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final results = snapshot.data!.docs;
              final filteredResults = _filterResults(results);

              if (filteredResults.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Bu dönemde test sonucu bulunamadı'),
                  ),
                );
              }

              return Column(
                children: [
                  // İstatistik özet kartları
                  _buildStatsCards(filteredResults),
                  const SizedBox(height: 24),

                  // Sonuçlar listesi
                  const Text(
                    'Test Geçmişi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...filteredResults.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildResultCard(data);
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = ['Tümü', 'Son 7 Gün', 'Son 30 Gün'];
    return Row(
      children: filters.map((filter) {
        final isSelected = _selectedFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FilterChip(
            label: Text(filter),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              }
            },
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF72B01D).withValues(alpha: 0.2),
            checkmarkColor: const Color(0xFF72B01D),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF72B01D) : Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  List<QueryDocumentSnapshot> _filterResults(
      List<QueryDocumentSnapshot> results) {
    if (_selectedFilter == 'Tümü') return results;

    final now = DateTime.now();
    final days = _selectedFilter == 'Son 7 Gün' ? 7 : 30;
    final cutoff = now.subtract(Duration(days: days));

    return results.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      return date.isAfter(cutoff);
    }).toList();
  }

  Widget _buildStatsCards(List<QueryDocumentSnapshot> results) {
    int totalTests = results.length;
    double totalScore = 0;
    double totalPercentage = 0;
    Map<String, int> levelCounts = {};

    for (var doc in results) {
      final data = doc.data() as Map<String, dynamic>;
      totalScore += (data['score'] ?? 0).toDouble();
      totalPercentage += (data['percentage'] ?? 0).toDouble();
      String level = data['level'] ?? 'Belirsiz';
      levelCounts[level] = (levelCounts[level] ?? 0) + 1;
    }

    final avgScore = totalTests > 0 ? (totalScore / totalTests).round() : 0;
    final avgPercentage =
        totalTests > 0 ? (totalPercentage / totalTests).round() : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Toplam Test', '$totalTests', Icons.assignment_turned_in),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Ortalama Puan', '$avgScore', Icons.show_chart),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard('Başarı', '$avgPercentage%', Icons.percent),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF72B01D), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> data) {
    final date = (data['date'] as Timestamp).toDate();
    final testName = data['testName'] ?? 'Test';
    final score = data['score'] ?? 0;
    final maxScore = data['maxScore'] ?? 0;
    final percentage = data['percentage'] ?? 0;
    final level = data['level'] ?? 'Belirsiz';

    Color levelColor;
    if (level == 'Yüksek') {
      levelColor = const Color(0xFF72B01D);
    } else if (level == 'Orta Üstü') {
      levelColor = Colors.blue;
    } else if (level == 'Orta Altı') {
      levelColor = Colors.orange;
    } else {
      levelColor = Colors.redAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  testName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4332),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  level,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd MMMM yyyy', 'tr').format(date),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.star, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '$score / $maxScore ($percentage%)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: levelColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz test sonucu yok',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Testler sekmesinden bir test çözerek başlayın',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Testler sekmesine yönlendir
                // HomeScreen'de index 2'ye gitmek için
                Navigator.pop(context); // Önce analizden çık
                // Ana sayfada testler sekmesine git
              },
              child: const Text('Testlere Git'),
            ),
          ],
        ),
      ),
    );
  }
}
