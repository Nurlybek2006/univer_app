import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../providers/app_providers.dart';
import 'home_page.dart';
import 'admin/admin_panel_page.dart';

/// Кіру беті — тек email/пароль арқылы
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = ref.read(authServiceProvider);
    final success = await authService.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      final isAdmin = ref.read(isAdminProvider);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => isAdmin ? const AdminPanelPage() : const HomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Градиент фон
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D1B6E),
                  Color(0xFF1A237E),
                  Color(0xFF283593),
                  Color(0xFF1565C0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Декоративті дөңгелектер
          Positioned(
            top: -80,
            right: -60,
            child: _GlowCircle(size: 260, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _GlowCircle(size: 300, color: Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            top: 160,
            left: -40,
            child: _GlowCircle(size: 140, color: AppTheme.accent.withValues(alpha: 0.1)),
          ),

          // Мазмұн
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Логотип блогы
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.school_rounded,
                            size: 52, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Абай ҚазҰПУ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Студент Көмекшісі',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Шыны карточка (glassmorphism)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                          ),
                          padding: const EdgeInsets.all(28),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Жүйеге кіру',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Email
                                _GlassField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Email енгізіңіз';
                                    if (!v.contains('@')) return 'Жарамсыз email';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Пароль
                                _GlassField(
                                  controller: _passwordController,
                                  label: 'Пароль',
                                  icon: Icons.lock_outlined,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _login(),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'Пароль енгізіңіз';
                                    if (v.length < 6) return 'Пароль тым қысқа';
                                    return null;
                                  },
                                ),

                                // Қате
                                if (authService.errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.red.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        authService.errorMessage!,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 24),

                                // Кіру батырмасы
                                GestureDetector(
                                  onTap: authService.isLoading ? null : _login,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 54,
                                    decoration: BoxDecoration(
                                      gradient: authService.isLoading
                                          ? null
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFF00BCD4),
                                                Color(0xFF0097A7),
                                              ],
                                            ),
                                      color: authService.isLoading
                                          ? Colors.white24
                                          : null,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: authService.isLoading
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: const Color(0xFF00BCD4)
                                                    .withValues(alpha: 0.45),
                                                blurRadius: 20,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                    ),
                                    child: Center(
                                      child: authService.isLoading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2.5,
                                                  color: Colors.white),
                                            )
                                          : const Text(
                                              'Кіру',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      'Аккаунт тек әкімші арқылы жасалады.\nТіркелу мүмкіндігі жоқ.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Декоративті дөңгелек ───────────────────────────────────────
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

// ─── Шыны стиліндегі TextFormField ──────────────────────────────
class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  const _GlassField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: Icon(icon, color: Colors.white70, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.red.withValues(alpha: 0.7)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.orangeAccent, fontSize: 11),
      ),
    );
  }
}
