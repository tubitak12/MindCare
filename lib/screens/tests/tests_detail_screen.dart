import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'tests_result_screen.dart';

class TestsDetailScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final String categoryId;

  const TestsDetailScreen({
    super.key,
    required this.testId,
    required this.testTitle,
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

  final Color primaryGreen = const Color(0xFF10B981);
  final Color darkText = const Color(0xFF064E3B);
  final Color mintBg = const Color(0xFFD1FAE5);

  // Bitki emojisini ilerlemeye göre belirleyen yardımcı fonksiyon
  String _getPlantEmoji(double progress) {
    if (progress < 0.2) return '🌱'; // Filiz
    if (progress < 0.4) return '🌿'; // Yapraklanma
    if (progress < 0.6) return '🪴'; // Büyüme
    if (progress < 0.8) return '🌳'; // Ağaçlanma
    return '🌸'; // Çiçek açma (Son aşama)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: showInfo ? _buildInfoView() : _buildQuestionView(),
    );
  }

  Widget _buildInfoView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 80, color: primaryGreen),
          const SizedBox(height: 24),
          Text(
            "Test Hakkında",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Bu test, ruh halinizi daha iyi anlamanıza yardımcı olmak için tasarlanmıştır. Lütfen sorulara samimiyetle cevap verin.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], height: 1.5),
          ),
          const SizedBox(height: 40),
          _buildBtn("Teste Başla", () => setState(() => showInfo = false)),
        ],
      ),
    );
  }

  Widget _buildQuestionView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tests')
          .doc(widget.testId)
          .collection('questions')
          .orderBy('order')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final questions = snapshot.data!.docs;
        if (selectedAnswers.isEmpty) {
          selectedAnswers = List.filled(questions.length, null);
        }

        final qData = questions[currentIndex].data() as Map<String, dynamic>;
        final List<String> options = List<String>.from(qData['options'] ?? []);

        // İlerleme yüzdesi (0.0 ile 1.0 arasında)
        final double progress = (currentIndex + 1) / questions.length;

        return Column(
          children: [
            // --- YENİ EKLENEN BİTKİ ANİMASYONU ALANI ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              color: Colors.white.withOpacity(0.5),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          // Ölçekleme (büyüme) animasyonu
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                    child: Text(
                      _getPlantEmoji(progress),
                      key: ValueKey<String>(_getPlantEmoji(progress)),
                      style: const TextStyle(fontSize: 55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "İyileşme yolculuğun devam ediyor...",
                    style: TextStyle(
                      color: primaryGreen.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // -------------------------------------------
            LinearProgressIndicator(
              value: progress,
              color: primaryGreen,
              backgroundColor: mintBg,
              minHeight: 6,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    "Soru ${currentIndex + 1}/${questions.length}",
                    style: TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    qData['question'] ?? '',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ...List.generate(
                    options.length,
                    (i) => _buildOption(options[i], i),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildBtn(
                currentIndex == questions.length - 1
                    ? "Sonuçları Gör"
                    : "İleri",
                () {
                  if (selectedAnswers[currentIndex] == null) return;

                  answersMap[currentIndex] = selectedAnswers[currentIndex]!;

                  if (currentIndex < questions.length - 1) {
                    setState(() => currentIndex++);
                  } else {
                    _finishTest(questions.length);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOption(String text, int index) {
    bool isSelected = selectedAnswers[currentIndex] == index;
    return GestureDetector(
      onTap: () => setState(() => selectedAnswers[currentIndex] = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? mintBg : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? primaryGreen : mintBg),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: darkText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _finishTest(int total) {
    int finalScore = 0;
    for (var answer in selectedAnswers) {
      if (answer != null) {
        finalScore += answer;
      }
    }

    int maxScore = total * 3;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TestsResultScreen(
          testId: widget.testId,
          testName: widget.testTitle,
          score: finalScore,
          maxScore: maxScore,
          answers: answersMap,
          testColor: primaryGreen,
          categoryId: widget.categoryId,
        ),
      ),
    );
  }

  Widget _buildBtn(String label, VoidCallback tap) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: tap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}