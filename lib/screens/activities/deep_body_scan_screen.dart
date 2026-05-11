import 'dart:async';
import 'package:flutter/material.dart';

class DeepBodyScanScreen extends StatefulWidget {
  final int totalDuration;

  const DeepBodyScanScreen({
    super.key,
    required this.totalDuration,
  });

  @override
  State<DeepBodyScanScreen> createState() => _DeepBodyScanScreenState();
}

class _DeepBodyScanScreenState extends State<DeepBodyScanScreen> {
  int currentStep = 0;
  bool isWaitingPause = false;
  bool _sessionStarted = false;
  bool _isInTransition = false;
  bool _isPaused = false;

  late Timer timer;
  Timer? _transitionTimer;
  late int remainingSeconds;
  late int stepDuration;
  late int stepSecondsLeft;
  final int pauseDuration = 2;

  // Renk paleti (color_focus_game'den uyarlandı)
  final List<Color> bodyColors = [
    const Color(0xFFA8D5BA), // Açık yeşil
    const Color(0xFFBFD8D2), // Gri-yeşil
    const Color(0xFFD6EADF), // Çok açık yeşil
    const Color(0xFFB5C9E2), // Açık mavi
    const Color(0xFFC9D6EA), // Mavi-gri
    const Color(0xFFEADBC8), // Krem
    const Color(0xFFF3E9DC), // Açık kahve
    const Color(0xFFDAD2BC), // Gri-kahve
    const Color(0xFFD1C9B8), // Taupe
    const Color(0xFFC8D7E0), // Buz mavi
    const Color(0xFFD9E0D5), // Açık haki
    const Color(0xFFE5D9D0), // Açık terracotta
    const Color(0xFFF0E8DE), // Çok açık beyaz
  ];

  final List<Map<String, String>> steps = [
    {"title": "Ayak Parmakları", "desc": "Karıncalanma veya sıcaklığı fark et"},
    {"title": "Ayak Tabanı", "desc": "Zemine temas hissini gözlemle"},
    {"title": "Topuk", "desc": "Basıncı hisset"},
    {"title": "Baldır", "desc": "Kaslarını gözlemle"},
    {"title": "Diz", "desc": "İç hareketleri fark et"},
    {"title": "Uyluk", "desc": "Yoğunluğu hisset"},
    {"title": "Karın", "desc": "İç hareketleri fark et"},
    {"title": "Göğüs", "desc": "Genişleme hissini gözlemle"},
    {"title": "Omuz", "desc": "Gerginliği bırak"},
    {"title": "Boyun", "desc": "Yumuşamayı hisset"},
    {"title": "Çene", "desc": "Sıkılıysa gevşet"},
    {"title": "Gözler", "desc": "Kasları serbest bırak"},
    {"title": "Alın", "desc": "Tüm yüzü gevşet"},
  ];

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.totalDuration;
    _calculateStepDuration();
  }

  void _calculateStepDuration() {
    // Başlangıçta daha fazla süre, sonra azalarak ilerle
    // Her adımın süresi biraz daha kısa olacak
    stepDuration = ((widget.totalDuration / steps.length) - pauseDuration).floor();
    if (stepDuration < 2) stepDuration = 2;
    stepSecondsLeft = stepDuration;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _isPaused) return;

      if (remainingSeconds <= 0) {
        t.cancel();
        showFinishDialog();
        return;
      }

      setState(() {
        remainingSeconds--;
        stepSecondsLeft--;
      });

      if (stepSecondsLeft <= 0) {
        if (isWaitingPause) {
          if (currentStep < steps.length - 1) {
            setState(() {
              _isInTransition = true;
            });
            timer.cancel();
            _transitionTimer = Timer(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _isInTransition = false;
                  currentStep++;
                  // Her adımda süre biraz azal
                  int newDuration =
                      ((widget.totalDuration - remainingSeconds) / (currentStep + 1))
                          .floor();
                  stepDuration = (newDuration - pauseDuration).clamp(2, 10);
                  stepSecondsLeft = stepDuration;
                  isWaitingPause = false;
                });
                startTimer();
              }
            });
          } else {
            t.cancel();
            showFinishDialog();
          }
        } else {
          if (currentStep < steps.length - 1) {
            setState(() {
              isWaitingPause = true;
              stepSecondsLeft = pauseDuration;
            });
          } else {
            t.cancel();
            showFinishDialog();
          }
        }
      }
    });
  }

  void showFinishDialog() {
    if (!mounted) return;

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
                Icons.spa_rounded,
                size: 60,
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 16),
              const Text(
                "Seans Tamamlandı",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064E3B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Kendini nasıl hissediyorsun?",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        restart();
                      },
                      child: const Text(
                        "Tekrar Başla",
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Çık"),
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

  void restart() {
    timer.cancel();
    _transitionTimer?.cancel();
    setState(() {
      currentStep = 0;
      isWaitingPause = false;
      _sessionStarted = false;
      _isPaused = false;
      remainingSeconds = widget.totalDuration;
      _calculateStepDuration();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _transitionTimer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    final statusText = isWaitingPause ? 'Kısa mola' : 'Bu bölgeye odaklan';

    String centerText;
    if (!_sessionStarted) {
      centerText = formatTime(widget.totalDuration);
    } else if (_isInTransition) {
      centerText = currentStep < steps.length - 1
          ? 'Sonraki: ${steps[currentStep + 1]["title"]}'
          : 'Bitiş';
    } else {
      centerText = formatTime(remainingSeconds);
    }

    Color currentColor = bodyColors[currentStep % bodyColors.length];

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        title: const Text("Vücut Taraması - Anı Yaşama Pratiği"),
        elevation: 0,
        leading: _sessionStarted
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  timer.cancel();
                  _transitionTimer?.cancel();
                  Navigator.pop(context);
                },
              )
            : null,
      ),
      body: !_sessionStarted
          ? _buildTutorialScreen()
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = constraints.maxWidth * 0.7;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: size,
                              height: size,
                              child: CircularProgressIndicator(
                                value: _isInTransition
                                    ? null
                                    : remainingSeconds / widget.totalDuration,
                                strokeWidth: 12,
                                color: currentColor,
                                backgroundColor: currentColor.withOpacity(0.2),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  centerText,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF064E3B),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                if (_sessionStarted && !_isInTransition)
                                  Text(
                                    step["title"]!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: currentColor.withOpacity(0.8),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (_sessionStarted && !_isInTransition) ...[
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black12,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: currentColor.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step["title"]!,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: currentColor.withOpacity(0.9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  step["desc"]!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                      backgroundColor:
                                          currentColor.withOpacity(0.2),
                                      label: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: currentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Chip(
                                      backgroundColor:
                                          currentColor.withOpacity(0.2),
                                      label: Text(
                                        '${stepSecondsLeft}s',
                                        style: TextStyle(
                                          color: currentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentStep + 1} / ${steps.length}',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              isWaitingPause
                                  ? 'Mola devam ediyor'
                                  : 'Tarama devam ediyor',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: LinearProgressIndicator(
                            value: (currentStep +
                                    (isWaitingPause ? 0.5 : 0)) /
                                steps.length,
                            backgroundColor: Colors.white,
                            color: currentColor,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      // Duraklat/Devam Et butonu - Secondary renk (açık yeşil)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isPaused
                                ? const Color(0xFF10B981) // Devam et - primary
                                : const Color(0xFFD1FAE5), // Duraklat - secondary
                            foregroundColor: _isPaused
                                ? Colors.white
                                : const Color(0xFF047857), // secondary-foreground
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _isPaused = !_isPaused;
                              if (!_isPaused) {
                                startTimer();
                              } else {
                                timer.cancel();
                                _transitionTimer?.cancel();
                              }
                            });
                          },
                          icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                          label: Text(_isPaused ? 'Devam Et' : 'Duraklat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Çık butonu - Koyu yeşil (secondary-foreground)
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857), // secondary-foreground - koyu yeşil
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            timer.cancel();
                            _transitionTimer?.cancel();
                            showDialog(
                              context: context,
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
                                        Icons.pause_circle_filled,
                                        size: 60,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Seans Durduruldu",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF064E3B),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Devam etmek istiyor musunuz?",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _isPaused = false;
                                                });
                                                startTimer();
                                              },
                                              child: const Text(
                                                "Devam Et",
                                                style: TextStyle(
                                                  color: Color(0xFF10B981),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF047857), // koyu yeşil
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Çık"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.stop),
                          label: const Text('Çık'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTutorialScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.self_improvement,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
                SizedBox(height: 16),
                Text(
                  "Anı Yaşama Pratiği",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF064E3B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "Nasıl Çalışır?",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 16),
          _buildTutorialStep(
            1,
            "Rahatlayın",
            "Sakin bir ortama geç ve rahat bir pozisyonda otur veya yat.",
          ),
          _buildTutorialStep(
            2,
            "Odaklanın",
            "Her body bölgesine sırasıyla odaklan ve o bölgedeki hissi gözlemle.",
          ),
          _buildTutorialStep(
            3,
            "Farkındalık Geliştir",
            "Vücudunun her bölgesine bilinç dolu bir şekilde dikkat ver.",
          ),
          _buildTutorialStep(
            4,
            "Tamamla",
            "10 dakika boyunca vücudunun tamamının taramasını tamamla.",
          ),
          const SizedBox(height: 32),
          const Text(
            "Faydaları",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 12),
          _buildBenefitItem("✓ Stressi azaltır"),
          _buildBenefitItem("✓ Vücut farkındalığını arttırır"),
          _buildBenefitItem("✓ Uykunuzu iyileştirir"),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                setState(() {
                  _sessionStarted = true;
                });
                startTimer();
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: const Text(
                "Başla",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(int number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF10B981),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF4B5563),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}