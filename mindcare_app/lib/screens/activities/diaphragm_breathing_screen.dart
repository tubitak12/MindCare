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
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

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

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      // keep session state so we remain in the exercise view
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
        return const Color(0xFF72B01D);
      case _DiaphragmPhase.exhale:
        return const Color(0xFF4E8A3A);
      case _DiaphragmPhase.finished:
        return const Color(0xFF1B4332);
    }
  }

  double get _circleScale {
    const double minScale = 0.55;
    const double maxScale = 0.75;
    const double range = maxScale - minScale;

    if (_phase == _DiaphragmPhase.inhale) {
      final double progress = (_inhaleSeconds - _phaseRemaining) / _inhaleSeconds;
      return minScale + (range * progress);
    }
    if (_phase == _DiaphragmPhase.exhale) {
      final double progress = (_exhaleSeconds - _phaseRemaining) / _exhaleSeconds;
      return maxScale - (range * progress);
    }
    return (minScale + maxScale) / 2;
  }

  double get _progressValue {
    return _remainingSeconds / _totalSeconds;
  }

  String get _timeFormatted {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildInstructionLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, color: Color(0xFF1B4332)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1B4332),
                height: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),
      appBar: AppBar(
        title: const Text('Diyafram Nefesi'),
        backgroundColor: const Color(0xFF72B01D),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_sessionStarted) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 10),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Diyafram Nefesi Nasıl Uygulanır?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B4332),
                                ),
                              ),
                              const SizedBox(height: 14),
                              _buildInstructionLine(
                                'Hazırlık: Rahat bir zemine sırt üstü yatın veya dik bir şekilde oturun.',
                              ),
                              _buildInstructionLine(
                                'Pozisyon: Bir elinizi göğsünüze, diğerini ise göğüs kafesinin altına (karnınıza) yerleştirin.',
                              ),
                              _buildInstructionLine(
                                'Nefes Alma: Burnunuzdan yavaşça 4 saniyede nefes alın. Bu sırada karnınızdaki elin yükseldiğini, göğsünüzdeki elin ise sabit kaldığını hissedin.',
                              ),
                              _buildInstructionLine(
                                'Nefes Verme: Karnınızı içeri çekerek, aldığınız nefesi 6 saniyede ağzınızdan yavaşça verin.',
                              ),
                              _buildInstructionLine(
                                'Tekrar: Bu işlemi günde birkaç kez, 5 dakika boyunca tekrarlayın.',
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_sessionStarted) ...[
                        Center(
                          child: Column(
                            children: [
                              Text(
                                _timeFormatted,
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _phaseLabel,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: _phaseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 250,
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
                                        color: const Color(0xFF72B01D),
                                        backgroundColor: const Color(0xFFE0F2F1),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeInOut,
                                      width: size * _circleScale,
                                      height: size * _circleScale,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFDFF7E6),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '🫁',
                                          style: TextStyle(fontSize: 48),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF72B01D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isRunning ? _stopSession : _startSession,
                  child: Text(
                    _isRunning ? 'Durdur' : 'Başla',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
