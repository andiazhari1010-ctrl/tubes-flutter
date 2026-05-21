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
        
        // Heatmap colors based on intensity
        final intensityColors = [
          Colors.white.withOpacity(0.04), // 0 tasks
          AppColors.accent.withOpacity(0.2), // 1-2 tasks
          AppColors.accent.withOpacity(0.4), // 3-4 tasks
          AppColors.accent.withOpacity(0.7), // 5-6 tasks
          AppColors.gold.withOpacity(0.8),    // 7+ tasks
        ];

        // Weekly chart task completions
        final weeklyData = [
          ('Sen', 3, 0.4),
          ('Sel', 5, 0.7),
          ('Rab', 2, 0.3),
          ('Kam', 7, 0.95),
          ('Jum', (4 + hero.totalTasksCompleted % 4), 0.6),
          ('Sab', 1, 0.15),
          ('Min', (2 + hero.streak % 3), 0.3),
        ];

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('STATISTICS'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.t2),
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
                  _statCard('Total XP', '${hero.xp + (hero.level * 100)}', 'TERKUMPUL', Icons.bolt_rounded, AppColors.accent2),
                  _statCard('Level Hero', 'LV. ${hero.level}', 'PERKEMBANGAN', Icons.workspace_premium_rounded, AppColors.gold),
                  _statCard('Quest Selesai', '${hero.totalQuestsCompleted}', 'PETUALANGAN', Icons.explore_rounded, AppColors.mp),
                ],
              ),

              const SizedBox(height: 20),

              // ── Weekly Progress Chart ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.c2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROGRES MINGGUAN',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: weeklyData.map((d) {
                        final (day, count, ratio) = d;
                        return Column(
                          children: [
                            Text('$count', style: const TextStyle(fontSize: 9, color: AppColors.t2)),
                            const SizedBox(height: 6),
                            Container(
                              width: 14,
                              height: 80 * ratio,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.accent.withOpacity(0.5),
                                    AppColors.accent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(day, style: const TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w600)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Activity Heatmap ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.c2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HEATMAP AKTIVITAS (5 MINGGU TERAKHIR)',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.t1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Heatmap Grid
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(7, (colIndex) {
                        return Column(
                          children: List.generate(5, (rowIndex) {
                            // Seed color intensity deterministically
                            final seed = (colIndex * 3 + rowIndex * 2 + hero.totalTasksCompleted) % 5;
                            final cellColor = intensityColors[seed];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2.5),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.02),
                                  width: 0.5,
                                ),
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 12),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Kurang ', style: TextStyle(fontSize: 9, color: AppColors.t3)),
                        ...intensityColors.map((color) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )),
                        const Text(' Banyak', style: TextStyle(fontSize: 9, color: AppColors.t3)),
                      ],
                    ),
                  ],
                ),
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
                    const Text(
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
                    _skillRow('🧠 Intelligence', hero.intelligence, 'Coding & Logika', const Color(0xFF85B7EB)),
                    _skillRow('💪 Strength', hero.strength, 'Olahraga & Fisik', const Color(0xFFE24B4A)),
                    _skillRow('🎨 Creativity', hero.creativity, 'Desain & Seni', const Color(0xFFFAC775)),
                    _skillRow('📚 Knowledge', hero.knowledge, 'Belajar & Teori', const Color(0xFF5DCAA5)),
                    _skillRow('🎯 Focus', hero.focus, 'Konsentrasi & Disiplin', const Color(0xFF7F77DD)),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
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
                  style: const TextStyle(fontSize: 9, color: AppColors.t3, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w800, fontFamily: 'Cinzel'),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 8, color: AppColors.t2, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Icon(icon, color: color.withOpacity(0.4), size: 24),
        ],
      ),
    );
  }

  Widget _skillRow(String label, int value, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.t1),
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
                    style: const TextStyle(fontSize: 9, color: AppColors.t3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              // Progress showing to next level (mocking fraction based on level value)
              value: (value % 10) / 10 + 0.1,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.04),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
