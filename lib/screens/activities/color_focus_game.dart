import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorFocusGame extends StatefulWidget {
  const ColorFocusGame({super.key});

  @override
  State<ColorFocusGame> createState() => _ColorFocusGameState();
}

class _ColorFocusGameState extends State<ColorFocusGame> {
  final int gridSize = 4;

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
    int total = gridSize * gridSize;
    targetIndex = random.nextInt(total);

    baseColor = getRandomColor();
    differentColor = getSlightlyDifferentColor(baseColor);
  }

  Color getRandomColor() {
    return softColors[random.nextInt(softColors.length)];
  }

  Color getSlightlyDifferentColor(Color base) {
    int diff = max(8, 50 - (level ~/ 2));

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emoji_events_outlined,
                size: 60,
                color: Colors.orange,
              ),
              const SizedBox(height: 10),

              const Text(
                "Oyun Bitti",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Skorun: $score",
                style: const TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    score = 100;
                    level = 1;
                    startGame();
                  });
                },
                child: const Text("Yeniden Başla"),
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
      appBar: AppBar(
        title: const Text("Farklı Rengi Bul"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Text(
            "⭐ Skor: $score | Level: $level",
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 10),

          // 🔥 GRID'E NEFES ALDIRDIK
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0), // 👈 kenarlardan boşluk
              child: GridView.builder(
                itemCount: total,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: index == targetIndex
                            ? differentColor
                            : baseColor,
                        borderRadius: BorderRadius.circular(10),
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