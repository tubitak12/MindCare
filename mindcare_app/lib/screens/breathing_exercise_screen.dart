import 'dart:async';
import 'package:flutter/material.dart';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() =>
      _BreathingExerciseScreenState();
}

enum _BreathPhase { inhale, hold, exhale, finished }

class _BreathingExerciseScreenState
    extends State<BreathingExerciseScreen> {
  static const int _totalSeconds = 120;
  static const int _inhaleSeconds = 4;
  static const int _holdSeconds = 7;
  static const int _exhaleSeconds = 8;

  int _remainingSeconds = _totalSeconds;
  _BreathPhase _phase = _BreathPhase.finished;
  int _phaseRemaining = _inhaleSeconds;
  Timer? _timer;

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
          if (_phase == _BreathPhase.inhale) {
            _phase = _BreathPhase.hold;
            _phaseRemaining = _holdSeconds;
          } else if (_phase == _BreathPhase.hold) {
            _phase = _BreathPhase.exhale;
            _phaseRemaining = _exhaleSeconds;
          } else if (_phase == _BreathPhase.exhale) {
            _phase = _BreathPhase.inhale;
            _phaseRemaining = _inhaleSeconds;
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
        return const Color(0xFF72B01D);
      case _BreathPhase.hold:
        return const Color(0xFF1B4332);
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

    if (total == 0) return 0;
    return _phase == _BreathPhase.finished
        ? 0
        : 1 - _phaseRemaining / total;
  }

  String get _timeFormatted {
    final min = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7EE),

      /// 🔥 YENİ MODERN HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF72B01D),
                Color(0xFF4E8A3A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.self_improvement,
                      color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "4-7-8 Nefes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Rahatlama egzersizi",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// 🔝 SAYAÇ
              Text(
                _timeFormatted,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _phaseLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _phaseColor,
                ),
              ),

              const SizedBox(height: 20),

              /// 🎯 ANİMASYON
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
                              color: const Color(0xFF72B01D),
                              backgroundColor:
                                  const Color(0xFFCEEDCB),
                            ),
                          ),
                          AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 500),
                            width:
                                (size * (0.6 + _phaseProgress * 0.3))
                                    .clamp(80, size),
                            height:
                                (size * (0.6 + _phaseProgress * 0.3))
                                    .clamp(80, size),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  _phaseColor.withValues(alpha: 0.2),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(_phaseEmoji,
                                    style:
                                        const TextStyle(fontSize: 40)),
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

              /// 🔘 BUTON
              ElevatedButton(
                onPressed: _timer?.isActive == true
                    ? _stopSession
                    : _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF72B01D),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: Text(
                  _timer?.isActive == true
                      ? "Durdur"
                      : "Başla",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              if (_phase == _BreathPhase.finished)
                TextButton(
                  onPressed: _startSession,
                  child: const Text("Tekrar Başlat"),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}