import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorFocusGame extends StatefulWidget {
  const ColorFocusGame({super.key});

  @override
  State<ColorFocusGame> createState() => _ColorFocusGameState();
}

class _ColorFocusGameState extends State<ColorFocusGame> {
  final int baseGridSize = 4;
  int gridSize = 4;

  int score = 100;
  int level = 1;
  int targetIndex = 0;

  Color baseColor = Colors.blue;
  Color differentColor = Colors.blue;

  final Random random = Random();

  final List<Color> softColors = [
    const Color(0xFFA8D5BA),
    const Color(0xFFBFD8D2),
    const Color(0xFFD6EADF),
    const Color(0xFFE2ECE9),
    const Color(0xFFB5C9E2),
    const Color(0xFFC9D6EA),
    const Color(0xFFEADBC8),
    const Color(0xFFF3E9DC),
    const Color(0xFFDAD2BC),
  ];

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    // Her 8 seviyeden sonra grid boyutu artar (max 6x6)
    gridSize = baseGridSize + (level ~/ 8);
    if (gridSize > 6) gridSize = 6;

    int total = gridSize * gridSize;
    targetIndex = random.nextInt(total);

    baseColor = getRandomColor();
    differentColor = getSlightlyDifferentColor(baseColor);
  }

  Color getRandomColor() {
    return softColors[random.nextInt(softColors.length)];
  }

  Color getSlightlyDifferentColor(Color base) {
    // Seviye arttıkça fark küçülüyor ama yavaş ve kademeli
    // 50'den başlayıp her 3 seviyede 1 azalıyor, minimum 8
    int diff = max(8, 50 - (level ~/ 3));

    int r = (base.red + random.nextInt(diff) - diff ~/ 2).clamp(0, 255);
    int g = (base.green + random.nextInt(diff) - diff ~/ 2).clamp(0, 255);
    int b = (base.blue + random.nextInt(diff) - diff ~/ 2).clamp(0, 255);

    return Color.fromARGB(255, r, g, b);
  }

  void onTap(int index) {
    if (index == targetIndex) {
      setState(() {
        level++;
        startGame();
      });
    } else {
      HapticFeedback.mediumImpact();

      setState(() {
        score -= 10;
        if (score < 0) score = 0;
      });

      if (score <= 0) {
        showGameOver();
      }
    }
  }

  // ⭐ GELİŞTİRİLMİŞ GAME OVER
  void showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 65,
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              const Text(
                "Oyun Bitti",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Skorun: $score",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Seviye: $level",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          score = 100;
                          level = 1;
                          startGame();
                        });
                      },
                      child: const Text(
                        "Yeniden Başla",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF10B981),
                          width: 2,
                        ),
                        foregroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Çık",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = gridSize * gridSize;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Farklı Rengi Bul"),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            "⭐ Skor: $score | Level: $level",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: total,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: index == targetIndex
                            ? differentColor
                            : baseColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}