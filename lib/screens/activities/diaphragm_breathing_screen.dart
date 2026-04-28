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
      _sessionStarted = false;
      _phase = _DiaphragmPhase.finished;
      _phaseRemaining = _inhaleSeconds;
      _remainingSeconds = _totalSeconds;
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

  Widget _buildInstructionLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 16, color: Color(0xFF064E3B)),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF064E3B),
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
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text('Diyafram Nefesi'),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_sessionStarted) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
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
                          color: Color(0xFF064E3B),
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
                                backgroundColor: const Color(0xFFE0F2F1),
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
              ],
              ElevatedButton(
                onPressed: _isRunning ? _stopSession : _startSession,
                child: Text(_isRunning ? 'Durdur' : 'Başla'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
