import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onRegistered;
  const RegisterScreen({super.key, required this.onRegistered});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;
    await viewModel.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (viewModel.status == AuthStatus.authenticated) {
      widget.onRegistered();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب جديد')),
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
                    Text('أنشئ حسابك في EduSpirit',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: AppSpacing.l),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                      validator: (value) =>
                          (value == null || value.trim().length < 2) ? 'أدخل اسمك الكامل' : null,
                    ),
                    const SizedBox(height: AppSpacing.m),
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
                        helperText: '8 أحرف على الأقل',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.length < 8) ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل' : null,
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
                          : const Text('إنشاء الحساب'),
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
}
