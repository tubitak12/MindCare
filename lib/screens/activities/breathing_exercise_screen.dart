import 'dart:async';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

enum _BreathPhase { inhale, hold, exhale, finished }

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen> {
  static const int _totalSeconds = 120;
  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 7;
  static const int _exhaleSeconds = 8;

  int _remainingSeconds = _totalSeconds;
  _BreathPhase _phase = _BreathPhase.finished;
  int _phaseRemaining = _inhaleSeconds;
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
      _phase = _BreathPhase.inhale;
      _phaseRemaining = _inhaleSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _phase = _BreathPhase.finished;
          _phaseRemaining = 0;
        });
        return;
      }

      setState(() {
        _remainingSeconds--;
        _phaseRemaining--;

        if (_phaseRemaining <= 0) {
          switch (_phase) {
            case _BreathPhase.inhale:
              _phase = _BreathPhase.hold;
              _phaseRemaining = _holdSeconds;
              break;

            case _BreathPhase.hold:
              _phase = _BreathPhase.exhale;
              _phaseRemaining = _exhaleSeconds;
              break;

            case _BreathPhase.exhale:
              _phase = _BreathPhase.inhale;
              _phaseRemaining = _inhaleSeconds;
              break;

            case _BreathPhase.finished:
              break;
          }
        }
      });
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _phase = _BreathPhase.finished;
      _phaseRemaining = 0;
    });
  }

  String get _phaseLabel {
    switch (_phase) {
      case _BreathPhase.inhale:
        return 'Nefes al';
      case _BreathPhase.hold:
        return 'Tut';
      case _BreathPhase.exhale:
        return 'Ver';
      case _BreathPhase.finished:
        return 'Hazır';
    }
  }

  String get _phaseEmoji {
    switch (_phase) {
      case _BreathPhase.inhale:
        return '🌬️';
      case _BreathPhase.hold:
        return '⏸️';
      case _BreathPhase.exhale:
        return '💨';
      case _BreathPhase.finished:
        return '🧘';
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case _BreathPhase.inhale:
        return const Color(0xFF10B981);
      case _BreathPhase.hold:
        return const Color(0xFF064E3B);
      case _BreathPhase.exhale:
        return const Color(0xFF4E8A3A);
      case _BreathPhase.finished:
        return Colors.grey;
    }
  }

  double get _phaseProgress {
    final total = _phase == _BreathPhase.inhale
        ? _inhaleSeconds
        : _phase == _BreathPhase.hold
            ? _holdSeconds
            : _phase == _BreathPhase.exhale
                ? _exhaleSeconds
                : 1;

    if (_phase == _BreathPhase.finished) return 0;

    return 1 - (_phaseRemaining / total);
  }

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
        title: const Text("4-7-8 Nefes"),
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
                            color: _phaseColor.withAlpha((0.2 * 255).round()), // updated
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_phaseEmoji,
                                  style: const TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              Text(
                                _phase == _BreathPhase.finished
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