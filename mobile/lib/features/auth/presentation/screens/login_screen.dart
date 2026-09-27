import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    await viewModel.login(_emailController.text.trim(), _passwordController.text);
    if (viewModel.status == AuthStatus.authenticated) {
      widget.onLoggedIn();
    }
  }

  Future<void> _submitGoogle(AuthViewModel viewModel) async {
    try {
      // GoogleSignIn يعرض واجهة اختيار الحساب الأصلية على الجهاز، ثم نرسل idToken فقط
      // للخادم — لا كلمة مرور ولا بيانات حساسة تمر عبر تطبيقنا مباشرة.
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      if (account == null) return; // ألغى المستخدم العملية
      final auth = await account.authentication;
      if (auth.idToken == null) return;

      await viewModel.loginWithGoogle(auth.idToken!);
      if (viewModel.status == AuthStatus.authenticated) widget.onLoggedIn();
    } catch (_) {
      // فشل صامت هنا؛ رسالة الخطأ العامة تظهر من viewModel.status لو تغيّرت فعليًا لـ error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, viewModel, _) {
            final isLoading = viewModel.status == AuthStatus.loading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildLogo(context),
                    const SizedBox(height: AppSpacing.xl),
                    Text('أهلًا بعودتك 👋',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('سجّل دخولك لمتابعة رحلتك الدراسية',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            )),
                    const SizedBox(height: AppSpacing.l),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.mail_outline)),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'أدخل بريدك الإلكتروني';
                        if (!value.contains('@')) return 'صيغة البريد الإلكتروني غير صحيحة';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.length < 8) ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل' : null,
                    ),

                    const SizedBox(height: AppSpacing.s),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        )),
                        child: const Text('نسيت كلمة المرور؟'),
                      ),
                    ),

                    if (viewModel.status == AuthStatus.error) ...[
                      const SizedBox(height: AppSpacing.m),
                      Text(viewModel.errorMessage ?? '', style: const TextStyle(color: AppColors.accentRed)),
                    ],

                    const SizedBox(height: AppSpacing.l),
                    ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(viewModel),
                      child: isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('تسجيل الدخول'),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Row(children: [
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2))),
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('أو', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))),
                      Expanded(child: Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2))),
                    ]),
                    const SizedBox(height: AppSpacing.m),
                    OutlinedButton.icon(
                      onPressed: isLoading ? null : () => _submitGoogle(viewModel),
                      icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                      label: const Text('المتابعة عبر Google'),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => RegisterScreen(onRegistered: widget.onLoggedIn),
                      )),
                      child: const Text('ليس لديك حساب؟ أنشئ حسابًا جديدًا'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Center(
      child: Container(
        width: 72, height: 72,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.school_rounded, color: Colors.white, size: 36),
      ),
    );
  }
}
