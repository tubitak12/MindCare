import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tests_result_screen.dart';

class TestsDetailScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final Color themeColor;
  final String categoryId;

  const TestsDetailScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    required this.themeColor,
    required this.categoryId,
  });

  @override
  State<TestsDetailScreen> createState() => _TestsDetailScreenState();
}

class _TestsDetailScreenState extends State<TestsDetailScreen> {
  bool showInfo = true;
  int currentIndex = 0;
  int score = 0;
  List<int?> selectedAnswers = [];
  Map<int, int> answersMap = {};

  @override
  Widget build(BuildContext context) {
    if (showInfo) {
      return _buildInfoScreen();
    }
    return _buildTestScreen();
  }

  // ========== BİLGİLENDİRME EKRANI (Taşma Hatası Düzeltildi) ==========
  Widget _buildInfoScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.themeColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('tests')
            .doc(widget.testId)
            .collection('questions')
            .orderBy('order')
            .get(),
        builder: (context, snapshot) {
          final int questionCount =
              snapshot.hasData ? snapshot.data!.docs.length : 0;

          return SingleChildScrollView(
            // Overflow hatasını önleyen ana yapı
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: widget.themeColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.assignment_turned_in,
                      size: 64,
                      color: widget.themeColor,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    widget.testTitle,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline, color: widget.themeColor),
                            const SizedBox(width: 12),
                            Text(
                              '$questionCount Soru',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: widget.themeColor),
                            const SizedBox(width: 12),
                            Text(
                              'Yaklaşık ${questionCount * 2} dakika',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '📝 Test Hakkında',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bu test, ruh sağlığınızı değerlendirmenize yardımcı olacaktır.\n\n'
                          '• Her soruyu dikkatlice okuyun\n'
                          '• Size en uygun seçeneği işaretleyin\n'
                          '• Cevaplarınız gizli tutulacaktır\n\n'
                          'Sonuçlarınız bir uzman değerlendirmesi değildir.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Spacer yerine sabit boşluk
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          showInfo = false;
                        });
                      },
                      child: const Text(
                        'Teste Başla',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: widget.themeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Geri Dön',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.themeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========== TEST EKRANI ==========
  Widget _buildTestScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: widget.themeColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tests')
            .doc(widget.testId)
            .collection('questions')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Hata: ${snapshot.error}'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final questions = snapshot.data!.docs;
          if (questions.isEmpty)
            return const Center(child: Text('Soru bulunamadı.'));

          if (selectedAnswers.isEmpty) {
            selectedAnswers = List<int?>.filled(questions.length, null);
          }

          final qData = questions[currentIndex].data() as Map<String, dynamic>;
          final String questionText = qData['question'] ?? 'Soru yüklenemedi';
          final List<String> options =
              List<String>.from(qData['options'] ?? []);
          final int? currentSelected = selectedAnswers[currentIndex];

          return Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (currentIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                color: widget.themeColor,
                minHeight: 6,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Soru ${currentIndex + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.themeColor,
                        ),
                      ),
                    ),
                    Text(
                      '/ ${questions.length}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFF10B981), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questionText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF064E3B),
                          ),
                        ),
                        const Divider(height: 32),
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, optIndex) {
                              final isSelected = currentSelected == optIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAnswers[currentIndex] = optIndex;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? widget.themeColor.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? widget.themeColor
                                          : const Color(0xFFD1FAE5),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: isSelected
                                            ? widget.themeColor
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          options[optIndex],
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isSelected
                                                ? widget.themeColor
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () {
                      if (selectedAnswers[currentIndex] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Lütfen bir cevap seçin')),
                        );
                        return;
                      }

                      answersMap[currentIndex] = selectedAnswers[currentIndex]!;

                      // Puanlama mantığı (Eğer correctOptionIndex varsa)
                      final int correctIndex =
                          qData['correctOptionIndex'] ?? -1;
                      if (correctIndex != -1 &&
                          selectedAnswers[currentIndex] == correctIndex) {
                        score++;
                      }

                      if (currentIndex < questions.length - 1) {
                        setState(() {
                          currentIndex++;
                        });
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestsResultScreen(
                              testId: widget.testId,
                              testName: widget.testTitle,
                              score: score,
                              maxScore: questions.length,
                              answers: answersMap,
                              testColor: widget.themeColor,
                              categoryId: widget.categoryId,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      currentIndex == questions.length - 1
                          ? 'Testi Bitir'
                          : 'Sonraki Soru',
                      style: const TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
