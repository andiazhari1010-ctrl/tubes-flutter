import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'admin/admin_shell.dart';

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

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
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

  void _goAdmin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const AdminShell()));
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 60),

                  // Logo & title
                  const Text('🏰', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  const Text(
                    'HeroQuest',
                    style: TextStyle(
                      fontFamily: 'Cinzel',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.t1,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk sebagai siapa?',
                    style: TextStyle(
                        fontSize: 14, color: AppColors.t3, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 56),

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
                    borderColor: AppColors.gold.withOpacity(0.4),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
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
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              widget.isAdmin ? AppColors.gold.withOpacity(0.05) : AppColors.c2,
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
                color: widget.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: widget.accentColor.withOpacity(0.3), width: 0.5),
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
                          color: widget.accentColor.withOpacity(0.15),
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
                    style: const TextStyle(
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
                                  style: const TextStyle(
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
                color: widget.accentColor.withOpacity(0.6), size: 22),
          ],
        ),
      ),
    );
  }
}
