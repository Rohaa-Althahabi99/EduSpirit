import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/auth_viewmodel.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استعادة كلمة المرور')),
      body: SafeArea(
        child: Consumer<AuthViewModel>(
          builder: (context, viewModel, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة تعيين كلمة المرور.'),
                const SizedBox(height: AppSpacing.l),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.mail_outline)),
                ),
                if (viewModel.forgotPasswordMessage != null) ...[
                  const SizedBox(height: AppSpacing.m),
                  Text(viewModel.forgotPasswordMessage!, style: Theme.of(context).textTheme.bodyMedium),
                ],
                const SizedBox(height: AppSpacing.l),
                ElevatedButton(
                  onPressed: viewModel.isSubmittingForgotPassword
                      ? null
                      : () => viewModel.requestPasswordReset(_emailController.text.trim()),
                  child: viewModel.isSubmittingForgotPassword
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('إرسال رابط الاستعادة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
