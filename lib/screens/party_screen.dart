import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final sorted = [...state.partyMembers]
          ..sort((a, b) => b.xp.compareTo(a.xp));

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            title: const Text('Party'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.c2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: const Center(
                  child: Text('👥', style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ── Party Card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.c2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border2, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚔️ Kelompok 6 — IF-A',
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 14,
                          color: AppColors.t1,
                        )),
                    const SizedBox(height: 4),
                    const Text('5 anggota · Quest aktif: Deadline Boss',
                        style: TextStyle(fontSize: 11, color: AppColors.t3)),
                    const SizedBox(height: 14),

                    // Boss bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('💀 Deadline Boss Lv.3',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.red)),
                        Text('1400 / 2000 HP',
                            style:
                                TextStyle(fontSize: 10, color: AppColors.t3)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: 0.70,
                        minHeight: 8,
                        backgroundColor: AppColors.red.withOpacity(0.12),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(AppColors.red),
                      ),
                    ),

                    // Members
                    const SizedBox(height: 14),
                    const Text('Party Members',
                        style: TextStyle(fontSize: 11, color: AppColors.t3)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.partyMembers.map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(99),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.07),
                                width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: m.avatarColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(m.emoji,
                                      style: const TextStyle(fontSize: 11)),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(m.name,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppColors.t1)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // ── Leaderboard ────────────────────────────────────────────
              _sectionTitle('Leaderboard'),
              ...List.generate(sorted.length, (i) {
                final m = sorted[i];
                final rank = i + 1;
                Color rankColor;
                String rankLabel;
                if (rank == 1) {
                  rankColor = AppColors.gold;
                  rankLabel = '1';
                } else if (rank == 2) {
                  rankColor = const Color(0xFFB4B2A9);
                  rankLabel = '2';
                } else if (rank == 3) {
                  rankColor = const Color(0xFFEF9F27);
                  rankLabel = '3';
                } else {
                  rankColor = AppColors.t3;
                  rankLabel = '$rank';
                }

                Color? borderColor;
                if (rank == 1) borderColor = AppColors.gold.withOpacity(0.35);
                if (rank == 2)
                  borderColor =
                      const Color(0xFFB4B2A9).withOpacity(0.3);
                if (rank == 3)
                  borderColor =
                      const Color(0xFFEF9F27).withOpacity(0.3);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: borderColor ?? AppColors.border,
                        width: 0.5),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text(rankLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Cinzel',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: rankColor,
                            )),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: m.avatarColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(m.emoji,
                              style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.t1)),
                            const SizedBox(height: 2),
                            Text(
                              'Lv.${m.level} · ${m.className} · 🔥 ${m.streak} streak',
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.t3),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${m.xp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.xp),
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 11,
              color: AppColors.t3,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(height: 0.5, color: AppColors.border),
          ),
        ],
      ),
    );
  }
}
