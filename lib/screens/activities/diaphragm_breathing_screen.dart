import 'dart:async';
import 'package:flutter/material.dart';

class DiaphragmBreathingScreen extends StatefulWidget {
  const DiaphragmBreathingScreen({super.key});

  @override
  State<DiaphragmBreathingScreen> createState() => _DiaphragmBreathingScreenState();
}

enum _DiaphragmPhase { inhale, exhale, finished }

class _DiaphragmBreathingScreenState extends State<DiaphragmBreathingScreen> {
  static const int _totalSeconds = 5 * 60;
  static const int _inhaleSeconds = 4;
  static const int _exhaleSeconds = 6;

  Timer? _timer;
  int _remainingSeconds = _totalSeconds;
  int _phaseRemaining = _inhaleSeconds;
  _DiaphragmPhase _phase = _DiaphragmPhase.finished;
  bool _sessionStarted = false;
  bool _isPaused = false;

  bool get _isRunning => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    _timer?.cancel();

    setState(() {
      if (!_sessionStarted) {
        _sessionStarted = true;
        _remainingSeconds = _totalSeconds;
        _phase = _DiaphragmPhase.inhale;
        _phaseRemaining = _inhaleSeconds;
      } else {
        _isPaused = false;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isPaused) return;

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _phase = _DiaphragmPhase.finished;
          _phaseRemaining = 0;
          _sessionStarted = false;
        });
        return;
      }

      setState(() {
        _remainingSeconds--;
        _phaseRemaining--;

        if (_phaseRemaining <= 0) {
          if (_phase == _DiaphragmPhase.inhale) {
            _phase = _DiaphragmPhase.exhale;
            _phaseRemaining = _exhaleSeconds;
          } else if (_phase == _DiaphragmPhase.exhale) {
            _phase = _DiaphragmPhase.inhale;
            _phaseRemaining = _inhaleSeconds;
          }
        }
      });
    });
  }

  void _pauseSession() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() {
        _isPaused = true;
      });
    }
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _sessionStarted = false;
      _phase = _DiaphragmPhase.finished;
      _phaseRemaining = _inhaleSeconds;
      _remainingSeconds = _totalSeconds;
      _isPaused = false;
    });
  }

  String get _phaseLabel {
    switch (_phase) {
      case _DiaphragmPhase.inhale:
        return 'Nefes Alma';
      case _DiaphragmPhase.exhale:
        return 'Nefes Verme';
      case _DiaphragmPhase.finished:
        return 'Hazırlan';
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case _DiaphragmPhase.inhale:
        return const Color(0xFF10B981);
      case _DiaphragmPhase.exhale:
        return const Color(0xFF4E8A3A);
      case _DiaphragmPhase.finished:
        return const Color(0xFF064E3B);
    }
  }

  double get _phaseProgress {
    if (_phase == _DiaphragmPhase.finished) return 0;

    final total = _phase == _DiaphragmPhase.inhale
        ? _inhaleSeconds
        : _exhaleSeconds;
    final progress = (_phase == _DiaphragmPhase.inhale
            ? _inhaleSeconds - _phaseRemaining
            : _exhaleSeconds - _phaseRemaining) /
        total;
    return progress.clamp(0.0, 1.0);
  }

  double get _progressValue {
    return _remainingSeconds / _totalSeconds;
  }

  String get _timeFormatted {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text('Diyafram Nefesi'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        leading: _sessionStarted
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: !_sessionStarted
          ? _buildTutorialScreen()
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            _timeFormatted,
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _phaseLabel,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _phaseColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
                                    value: _progressValue,
                                    strokeWidth: 10,
                                    color: const Color(0xFF10B981),
                                    backgroundColor:
                                        const Color(0xFFE0F2F1),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: size * (0.6 + _phaseProgress * 0.3),
                                  height: size * (0.6 + _phaseProgress * 0.3),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFDFF7E6),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '🫁',
                                      style: TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
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
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (_isPaused) {
                                _startSession();
                              } else {
                                _pauseSession();
                              }
                            },
                            icon: Icon(_isPaused
                                ? Icons.play_arrow
                                : Icons.pause),
                            label: Text(_isPaused
                                ? 'Devam Et'
                                : 'Duraklat'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Çık butonu - Koyu yeşil ton (secondary-foreground)
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF047857), // secondary-foreground - koyu yeşil
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _stopSession,
                            icon: const Icon(Icons.stop),
                            label: const Text('Çık'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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
                  Icons.air,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
                SizedBox(height: 16),
                Text(
                  "Diyafram Nefesi",
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
          _buildStep(
            1,
            "Rahatlayın",
            "Rahat bir zemine sırt üstü yatın veya dik bir şekilde oturun.",
          ),
          _buildStep(
            2,
            "Pozisyon",
            "Bir elinizi göğsünüze, diğerini ise göğüs kafesinin altına (karnınıza) yerleştirin.",
          ),
          _buildStep(
            3,
            "Nefes Alma",
            "Burnunuzdan yavaşça 4 saniyede nefes alın. Karnınızdaki elin yükseldiğini hissedin.",
          ),
          _buildStep(
            4,
            "Nefes Verme",
            "Karnınızı içeri çekerek, aldığınız nefesi 6 saniyede ağzınızdan yavaşça verin.",
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
          _buildBenefit("✓ Stresi azaltır ve rahatlamayı sağlar"),
          _buildBenefit("✓ Kalp atış hızını normalleştirir"),
          _buildBenefit("✓ Derin uyku uyumanıza yardımcı olur"),
          _buildBenefit("✓ Diyafram kasını güçlendirir"),
          _buildBenefit("✓ Konsantrasyon artırır"),
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
                  _isPaused = false;
                });
                _startSession();
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

  Widget _buildStep(int number, String title, String description) {
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

  Widget _buildBenefit(String text) {
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