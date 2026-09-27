import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/auth_repository.dart';
import '../../data/user_model.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// ViewModel وحيد لكل شاشات المصادقة — يحمل الحالة (Loading/Error/Authenticated)
/// وتستمع له الشاشات عبر Provider دون أي منطق أعمال داخل الـ Widgets نفسها.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  AuthViewModel(this._repository);

  AuthStatus status = AuthStatus.initial;
  String? errorMessage;
  UserModel? currentUser;

  Future<void> checkSession() async {
    status = (await _repository.hasActiveSession())
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading();
    try {
      currentUser = await _repository.login(email: email, password: password);
      status = AuthStatus.authenticated;
    } on DioException catch (e) {
      status = AuthStatus.error;
      errorMessage = _extractMessage(e);
    }
    notifyListeners();
  }

  Future<void> register(String fullName, String email, String password) async {
    _setLoading();
    try {
      currentUser = await _repository.register(fullName: fullName, email: email, password: password);
      status = AuthStatus.authenticated;
    } on DioException catch (e) {
      status = AuthStatus.error;
      errorMessage = _extractMessage(e);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// حالة منفصلة عن status الرئيسي حتى لا تُقحم شاشة "نسيت كلمة المرور" بمنطق تسجيل الدخول.
  bool isSubmittingForgotPassword = false;
  String? forgotPasswordMessage;

  Future<void> requestPasswordReset(String email) async {
    isSubmittingForgotPassword = true;
    forgotPasswordMessage = null;
    notifyListeners();
    try {
      await _repository.forgotPassword(email);
      forgotPasswordMessage = 'إن كان البريد الإلكتروني مسجّلًا لدينا، سيصلك رابط إعادة التعيين خلال دقائق.';
    } on DioException {
      forgotPasswordMessage = 'تعذّر إرسال الطلب. تحقق من اتصالك بالإنترنت وحاول مجددًا.';
    }
    isSubmittingForgotPassword = false;
    notifyListeners();
  }

  Future<void> loginWithGoogle(String idToken) async {
    _setLoading();
    try {
      currentUser = await _repository.loginWithGoogle(idToken);
      status = AuthStatus.authenticated;
    } on DioException catch (e) {
      status = AuthStatus.error;
      errorMessage = _extractMessage(e);
    }
    notifyListeners();
  }

  void _setLoading() {
    status = AuthStatus.loading;
    errorMessage = null;
    notifyListeners();
  }

  String _extractMessage(DioException e) {
    // نعرض رسالة الخادم إن وُجدت (عربية وواضحة)، وإلا رسالة عامة لا تكشف تفاصيل تقنية.
    final serverMessage = e.response?.data is Map ? e.response?.data['message'] : null;
    return serverMessage ?? 'تعذّر الاتصال بالخادم. تحقق من اتصالك بالإنترنت.';
  }
}
