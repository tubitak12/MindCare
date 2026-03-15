import 'package:flutter/material.dart';
import '../services/tests_service.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  final TestsService _testsService = TestsService();
  List<Map<String, dynamic>> _testList = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  Future<void> _loadTestData() async {
    List<Map<String, dynamic>> tests = await _testsService.getAllTests();
    setState(() {
      _testList = tests;
      _isLoadingData = false;
    });
  }

  IconData _getIconForName(String iconName) {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology;
      case 'favorite':
        return Icons.favorite;
      case 'whatshot':
        return Icons.whatshot;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorFromString(String colorString) {
    try {
      return Color(int.parse(colorString));
    } catch (e) {
      return const Color(0xFF7B61FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Testler'),
        backgroundColor: const Color(0xFF7B61FF),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _testList.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, position) {
                if (position == _testList.length) {
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

                final currentTest = _testList[position];
                return Material(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _getColorFromString(currentTest['color']),
                      child: Icon(_getIconForName(currentTest['icon']),
                          color: Colors.white),
                    ),
                    title: Text(currentTest['title']),
                    subtitle: Text(currentTest['subtitle']),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DynamicTestScreen(
                            testId: currentTest['id'],
                            testTitle: currentTest['title'],
                            testType: currentTest['type'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class DynamicTestScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final String testType;

  const DynamicTestScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    required this.testType,
  });

  @override
  State<DynamicTestScreen> createState() => _DynamicTestScreenState();
}

class _DynamicTestScreenState extends State<DynamicTestScreen> {
  final TestsService _testsService = TestsService();
  List<Map<String, dynamic>> _questionList = [];
  List<int?> _answerList = [];
  int _currentQuestionIndex = 0;
  bool _isLoadingQuestions = true;

  @override
  void initState() {
    super.initState();
    _loadQuestionData();
  }

  Future<void> _loadQuestionData() async {
    List<Map<String, dynamic>> questions =
        await _testsService.getTestQuestions(widget.testId);
    setState(() {
      _questionList = questions;
      _answerList = List<int?>.filled(questions.length, null);
      _isLoadingQuestions = false;
    });
  }

  String _getLevelFromScore(int score) {
    switch (widget.testType) {
      case 'anxiety':
        return TestsService.getAnxietyLevel(score);
      case 'depression':
        return TestsService.getDepressionLevel(score);
      case 'stress':
        return TestsService.getStressLevel(score);
      case 'wellbeing':
        return TestsService.getWellbeingLevel(score);
      default:
        return 'Değerlendirildi';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingQuestions) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: AppBar(
          title: Text(widget.testTitle),
          backgroundColor: const Color(0xFF7B61FF),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questionList.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: AppBar(
          title: Text(widget.testTitle),
          backgroundColor: const Color(0xFF7B61FF),
        ),
        body: const Center(
          child: Text('Bu test için soru bulunamadı.'),
        ),
      );
    }

    final currentQuestion = _questionList[_currentQuestionIndex];
    final optionList = List<String>.from(currentQuestion['options']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: Text(widget.testTitle),
        backgroundColor: const Color(0xFF7B61FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questionList.length,
              backgroundColor: Colors.grey[300],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
            ),
            const SizedBox(height: 20),
            Text(
              'Soru ${_currentQuestionIndex + 1}/${_questionList.length}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              currentQuestion['question'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ...List.generate(optionList.length, (index) {
              return RadioListTile<int>(
                title: Text(optionList[index]),
                value: index,
                groupValue: _answerList[_currentQuestionIndex],
                onChanged: (value) {
                  setState(() {
                    _answerList[_currentQuestionIndex] = value;
                  });
                },
                activeColor: const Color(0xFF7B61FF),
              );
            }),
            const Spacer(),
            Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Geri'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _answerList[_currentQuestionIndex] != null
                        ? () {
                            if (_currentQuestionIndex <
                                _questionList.length - 1) {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            } else {
                              _showResultDialog();
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_currentQuestionIndex < _questionList.length - 1
                        ? 'İleri'
                        : 'Bitir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog() {
    int totalScore = _answerList.fold(0, (sum, item) => sum + (item ?? 0));
    String level = _getLevelFromScore(totalScore);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Sonucu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Toplam Puan: $totalScore'),
            const SizedBox(height: 10),
            Text(
              level,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _testsService.saveTestResult(
                testId: widget.testId,
                testName: widget.testTitle,
                score: totalScore,
                level: level,
                answers: {'answers': _answerList},
              );

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sonuç kaydedildi!')),
                );
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
