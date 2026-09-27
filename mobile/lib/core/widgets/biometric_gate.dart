import 'package:flutter/material.dart';
import '../security/biometric_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class BiometricGate extends StatefulWidget {
  final Widget child;
  final BiometricService biometricService;
  const BiometricGate({super.key, required this.child, required this.biometricService});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> with WidgetsBindingObserver {
  bool _isChecking = true;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAndAuthenticate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkAndAuthenticate() async {
    final enabled = await widget.biometricService.isEnabledByUser;
    if (!enabled) {
      setState(() { _isChecking = false; _isUnlocked = true; });
      return;
    }
    setState(() => _isChecking = false);
    final success = await widget.biometricService.authenticate();
    setState(() => _isUnlocked = success);
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_isUnlocked) return widget.child;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fingerprint, size: 72, color: AppColors.primary),
                const SizedBox(height: AppSpacing.l),
                const Text('التطبيق مقفل', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: AppSpacing.s),
                const Text('استخدم بصمتك أو رمز القفل لفتح EduSpirit', textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.l),
                ElevatedButton(onPressed: _checkAndAuthenticate, child: const Text('حاول مرة أخرى')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
