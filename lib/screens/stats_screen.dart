import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final hero = state.hero;

        // Knowledge & Focus lama sudah dilebur ke Intelligence saat load,
        // jadi Intelligence adalah satu-satunya sumber kebenaran sekarang.
        final intelligenceTotal = hero.intelligence;

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('STATISTICS'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.t2),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 10),

              // ── General Statistics Grid ───────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _statCard('Total Task', '${hero.totalTasksCompleted}', 'SELESAI', Icons.task_alt_rounded, AppColors.xp),
                  _statCard('Total XP', '${hero.xp + (hero.level - 1) * 100}', 'TERKUMPUL', Icons.bolt_rounded, AppColors.accent2),
                  _statCard('Level Hero', 'LV. ${hero.level}', 'PERKEMBANGAN', Icons.workspace_premium_rounded, AppColors.gold),
                  _statCard('Quest Selesai', '${hero.totalQuestsCompleted}', 'PETUALANGAN', Icons.explore_rounded, AppColors.mp),
                ],
              ),

              const SizedBox(height: 20),

              // ── Skill Attributes Levels ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.c2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATRIBUT SKILL RPG',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _skillRow(Icons.psychology_rounded, 'Intelligence', intelligenceTotal, 'Belajar, Logika & Fokus', const Color(0xFF85B7EB)),
                    _skillRow(Icons.fitness_center_rounded, 'Strength', hero.strength, 'Olahraga & Fisik', const Color(0xFFE24B4A)),
                    _skillRow(Icons.palette_rounded, 'Creativity', hero.creativity, 'Desain & Seni', const Color(0xFFFAC775)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.c1, color.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18), width: 0.6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(fontSize: 9, color: AppColors.t3, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(fontSize: 19, color: color, fontWeight: FontWeight.w800, fontFamily: 'Cinzel'),
                ),
                const SizedBox(height: 1),
                Text(
                  sub,
                  style: TextStyle(fontSize: 8, color: AppColors.t2, fontWeight: FontWeight.w500, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: color.withValues(alpha: 0.22), width: 0.5),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
        ],
      ),
    );
  }

  Widget _skillRow(IconData icon, String label, int value, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.t1),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'LV. $value',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '($desc)',
                    style: TextStyle(fontSize: 9, color: AppColors.t3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progres menuju "level" atribut berikutnya (tiap 10 poin = 1 tingkat).
          LayoutBuilder(
            builder: (context, c) {
              final frac = ((value % 10) / 10).clamp(0.08, 1.0);
              return ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      width: c.maxWidth,
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      height: 6,
                      width: c.maxWidth * frac,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withValues(alpha: 0.5), color],
                        ),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}