import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ruh Halini Değerlendir',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kendini daha iyi tanımak için testleri çöz',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Firebase'den testleri çek
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('tests').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text('Hata: ${snapshot.error}'),
                    ],
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF72B01D)),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_late, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('Henüz test eklenmemiş',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 10),
                      Text('Firebase Cloud Firestore\'a test ekleyin',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                );
              }

              final tests = snapshot.data!.docs;
              return Column(
                children: tests.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildTestCard(
                      context,
                      data['emoji'] ?? '📝',
                      data['title'] ?? 'Test',
                      data['description'] ?? 'Açıklama',
                      '${data['questionCount'] ?? 0} soru • ${data['duration'] ?? '?'} dk',
                      doc.id,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context,
    String emoji,
    String title,
    String description,
    String duration,
    String testId,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7EE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.timer, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  duration,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF72B01D).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFF72B01D),
            size: 16,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TestDetailScreen(testId: testId, testTitle: title),
            ),
          );
        },
      ),
    );
  }
}

// Test detay sayfası
class TestDetailScreen extends StatefulWidget {
  final String testId;
  final String testTitle;

  const TestDetailScreen({
    super.key,
    required this.testId,
    required this.testTitle,
  });

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _questions = [];
  Map<int, String> _answers = {};
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _testStarted = false;
  bool _testCompleted = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await _firestore
          .collection('tests')
          .doc(widget.testId)
          .collection('questions')
          .orderBy('order')
          .get();

      _questions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'question': data['question'] ?? '',
          'options': List<String>.from(data['options'] ?? []),
          'order': data['order'] ?? 0,
        };
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Sorular yüklenirken hata: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _currentQuestionIndex = 0;
    });
  }

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_answers[_currentQuestionIndex] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir cevap seçin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _calculateScore();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _calculateScore() {
    int totalScore = 0;
    _answers.forEach((index, answer) {
      final options = _questions[index]['options'] as List;
      final optionIndex = options.indexOf(answer);
      if (optionIndex >= 0) {
        totalScore += optionIndex;
      }
    });

    _score = totalScore;
    _testCompleted = true;
  }

  String _getResultLevel() {
    final maxScore = _questions.length * 4;
    final percentage = (_score / maxScore) * 100;

    if (percentage <= 25) return 'Düşük';
    if (percentage <= 50) return 'Orta Altı';
    if (percentage <= 75) return 'Orta Üstü';
    return 'Yüksek';
  }

  void _saveResult() async {
    // Test sonucunu Firebase'e kaydet
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('test_results')
            .add({
          'testId': widget.testId,
          'testName': widget.testTitle,
          'score': _score,
          'maxScore': _questions.length * 4,
          'percentage': (_score / (_questions.length * 4)) * 100,
          'level': _getResultLevel(),
          'answers': _answers,
          'date': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test sonucunuz kaydedildi! 📊'),
          backgroundColor: Color(0xFF72B01D),
        ),
      );
    } catch (e) {
      print('Sonuç kaydedilirken hata: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sonuç kaydedilemedi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: const TextStyle(color: Color(0xFF1B4332)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF72B01D)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF72B01D)))
          : _questions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, size: 50, color: Colors.orange),
                      const SizedBox(height: 10),
                      const Text('Bu test için soru bulunamadı'),
                      const SizedBox(height: 10),
                      Text(
                        'Firebase\'de ${widget.testId} testine soru ekleyin',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : _testCompleted
                  ? _buildResultScreen()
                  : _testStarted
                      ? _buildQuestionScreen()
                      : _buildIntroScreen(),
    );
  }

  Widget _buildIntroScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF72B01D),
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.testTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bu test ${_questions.length} sorudan oluşmaktadır.',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              'Her soruyu dikkatlice okuyun ve size en uygun seçeneği işaretleyin.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startTest,
                child: const Text('Teste Başla'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final question = _questions[_currentQuestionIndex];
    final options = List<String>.from(question['options']);
    final selectedAnswer = _answers[_currentQuestionIndex];

    return Column(
      children: [
        // Progress
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Soru ${_currentQuestionIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                  Text(
                    '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}%',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF72B01D),
              ),
            ],
          ),
        ),

        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B4332),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ...options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final isSelected = selectedAnswer == option;

                  return GestureDetector(
                    onTap: () => _selectAnswer(option),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF72B01D).withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF72B01D)
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFF72B01D)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF72B01D)
                                    : Colors.grey,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF1B4332)
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Navigation Buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF72B01D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Önceki'),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    _currentQuestionIndex == _questions.length - 1
                        ? 'Bitir'
                        : 'Sonraki',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultScreen() {
    final maxScore = _questions.length * 4;
    final percentage = (_score / maxScore) * 100;
    final level = _getResultLevel();

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

    String resultMessage;
    if (percentage <= 25) {
      resultMessage =
          'Kendinize daha fazla zaman ayırın. İhtiyacınız olan desteği almayı unutmayın. 🌱';
    } else if (percentage <= 50) {
      resultMessage =
          'İyi gidiyorsunuz! Küçük adımlarla ilerlemeye devam edin. 🌿';
    } else if (percentage <= 75) {
      resultMessage = 'Çok iyi durumdasınız! Bu pozitif enerjinizi koruyun. ✨';
    } else {
      resultMessage =
          'Harika bir ruh halindesiniz! Bu enerjinizi sevdiklerinizle paylaşın. 🌟';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                percentage >= 70 ? Icons.emoji_emotions : Icons.analytics,
                color: levelColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Test Tamamlandı!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    '$_score / $maxScore',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '%${percentage.toInt()} Başarı',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        color: levelColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F7EE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                resultMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1B4332),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveResult,
                child: const Text('Sonuçları Kaydet ve Bitir'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Test Listesine Dön',
                style: TextStyle(color: Color(0xFF72B01D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
