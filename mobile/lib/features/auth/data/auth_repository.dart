import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/secure_token_storage.dart';
import 'user_model.dart';

/// يعزل كل تفاصيل الاتصال بالـ API عن الـ ViewModel — بحيث لو تغيّر مصدر البيانات
/// (مثلًا نضيف Cache محلي) لا نلمس أي شاشة أو ViewModel.
class AuthRepository {
  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  AuthRepository(this._apiClient, this._tokenStorage);

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return _persistAndReturnUser(response.data);
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post('/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    return _persistAndReturnUser(response.data);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.refreshToken;
    try {
      if (refreshToken != null) {
        await _apiClient.dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } on DioException {
      // حتى لو فشل استدعاء الخادم (لا اتصال إنترنت مثلًا)، ننظّف الجلسة محليًا دائمًا.
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> forgotPassword(String email) =>
      _apiClient.dio.post('/auth/forgot-password', data: {'email': email});

  Future<void> resetPassword({required String token, required String newPassword}) =>
      _apiClient.dio.post('/auth/reset-password', data: {'token': token, 'newPassword': newPassword});

  Future<void> verifyEmail(String token) =>
      _apiClient.dio.post('/auth/verify-email', data: {'token': token});

  Future<void> resendVerification(String email) =>
      _apiClient.dio.post('/auth/resend-verification', data: {'email': email});

  Future<UserModel> loginWithGoogle(String idToken) async {
    final response = await _apiClient.dio.post('/auth/google', data: {'idToken': idToken});
    return _persistAndReturnUser(response.data);
  }

  Future<bool> hasActiveSession() async => await _tokenStorage.accessToken != null;

  Future<UserModel> _persistAndReturnUser(Map<String, dynamic> data) async {
    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
    return UserModel.fromJson(data['user']);
  }
}
