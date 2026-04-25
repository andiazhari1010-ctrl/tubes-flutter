import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../widgets/common_widgets.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onShopPressed;
  const HomeScreen({super.key, this.onShopPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final hero = state.hero;
        final todayTasks = state.dailyTasks; // Gunakan Daily Tasks untuk hari ini

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
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(
                                    value: state,
                                    child: const NotificationsScreen(),
                                  )));
                                },
                                child: _iconBtn('🔔'),
                              ),
                              if (state.notifications.any((n) => !n.isRead))
                                Positioned(
                                  top: -2, right: -2,
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppColors.c0, width: 1.5),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onShopPressed,
                            child: _iconBtn('🛒'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

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
                      if (state.quests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Belum ada quest aktif dari Admin.', style: TextStyle(color: AppColors.t3, fontSize: 12)),
                        )
                      else
                        ...state.quests.map((q) => QuestCard(
                              quest: q,
                              onContribute: () => state.contributeToQuest(q.id),
                            )),

                      const SectionTitle('Today'),
                      if (todayTasks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Tidak ada tugas harian (Daily) untuk hari ini. Tambahkan di tab Tasks!', style: TextStyle(color: AppColors.t3, fontSize: 12)),
                        )
                      else
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

  Widget _iconBtn(String icon) {
    return Container(
      width: 34, height: 34,
      decoration: BoxDecoration(
        color: AppColors.c2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Center(
        child: Text(icon, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
}
