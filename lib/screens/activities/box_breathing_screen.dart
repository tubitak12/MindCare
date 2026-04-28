import 'dart:async';
import 'package:flutter/material.dart';

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

enum _BoxBreathPhase { inhale, hold, exhale, holdAfterExhale, finished }

class _BoxBreathingScreenState extends State<BoxBreathingScreen> {
  static const int _totalSeconds = 180; // 3 dakika
  static const int _phaseSeconds = 4; // Her adım 4 saniye

  int _remainingSeconds = _totalSeconds;
  _BoxBreathPhase _phase = _BoxBreathPhase.finished;
  int _phaseRemaining = _phaseSeconds;
  Timer? _timer;

  bool get _isRunning => _timer?.isActive ?? false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSession() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = _totalSeconds;
      _phase = _BoxBreathPhase.inhale;
      _phaseRemaining = _phaseSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _phase = _BoxBreathPhase.finished;
          _phaseRemaining = 0;
        });
        return;
      }

      setState(() {
        _remainingSeconds--;
        _phaseRemaining--;

        if (_phaseRemaining <= 0) {
          switch (_phase) {
            case _BoxBreathPhase.inhale:
              _phase = _BoxBreathPhase.hold;
              break;
            case _BoxBreathPhase.hold:
              _phase = _BoxBreathPhase.exhale;
              break;
            case _BoxBreathPhase.exhale:
              _phase = _BoxBreathPhase.holdAfterExhale;
              break;
            case _BoxBreathPhase.holdAfterExhale:
              _phase = _BoxBreathPhase.inhale;
              break;
            case _BoxBreathPhase.finished:
              break;
          }
          _phaseRemaining = _phaseSeconds;
        }
      });
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _phase = _BoxBreathPhase.finished;
      _phaseRemaining = 0;
    });
  }

  String get _phaseLabel {
    switch (_phase) {
      case _BoxBreathPhase.inhale:
        return 'Nefes al';
      case _BoxBreathPhase.hold:
      case _BoxBreathPhase.holdAfterExhale:
        return 'Tut';
      case _BoxBreathPhase.exhale:
        return 'Ver';
      case _BoxBreathPhase.finished:
        return 'Hazır';
    }
  }

  String get _phaseEmoji {
    switch (_phase) {
      case _BoxBreathPhase.inhale:
        return '🌬️';
      case _BoxBreathPhase.hold:
      case _BoxBreathPhase.holdAfterExhale:
        return '⏸️';
      case _BoxBreathPhase.exhale:
        return '💨';
      case _BoxBreathPhase.finished:
        return '🧘';
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case _BoxBreathPhase.inhale:
        return const Color(0xFF10B981);
      case _BoxBreathPhase.hold:
      case _BoxBreathPhase.holdAfterExhale:
        return const Color(0xFF064E3B);
      case _BoxBreathPhase.exhale:
        return const Color(0xFF4E8A3A);
      case _BoxBreathPhase.finished:
        return Colors.grey;
    }
  }

  double get _phaseProgress =>
      1 - (_phaseRemaining / _phaseSeconds);

  String get _timeFormatted {
    final min = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        title: const Text("Kutu Nefesi"),
        backgroundColor: const Color(0xFF10B981),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
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
                            value: _remainingSeconds / _totalSeconds,
                            strokeWidth: 10,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: size * (0.6 + _phaseProgress * 0.3),
                          height: size * (0.6 + _phaseProgress * 0.3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _phaseColor.withValues(alpha: 51),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_phaseEmoji,
                                  style: const TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              Text(
                                _phase == _BoxBreathPhase.finished
                                    ? '0'
                                    : '$_phaseRemaining',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _phaseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isRunning ? _stopSession : _startSession,
              child: Text(_isRunning ? "Durdur" : "Başla"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}