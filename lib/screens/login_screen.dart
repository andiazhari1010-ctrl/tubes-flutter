import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'role_selection_screen.dart'; // ← ganti dari main_shell.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLogin = true;

  // ── Setelah submit, arahkan ke pilih role ──────────────────────────────
  void _submit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text('🏰', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text(
                'HeroQuest',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.t1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Gamified Task Management',
                style: TextStyle(
                    fontSize: 13, color: AppColors.t3, letterSpacing: 0.5),
              ),
              const SizedBox(height: 48),

              // Email
              _buildInput(
                controller: _emailCtrl,
                hint: 'Email kamu',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Password
              _buildInput(
                controller: _passCtrl,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscure,
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.t3,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 6),

              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Lupa password?',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.accent2)),
                  ),
                ),
              const SizedBox(height: 8),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLogin ? 'Masuk Sekarang' : 'Daftar Sekarang',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  Expanded(
                      child: Divider(color: AppColors.border, thickness: 0.5)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('atau',
                        style: TextStyle(fontSize: 11, color: AppColors.t3)),
                  ),
                  Expanded(
                      child: Divider(color: AppColors.border, thickness: 0.5)),
                ],
              ),
              const SizedBox(height: 16),

              // Google button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _submit,
                  icon: const Text('🌐', style: TextStyle(fontSize: 16)),
                  label: const Text('Lanjut dengan Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.t1,
                    side: BorderSide(color: AppColors.border2, width: 0.5),
                    backgroundColor: AppColors.c2,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Toggle login/register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? 'Belum punya akun? ' : 'Sudah punya akun? ',
                    style: const TextStyle(fontSize: 12, color: AppColors.t3),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Daftar gratis' : 'Masuk',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.accent2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: AppColors.t1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.t3),
        prefixIcon: Icon(icon, color: AppColors.t3, size: 18),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.c2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border2, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1),
        ),
      ),
    );
  }
}
