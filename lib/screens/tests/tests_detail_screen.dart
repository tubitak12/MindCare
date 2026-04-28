import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tests_result_screen.dart';

class TestsDetailScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final Color testColor;
  final String testColorHex;
  final String categoryId;

  const TestsDetailScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    required this.testColor,
    required this.testColorHex,
    required this.categoryId,
  });

  @override
  State<TestsDetailScreen> createState() => _TestsDetailScreenState();
}

class _TestsDetailScreenState extends State<TestsDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _questions = [];
  final Map<int, int> _answers = {};
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
      setState(() => _isLoading = false);
      debugPrint('Sorular yüklenirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorular yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _startTest() {
    setState(() {
      _testStarted = true;
      _currentQuestionIndex = 0;
      _answers.clear();
    });
  }

  void _selectAnswer(int score) {
    setState(() {
      _answers[_currentQuestionIndex] = score;
    });
  }

  void _nextQuestion() {
    if (!_answers.containsKey(_currentQuestionIndex)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir cevap seçin'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 1),
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
    _answers.forEach((index, score) {
      totalScore += score;
    });
    _score = totalScore;
    _testCompleted = true;
    _saveAndNavigateToResult();
  }

  Future<void> _saveAndNavigateToResult() async {
    await _saveResult();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestsResultScreen(
          testId: widget.testId,
          testName: widget.testTitle,
          score: _score,
          maxScore: _questions.length * 3,
          answers: _answers,
          testColor: widget.testColor,
          categoryId: widget.categoryId,
        ),
      ),
    );
  }

  Future<void> _saveResult() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        final maxScore = _questions.length * 3;
        final percentage = maxScore > 0 ? (_score / maxScore) * 100 : 0;
        final level = _getResultLevel();

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('test_results')
            .add({
          'testId': widget.testId,
          'testName': widget.testTitle,
          'categoryId': widget.categoryId,
          'score': _score,
          'maxScore': maxScore,
          'percentage': percentage,
          'level': level,
          'answers': _answers,
          'date': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Sonuç kaydedilirken hata: $e');
    }
  }

  String _getResultLevel() {
    final maxScore = _questions.length * 3;
    if (maxScore == 0) return 'Belirsiz';

    final percentage = (_score / maxScore) * 100;

    switch (widget.categoryId) {
      case 'anxiety':
        if (_score <= 4) return 'Minimal Anksiyete';
        if (_score <= 9) return 'Hafif Anksiyete';
        if (_score <= 14) return 'Orta Anksiyete';
        return 'Şiddetli Anksiyete';

      case 'depression':
        if (_score <= 4) return 'Minimal Depresyon';
        if (_score <= 9) return 'Hafif Depresyon';
        if (_score <= 14) return 'Orta Depresyon';
        if (_score <= 19) return 'Orta-Şiddetli Depresyon';
        return 'Şiddetli Depresyon';

      case 'stress':
        if (_score <= 13) return 'Düşük Stres';
        if (_score <= 26) return 'Orta Stres';
        return 'Yüksek Stres';

      case 'wellbeing':
        if (percentage >= 70) return 'Yüksek İyi Olma Hali';
        if (percentage >= 50) return 'Orta İyi Olma Hali';
        return 'Düşük İyi Olma Hali';

      default:
        if (percentage >= 70) return 'Yüksek';
        if (percentage >= 50) return 'Orta';
        return 'Düşük';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: const TextStyle(color: Color(0xFF064E3B)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.testColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : _questions.isEmpty
              ? _buildEmptyState()
              : _testCompleted
                  ? const SizedBox()
                  : _testStarted
                      ? _buildQuestionScreen()
                      : _buildIntroScreen(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning, size: 60, color: Colors.orange.shade300),
          const SizedBox(height: 16),
          const Text(
            'Bu test için soru bulunamadı',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Lütfen daha sonra tekrar deneyin',
            style: TextStyle(color: const Color(0xFF6B7280)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.testColor,
            ),
            child: const Text('Geri Dön'),
          ),
        ],
      ),
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
                boxShadow: [
                  BoxShadow(
                    color: widget.testColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.assignment,
                color: widget.testColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              widget.testTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF064E3B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: widget.testColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_questions.length} Soru',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.testColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Her soruyu dikkatlice okuyun ve size en uygun seçeneği işaretleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF6B7280), height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Cevaplarınız gizli tutulacaktır.',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 12),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.testColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Teste Başla',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    if (_questions.isEmpty) return const SizedBox();

    final question = _questions[_currentQuestionIndex];
    final options = List<String>.from(question['options']);
    final selectedAnswer = _answers[_currentQuestionIndex];

    return Column(
      children: [
        // Progress Bar
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
                      color: Color(0xFF064E3B),
                    ),
                  ),
                  Text(
                    '${((_currentQuestionIndex + 1) / _questions.length * 100).toInt()}%',
                    style: const TextStyle(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // DÜZELTİLDİ: height yerine minHeight kullanıldı
              SizedBox(
                height: 8,
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey.shade200,
                  color: widget.testColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),

        // Soru ve Cevaplar
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soru Kartı
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF064E3B),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Cevaplar
                const Text(
                  'Size en uygun seçeneği işaretleyin',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                ...options.asMap().entries.map((entry) {
                  final option = entry.value;
                  final optionIndex = entry.key;
                  final isSelected = selectedAnswer == optionIndex;

                  String scoreText = '';
                  if (optionIndex == 0) {
                    scoreText = ' (0 puan)';
                  } else if (optionIndex == 1) {
                    scoreText = ' (1 puan)';
                  } else if (optionIndex == 2) {
                    scoreText = ' (2 puan)';
                  } else if (optionIndex == 3) {
                    scoreText = ' (3 puan)';
                  }

                  return GestureDetector(
                    onTap: () => _selectAnswer(optionIndex),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.testColor.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? widget.testColor
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      widget.testColor.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  isSelected ? widget.testColor : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? widget.testColor
                                    : Colors.grey.shade400,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              option + scoreText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected
                                    ? widget.testColor
                                    : const Color(0xFF064E3B),
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

        // Navigasyon Butonları
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_currentQuestionIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: widget.testColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 4),
                        Text('Önceki'),
                      ],
                    ),
                  ),
                ),
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              Expanded(
                flex: _currentQuestionIndex > 0 ? 2 : 1,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.testColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentQuestionIndex == _questions.length - 1
                            ? 'Testi Bitir'
                            : 'Sonraki',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentQuestionIndex != _questions.length - 1)
                        const SizedBox(width: 4),
                      if (_currentQuestionIndex != _questions.length - 1)
                        const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
