import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final hero = state.hero;
        final todayTasks =
            state.todos.where((t) => t.subtitle.contains('Hari ini')).toList();

        return Scaffold(
          backgroundColor: AppColors.c0,
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Selamat pagi,',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.t3,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            '${hero.name.split(' ').first} ${hero.classEmoji}',
                            style: const TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.t1,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _iconBtn('🔔', onTap: () {}),
                          const SizedBox(width: 8),
                          _iconBtn('🛒', onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ShopScreen()),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rest of the UI ...
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // ── Hero Card ──────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.c2,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                              color: AppColors.border2, width: 0.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 58, height: 58,
                                      decoration: BoxDecoration(
                                        color: AppColors.c3,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        border: Border.all(
                                            color: AppColors.accent,
                                            width: 2),
                                      ),
                                      child: const Center(
                                        child: Text('⚔️',
                                            style:
                                                TextStyle(fontSize: 26)),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -6, right: -6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Lv.${hero.level}',
                                          style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2A1A00)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(hero.name,
                                        style: const TextStyle(
                                          fontFamily: 'Cinzel',
                                          fontSize: 14,
                                          color: AppColors.t1,
                                        )),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${hero.classEmoji} ${hero.className} · Kelompok 6',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.accent2,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            StatBar(
                                label: 'HP',
                                value: hero.hp,
                                maxValue: hero.maxHp,
                                color: AppColors.hp),
                            StatBar(
                                label: 'XP',
                                value: hero.xp,
                                maxValue: hero.maxXp,
                                color: AppColors.xp),
                            StatBar(
                                label: 'MP',
                                value: hero.mp,
                                maxValue: hero.maxMp,
                                color: AppColors.mp),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CurrencyChip(
                                    icon: '🪙',
                                    value: '${hero.gold}',
                                    label: 'Gold'),
                                const SizedBox(width: 8),
                                CurrencyChip(
                                    icon: '💎',
                                    value: '${hero.gems}',
                                    label: 'Gems'),
                                const SizedBox(width: 8),
                                CurrencyChip(
                                    icon: '🔥',
                                    value: '${hero.streak}',
                                    label: 'Streak'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SectionTitle('Active Quest'),
                      ...state.quests
                          .map((q) => QuestCard(quest: q)),

                      const SectionTitle('Today'),
                      ...todayTasks.map((t) => TaskItem(
                            task: t,
                            onTap: () => state.toggleTask(t),
                          )),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBtn(String icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppColors.c2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Center(
          child: Text(icon, style: const TextStyle(fontSize: 15)),
        ),
      ),
    );
  }
}
