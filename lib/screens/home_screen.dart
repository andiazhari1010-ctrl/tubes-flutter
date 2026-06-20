import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';
import 'shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final hero = state.hero;
        final todayWeekday = DateTime.now().weekday;
        // Daily yang jadwalnya hari ini + To-Do bertanda "Hari ini".
        final todayDailies =
            state.dailyTasks.where((t) => t.isActiveOn(todayWeekday)).toList();
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
                          Text('Selamat pagi,',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.t3,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            '${hero.name.split(' ').first} ${hero.classEmoji}',
                            style: TextStyle(
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
                              _iconBtn(
                                '🔔',
                                onTap: () {
                                  state.markNotificationsAsRead();
                                  _showNotificationsSheet(context, state);
                                },
                              ),
                              if (state.hasUnreadNotifications)
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
                                      child: Center(
                                        child: Text(hero.classEmoji,
                                            style:
                                                const TextStyle(fontSize: 26)),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(hero.name,
                                          style: TextStyle(
                                            fontFamily: 'Cinzel',
                                            fontSize: 14,
                                            color: AppColors.t1,
                                          )),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${hero.classEmoji} ${hero.className} · ${state.partyName ?? "No Party"}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.accent2,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _showStatsExplanation(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
                                    ),
                                    child: const Text('ℹ️', style: TextStyle(fontSize: 12)),
                                  ),
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
                            
                            // Momentum Glowing Bar
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    child: Text('MM',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF00E5FF))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(99),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                                                blurRadius: 6,
                                                spreadRadius: 0.5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(99),
                                          child: LinearProgressIndicator(
                                            value: hero.momentum / 100.0,
                                            minHeight: 6,
                                            backgroundColor: Colors.white.withValues(alpha: 0.07),
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 70,
                                    child: Text(
                                      '${hero.momentum}%${state.momentumMultiplier > 1.0 ? " (x${state.momentumMultiplier})" : ""}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 9, 
                                          fontWeight: FontWeight.w700, 
                                          color: Color(0xFF00E5FF)),
                                    ),
                                  ),
                                ],
                              ),
                            ),

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

                      const SizedBox(height: 12),
                      // ── Daily Streak Claim Card ────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.c2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: state.hasClaimedDaily 
                                ? AppColors.border 
                                : AppColors.gold.withValues(alpha: 0.4),
                            width: 0.5,
                          ),
                          boxShadow: state.hasClaimedDaily ? [] : [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.05),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              state.hasClaimedDaily ? '📆' : '🔥',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.hasClaimedDaily 
                                        ? 'DAILY STREAK CLAIMED' 
                                        : 'DAILY STREAK READY!',
                                    style: TextStyle(
                                      fontFamily: 'Cinzel',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: state.hasClaimedDaily 
                                          ? AppColors.t2 
                                          : AppColors.gold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.hasClaimedDaily
                                        ? 'Kembali besok untuk mempertahankan streak Anda.'
                                        : 'Klaim hadiah streak harian Anda sekarang!',
                                    style: TextStyle(fontSize: 9, color: AppColors.t3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!state.hasClaimedDaily)
                              GestureDetector(
                                onTap: () => state.claimDailyReward(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.gold, Color(0xFFFF9800)],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'KLAIM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2A1A00),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.c1,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border, width: 0.5),
                                ),
                                child: Text(
                                  'SELESAI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.t3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SectionTitle('Active Quest'),
                      ...state.quests
                          .where((q) => !state.globalQuests.any((gq) => gq.id == q.id) && !state.globalBosses.any((gb) => gb.id == q.id))
                          .map((q) => QuestCard(quest: q)),

                      const SectionTitle('Quest Komunitas & Boss'),
                      if (state.globalQuests.where((q) => q.progress > 0).isEmpty &&
                          state.globalBosses.where((b) => b.progress > 0).isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Tidak ada Quest Komunitas atau Boss aktif',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.t3,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else ...[
                        ...state.globalQuests
                            .where((gq) => gq.progress > 0)
                            .map((gq) {
                              final userQuest = state.quests.firstWhere(
                                (q) => q.id == gq.id,
                                orElse: () => QuestModel(
                                  id: gq.id,
                                  title: gq.title,
                                  progress: 0,
                                  xpReward: gq.xpReward,
                                  timeLeft: gq.timeLeft,
                                  isBoss: gq.isBoss,
                                ),
                              );
                              return QuestCard(quest: userQuest);
                            }),
                        ...state.globalBosses
                            .where((b) => b.progress > 0)
                            .map((b) => QuestCard(quest: b)),
                      ],

                      SectionTitle('Today · ${_dayName(todayWeekday)}'),
                      if (todayDailies.isEmpty && todayTasks.isEmpty)
                        _todayEmpty()
                      else ...[
                        ...todayDailies.map((t) => TaskItem(
                              task: t,
                              onTap: () => state.toggleTask(t),
                            )),
                        ...todayTasks.map((t) => TaskItem(
                              task: t,
                              onTap: () => state.toggleTask(t),
                            )),
                      ],

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

  String _dayName(int weekday) {
    const names = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return names[(weekday - 1) % 7];
  }

  Widget _todayEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.c1.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          const Text('🌙', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text('Tidak ada agenda hari ini',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.t2)),
          const SizedBox(height: 3),
          Text('Daily yang dijadwalkan hari ini akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.t3, height: 1.4)),
        ],
      ),
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

  void _showNotificationsSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<AppState>(
          builder: (context, state, _) {
            final list = state.notificationHistory;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.t3,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PEMBERITAHUAN',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (list.isNotEmpty)
                        GestureDetector(
                          onTap: () => state.clearNotifications(),
                          child: Text(
                            'Bersihkan',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🔔', style: TextStyle(fontSize: 32)),
                                const SizedBox(height: 10),
                                Text(
                                  'Tidak ada notifikasi baru',
                                  style: TextStyle(color: AppColors.t3, fontSize: 12, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) => Divider(color: AppColors.border, height: 1, thickness: 0.5),
                            itemBuilder: (context, index) {
                              final msg = list[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    const Text('🔔', style: TextStyle(fontSize: 16)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        msg,
                                        style: TextStyle(color: AppColors.t1, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStatsExplanation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.t3,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'STATUS HERO & STATS',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              _statExplainRow('❤️ HP (Health Points)', 'Kesehatan Hero Anda. HP berkurang jika Anda mengabaikan quest/boss, dan dapat dipulihkan dengan ramuan (potion) dari toko.'),
              const SizedBox(height: 12),
              _statExplainRow('✨ XP (Experience Points)', 'Poin Pengalaman. Kumpulkan 100 XP untuk naik level. XP akan tereset ke 0 setelah level naik.'),
              const SizedBox(height: 12),
              _statExplainRow('🧪 MP (Mana Points)', 'Mana / Energi Hero. Digunakan untuk beraktivitas atau menggunakan skill khusus tertentu.'),
              const SizedBox(height: 12),
              _statExplainRow('⚡ MM (Momentum)', 'Productivity Momentum. Pengali XP/Gold (hingga x1.5) berdasarkan keaktifan Anda menyelesaikan tugas hari ini.'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _statExplainRow(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: AppColors.t1, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(description, style: TextStyle(color: AppColors.t3, fontSize: 10, height: 1.4)),
      ],
    );
  }
}