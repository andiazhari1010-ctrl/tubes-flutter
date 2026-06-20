import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'admin/admin_shell.dart';
import '../services/firestore_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  bool _checkingRole = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    
    _checkUserRole();
  }

  void _checkUserRole() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _checkingRole = false;
        });
        _ctrl.forward();
        return;
      }

      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final email = user.email ?? '';
        final roleVal = (email.toLowerCase().contains('admin') || email.toLowerCase().contains('tubaguslinggaap')) ? 'admin' : 'user';
        final username = email.isNotEmpty ? email.split('@').first : 'new_hero';
        final fullName = user.displayName ?? 'New Hero';

        await FirestoreService().createUserDoc(
          uid: user.uid,
          email: email,
          role: roleVal,
          username: username,
          fullName: fullName,
          phone: '',
        );

        doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      }

      String role = doc.data()?['role'] ?? 'user';
      final email = user.email ?? doc.data()?['email'] ?? '';
      final isAdm = email.toLowerCase().contains('admin') || email.toLowerCase().contains('tubaguslinggaap');
      if (isAdm && role != 'admin') {
        role = 'admin';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'role': 'admin'});
      }

      if (mounted) {
        if (role == 'admin') {
          setState(() {
            _checkingRole = false;
          });
          _ctrl.forward();
        } else {
          // Jika role adalah user biasa, langsung alihkan ke MainShell tanpa memunculkan layar pemilihan
          _goUser();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _checkingRole = false;
        });
        _ctrl.forward();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goUser() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainShell()));
  }

  void _goAdmin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Pengguna tidak ditemukan. Silakan login kembali.';

      final email = user.email ?? '';
      final isAdmEmail = email.toLowerCase().contains('admin') || email.toLowerCase().contains('tubaguslinggaap');

      DocumentSnapshot? doc;
      try {
        doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      } catch (_) {}

      final docExists = doc != null && doc.exists;
      String role = 'user';
      if (docExists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          role = data['role'] ?? 'user';
        }
      }

      if (mounted) Navigator.pop(context); // Close loading dialog

      if (role == 'admin' || isAdmEmail) {
        if (mounted) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const AdminShell()));
        }
      } else {
        if (!docExists) throw 'Profil pengguna tidak ditemukan di database.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ Akses ditolak! Akun Anda bukan Administrator.'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingRole) {
      return Scaffold(
        backgroundColor: AppColors.c0,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.c0,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 56),

                  // Emblem ber-glow — konsisten dengan layar Login.
                  Container(
                    width: 84, height: 84,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.accent.withValues(alpha: 0.35), AppColors.c2],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.28),
                          blurRadius: 28,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Center(child: Text('🏰', style: TextStyle(fontSize: 42))),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                      children: [
                        TextSpan(text: 'Hero', style: TextStyle(color: AppColors.t1)),
                        TextSpan(text: 'Quest', style: TextStyle(color: AppColors.gold2)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masuk sebagai siapa?',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.t3, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 48),

                  // User card
                  _RoleCard(
                    emoji: '⚔️',
                    title: 'User',
                    subtitle:
                        'Mahasiswa yang ingin mengelola tugas, habits, dan bergabung dalam party.',
                    accentColor: AppColors.accent,
                    borderColor: AppColors.border2,
                    onTap: _goUser,
                    badges: const ['Habits', 'Quest', 'Party', 'Leaderboard'],
                  ),

                  const SizedBox(height: 16),

                  // Admin card
                  _RoleCard(
                    emoji: '🛡️',
                    title: 'Admin',
                    subtitle:
                        'Kelola konten game, pantau statistik pengguna, dan moderasi aplikasi.',
                    accentColor: AppColors.gold,
                    borderColor: AppColors.gold.withValues(alpha: 0.4),
                    onTap: _goAdmin,
                    badges: const [
                      'Dashboard',
                      'Users',
                      'Content',
                      'Statistik'
                    ],
                    isAdmin: true,
                  ),

                  const Spacer(),

                  // Back button
                  TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Text(
                      '← Kembali ke Login',
                      style: TextStyle(fontSize: 12, color: AppColors.t3),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Role Card ────────────────────────────────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;
  final Color borderColor;
  final VoidCallback onTap;
  final List<String> badges;
  final bool isAdmin;

  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.borderColor,
    required this.onTap,
    required this.badges,
    this.isAdmin = false,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.diagonal3Values(_pressed ? 0.97 : 1.0, _pressed ? 0.97 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              widget.isAdmin ? AppColors.gold.withValues(alpha: 0.05) : AppColors.c2,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _pressed ? widget.accentColor : widget.borderColor,
            width: _pressed ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: widget.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Center(
                child: Text(widget.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: widget.isAdmin ? AppColors.gold : AppColors.t1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.isAdmin ? 'ADMIN' : 'USER',
                          style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              color: widget.accentColor,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                        fontSize: 11, color: AppColors.t3, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.badges
                        .map((b) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.c3,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppColors.border, width: 0.5),
                              ),
                              child: Text(b,
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: AppColors.t2,
                                      fontWeight: FontWeight.w500)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: widget.accentColor.withValues(alpha: 0.6), size: 22),
          ],
        ),
      ),
    );
  }
}