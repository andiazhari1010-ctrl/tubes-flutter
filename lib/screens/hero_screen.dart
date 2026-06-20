import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  static const _classes = [
    (HeroClass.warrior, '⚔️', 'Warrior', '+20% HP bonus. Tahan tugas berat.'),
    (HeroClass.mage, '🧙', 'Mage', '+20% XP bonus. Damage boss lebih.'),
    (HeroClass.healer, '💚', 'Healer', 'HP regen. Buff anggota party.'),
    (HeroClass.rogue, '🏹', 'Rogue', '+25% Gold. Critical hit chance.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (ctx, state, _) {
        final hero = state.hero;

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            title: const Text('Hero'),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.c2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Center(
                    child: Icon(Icons.settings_outlined,
                        color: AppColors.t2, size: 18),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ── Profile Card ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.c2,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border2, width: 0.5),
                ),
                child: Column(
                  children: [
                    // Avatar emblem + badge level.
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88, height: 88,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.accent.withValues(alpha: 0.3), AppColors.c3],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                blurRadius: 22,
                                spreadRadius: -4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(hero.classEmoji, style: const TextStyle(fontSize: 44)),
                          ),
                        ),
                        Positioned(
                          bottom: -8, left: 0, right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(color: AppColors.gold.withValues(alpha: 0.3), blurRadius: 8),
                                ],
                              ),
                              child: Text('LV ${hero.level}',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2A1A00))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(hero.name,
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 17,
                          color: AppColors.t1,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      '${hero.className} · ${hero.xp}/${hero.maxXp} XP',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.accent2),
                    ),
                    const SizedBox(height: 16),
                    StatBar(
                        label: 'XP',
                        value: hero.xp,
                        maxValue: hero.maxXp,
                        color: AppColors.xp),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _statChip('🪙', '${hero.gold}', 'Gold',
                            AppColors.gold),
                        const SizedBox(width: 24),
                        _statChip(
                            '💎', '${hero.gems}', 'Gems', AppColors.accent2),
                        const SizedBox(width: 24),
                        _statChip('🔥', '${hero.streak}', 'Streak',
                            AppColors.gold),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              // ── Statistics Dashboard Button ────────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.15),
                        AppColors.accent2.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bar_chart_rounded, color: AppColors.accent, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STATISTICS DASHBOARD',
                              style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.t1,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Lihat ringkasan progress & level atribut',
                              style: TextStyle(fontSize: 9, color: AppColors.t3),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: AppColors.t3, size: 12),
                    ],
                  ),
                ),
              ),

              // ── Class Selection ────────────────────────────────────────
              const SectionTitle('Pilih Class'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: _classes.map((c) {
                  final (cls, emoji, name, desc) = c;
                  final sel = hero.heroClass == cls;
                  return GestureDetector(
                    onTap: () {
                      state.changeClass(cls);
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Class dipilih: $name!'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.accent.withValues(alpha: 0.09)
                            : AppColors.c1,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border,
                          width: sel ? 1.5 : 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji,
                              style: const TextStyle(fontSize: 28)),
                          const SizedBox(height: 6),
                          Text(name,
                              style: TextStyle(
                                fontFamily: 'Cinzel',
                                fontSize: 12,
                                color: AppColors.t1,
                              )),
                          const SizedBox(height: 3),
                          Text(desc,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.t3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ── Item Shop ──────────────────────────────────────────────
              const SectionTitle('Item Shop'),
              ...state.shopItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Text(item.emoji,
                          style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.t1)),
                            const SizedBox(height: 2),
                            Text(item.description,
                                style: TextStyle(
                                    fontSize: 10, color: AppColors.t3)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: item.owned
                            ? null
                            : () {
                                if (hero.gold < item.price) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                      content: const Text('Gold tidak cukup!'),
                                      backgroundColor: AppColors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }
                                state.buyItem(item);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${item.name} berhasil dibeli!'),
                                    backgroundColor: AppColors.accent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: item.owned
                                ? AppColors.c2
                                : AppColors.gold.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: item.owned
                                  ? AppColors.border
                                  : AppColors.gold.withValues(alpha: 0.35),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            item.owned ? '✓ Dimiliki' : '🪙 ${item.price}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: item.owned
                                  ? AppColors.t3
                                  : AppColors.gold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String icon, String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valueColor)),
        Text(label.toUpperCase(),
            style: TextStyle(
                fontSize: 9, color: AppColors.t3, letterSpacing: 0.5)),
      ],
    );
  }
}