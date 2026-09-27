import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يغلّف local_auth بمنطق تفعيل/تعطيل يختاره المستخدم بنفسه من شاشة الحساب —
/// لا نفرض البصمة على أحد؛ هي طبقة حماية إضافية اختيارية فوق الجلسة المخزّنة أصلًا.
class BiometricService {
  static const _enabledKey = 'eduspirit_biometric_enabled';
  final _auth = LocalAuthentication();

  Future<bool> get isDeviceSupported async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> get isEnabledByUser async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'تحقق من هويتك للدخول إلى EduSpirit',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
