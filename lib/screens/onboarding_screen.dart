import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      emoji: '⚔️',
      title: 'Setiap tugas adalah\npetualangan',
      subtitle:
          'Selesaikan tugas kuliah, naikkan level karakter, dan taklukkan boss bersama party-mu.',
    ),
    _OnboardPage(
      emoji: '🏆',
      title: 'Bangun kebiasaan\nseperti seorang hero',
      subtitle:
          'Catat habit harianmu. Setiap keberhasilan memberikan XP dan streak yang makin panjang.',
    ),
    _OnboardPage(
      emoji: '⚡',
      title: 'Bergabung dengan\nparty-mu',
      subtitle:
          'Tantang boss deadline bersama teman satu kelompok dan bersaing di leaderboard.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 132, height: 132,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.accent.withValues(alpha: 0.28), AppColors.c2],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.22),
                            blurRadius: 36,
                            spreadRadius: -6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_pages[_page].emoji,
                            style: const TextStyle(fontSize: 64)),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _pages[_page].title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pages[_page].subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: AppColors.t2,
                          height: 1.6),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        final active = i == _page;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? AppColors.accent : AppColors.t3,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_page < _pages.length - 1) {
                          setState(() => _page++);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _page < _pages.length - 1
                            ? 'Lanjut →'
                            : 'Mulai Petualangan →',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.t2,
                        side: BorderSide(
                            color: AppColors.border2, width: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Sudah punya akun? Masuk',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String subtitle;
  const _OnboardPage(
      {required this.emoji, required this.title, required this.subtitle});
}