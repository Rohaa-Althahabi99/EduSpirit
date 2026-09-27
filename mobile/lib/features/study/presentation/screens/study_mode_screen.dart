import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/study_repository.dart';

/// شاشة وضع الدراسة: مؤقت بومودورو (25 دقيقة تركيز / 5 دقائق راحة) مع تسجيل
/// الجلسة في الخادم عند البدء والانتهاء لتحديث سلسلة الإنجاز (Study Streak).
class StudyModeScreen extends StatefulWidget {
  final StudyRepository repository;
  const StudyModeScreen({super.key, required this.repository});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  static const _focusDuration = Duration(minutes: 25);
  static const _breakDuration = Duration(minutes: 5);

  Duration _remaining = _focusDuration;
  bool _isRunning = false;
  bool _isBreak = false;
  Timer? _timer;
  String? _sessionId;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleTimer() async {
    if (_isRunning) {
      _pause();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    setState(() => _isRunning = true);
    if (!_isBreak && _sessionId == null) {
      try {
        _sessionId = await widget.repository.startSession('pomodoro');
      } catch (_) {
        // حتى لو فشل تسجيل الجلسة على الخادم (لا إنترنت)، المؤقت يعمل محليًا بلا انقطاع.
      }
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _tick());
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  Future<void> _tick() async {
    if (_remaining.inSeconds <= 1) {
      _timer?.cancel();
      if (!_isBreak && _sessionId != null) {
        try {
          await widget.repository.endSession(_sessionId!);
        } catch (_) {}
        _sessionId = null;
      }
      setState(() {
        _isBreak = !_isBreak;
        _remaining = _isBreak ? _breakDuration : _focusDuration;
        _isRunning = false;
      });
      return;
    }
    setState(() => _remaining -= const Duration(seconds: 1));
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remaining = _focusDuration;
      _sessionId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = (_isBreak ? _breakDuration : _focusDuration).inSeconds;
    final progress = 1 - (_remaining.inSeconds / totalSeconds);
    final minutes = _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('وضع الدراسة')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_isBreak ? 'وقت الراحة ☕' : 'وقت التركيز 🎯',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.l),
            SizedBox(
              width: 220, height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220, height: 220,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: AppColors.primarySoft,
                      valueColor: AlwaysStoppedAnimation(_isBreak ? AppColors.accentGreen : AppColors.primary),
                    ),
                  ),
                  Text('$minutes:$seconds', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: _toggleTimer,
                  iconSize: 32,
                  padding: const EdgeInsets.all(20),
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: AppSpacing.m),
                IconButton(onPressed: _reset, iconSize: 28, icon: const Icon(Icons.refresh)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
