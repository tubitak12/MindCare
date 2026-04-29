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

  late Timer timer;
  Timer? _transitionTimer;
  late int remainingSeconds;
  late int stepDuration;
  late int stepSecondsLeft;
  final int pauseDuration = 2;

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
    stepDuration = ((widget.totalDuration / steps.length) - pauseDuration).floor();
    if (stepDuration < 3) stepDuration = 3;
    stepSecondsLeft = stepDuration;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

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
            _transitionTimer = Timer(const Duration(seconds: 3), () {
              if (mounted) {
                setState(() {
                  _isInTransition = false;
                  currentStep++;
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
    setState(() {
      currentStep = 0;
      isWaitingPause = false;
      remainingSeconds = widget.totalDuration;
      stepSecondsLeft = stepDuration;
    });
    startTimer();
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
      centerText = currentStep < steps.length - 1 ? 'Sonraki: ${steps[currentStep + 1]["title"]}' : 'Bitiş';
    } else {
      centerText = formatTime(remainingSeconds);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10B981),
        title: const Text("Derin Tarama"),
        elevation: 0,
      ),
      body: Column(
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
                          value: _sessionStarted && !_isInTransition ? remainingSeconds / widget.totalDuration : 1.0,
                          strokeWidth: 10,
                          color: const Color(0xFF10B981),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      Text(
                        centerText,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF064E3B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (!_sessionStarted) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _sessionStarted = true;
                    });
                    startTimer();
                  },
                  child: const Text(
                    "Başlat",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ] else if (_isInTransition) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text(
                    "Hazırlan...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF064E3B),
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black12,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step["title"]!,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF064E3B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            step["desc"]!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                backgroundColor: const Color(0xFFD1FAE5),
                                label: Text(
                                  statusText,
                                  style: const TextStyle(
                                    color: Color(0xFF064E3B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Chip(
                                backgroundColor: const Color(0xFFE5E7EB),
                                label: Text(
                                  '${stepSecondsLeft}s',
                                  style: const TextStyle(
                                    color: Color(0xFF374151),
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
                  const SizedBox(height: 28),
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
                        isWaitingPause ? 'Mola devam ediyor' : 'Tarama devam ediyor',
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
                      value: (currentStep + (isWaitingPause ? 0.5 : 0)) / steps.length,
                      backgroundColor: Colors.white,
                      color: const Color(0xFF10B981),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
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
                                        backgroundColor: Colors.red,
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
                  },
                  child: const Text(
                    "Durdur",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
