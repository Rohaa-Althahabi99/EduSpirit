import 'package:dio/dio.dart';
import 'secure_token_storage.dart';

/// عميل HTTP موحّد لكل التطبيق:
/// - يضيف Authorization Header تلقائيًا لكل طلب.
/// - عند استجابة 401 (Access Token منتهي) يحاول تجديد التوكن تلقائيًا مرة واحدة
///   ثم يعيد الطلب الأصلي، دون أن تشعر شاشات التطبيق بأي انقطاع.
class ApiClient {
  // غيّر هذا العنوان إلى عنوان خادم ASP.NET Core الفعلي لديك.
static const String baseUrl = 'http://10.0.2.2:64610/api/v1';  final Dio dio;
  final SecureTokenStorage _tokenStorage;
  bool _isRefreshing = false;

  ApiClient(this._tokenStorage) : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 15))) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final isRetry = error.requestOptions.extra['retried'] == true;

        if (isUnauthorized && !isRetry && !_isRefreshing) {
          _isRefreshing = true;
          final refreshed = await _tryRefreshToken();
          _isRefreshing = false;

          if (refreshed) {
            final newToken = await _tokenStorage.accessToken;
            final retryOptions = error.requestOptions
              ..headers['Authorization'] = 'Bearer $newToken'
              ..extra['retried'] = true;
            try {
              final response = await dio.fetch(retryOptions);
              return handler.resolve(response);
            } catch (_) {
              // إن فشلت إعادة المحاولة أيضًا، نمرر الخطأ الأصلي للواجهة لتوجيه المستخدم لتسجيل الدخول.
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    try {
      final response = await Dio(BaseOptions(baseUrl: baseUrl)).post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      await _tokenStorage.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    }
  }
}
