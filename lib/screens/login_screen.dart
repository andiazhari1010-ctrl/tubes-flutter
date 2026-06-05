import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLogin = true;
  bool _isLoading = false;
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (_isLogin) {
      if (email.isEmpty || pass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email dan Password harus diisi')),
        );
        return;
      }
    } else {
      final username = _usernameCtrl.text.trim();
      final fullName = _fullNameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      if (username.isEmpty || fullName.isEmpty || phone.isEmpty || email.isEmpty || pass.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua kolom harus diisi untuk mendaftar')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(email, pass);
        // Jika berhasil, AuthWrapper otomatis akan pindah ke RoleSelectionScreen
      } else {
        final username = _usernameCtrl.text.trim();
        final fullName = _fullNameCtrl.text.trim();
        final phone = _phoneCtrl.text.trim();

        final cred = await _authService.registerWithEmail(email, pass);
        if (cred?.user != null) {
          final isAdm = email.toLowerCase().contains('admin') || email.toLowerCase().contains('tubaguslinggaap');
          await _firestoreService.createUserDoc(
            uid: cred!.user!.uid,
            email: email,
            role: isAdm ? 'admin' : 'user',
            username: username,
            fullName: fullName,
            phone: phone,
          );
        }
        // Sama, otomatis pindah
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cred = await _authService.signInWithGoogle();
      if (cred == null) {
        return; // User cancelled
      }

      final user = cred.user;
      if (user != null) {
        final exists = await _firestoreService.userDocExists(user.uid);
        if (!exists) {
          // Buat dokumen baru di Firestore untuk pengguna baru Google
          final isAdm = (user.email ?? '').toLowerCase().contains('admin') || (user.email ?? '').toLowerCase().contains('tubaguslinggaap');
          await _firestoreService.createUserDoc(
            uid: user.uid,
            email: user.email ?? '',
            role: isAdm ? 'admin' : 'user',
            username: user.displayName?.replaceAll(' ', '').toLowerCase() ?? 'user_${user.uid.substring(0, 5)}',
            fullName: user.displayName ?? 'New Hero',
            phone: user.phoneNumber ?? '',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      final resetEmailCtrl = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.c1,
          title: Text(
            'Reset Password',
            style: TextStyle(color: AppColors.t1, fontFamily: 'Cinzel', fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Masukkan email Anda untuk menerima tautan penyetelan ulang kata sandi.',
                style: TextStyle(color: AppColors.t3, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildInput(
                controller: resetEmailCtrl,
                hint: 'Email Anda',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: AppColors.t3)),
            ),
            ElevatedButton(
              onPressed: () async {
                final resetEmail = resetEmailCtrl.text.trim();
                if (resetEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email harus diisi')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _sendResetLink(resetEmail);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim'),
            ),
          ],
        ),
      );
    } else {
      await _sendResetLink(email);
    }
  }

  Future<void> _sendResetLink(String email) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tautan reset password telah dikirim ke $email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim tautan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
              Text(
                'HeroQuest',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.t1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Gamified Task Management',
                style: TextStyle(
                    fontSize: 13, color: AppColors.t3, letterSpacing: 0.5),
              ),
              const SizedBox(height: 48),

              // Username (hanya untuk register)
              if (!_isLogin) ...[
                _buildInput(
                  controller: _usernameCtrl,
                  hint: 'Username kamu',
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 12),
                
                // Nama Lengkap (hanya untuk register)
                _buildInput(
                  controller: _fullNameCtrl,
                  hint: 'Nama Lengkap kamu',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 12),
                
                // No Telepon (hanya untuk register)
                _buildInput(
                  controller: _phoneCtrl,
                  hint: 'Nomor Telepon kamu',
                  icon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
              ],

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
                    onPressed: _forgotPassword,
                    child: Text('Lupa password?',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.accent2)),
                  ),
                ),
              const SizedBox(height: 8),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 20, 
                        width: 20, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : Text(
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
                  Padding(
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
                  onPressed: _isLoading ? null : _signInWithGoogle,
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
                    style: TextStyle(fontSize: 12, color: AppColors.t3),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Daftar gratis' : 'Masuk',
                      style: TextStyle(
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
      style: TextStyle(fontSize: 13, color: AppColors.t1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.t3),
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
          borderSide: BorderSide(color: AppColors.accent, width: 1),
        ),
      ),
    );
  }
}