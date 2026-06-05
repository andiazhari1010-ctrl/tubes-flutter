import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final sorted = [...state.allUsers]
          ..sort((a, b) => b.xp.compareTo(a.xp));

        final hasParty = state.partyId != null && state.partyId!.isNotEmpty;

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
              if (!hasParty)
                _buildNoPartyWidget(context, state)
              else
                // ── Party Card ─────────────────────────────────────────────
                Builder(builder: (context) {
                  final activeBosses = state.globalBosses.where((b) => b.progress > 0).toList();
                  final activeBoss = activeBosses.isNotEmpty ? activeBosses.first : null;
                  final hpValue = activeBoss != null ? (activeBoss.progress / 100) : 0.0;
                  final hpText = activeBoss != null ? "${(activeBoss.progress / 100 * 2000).round()} / 2000 HP" : "0 / 2000 HP";

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.c2,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border2, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('⚔️ ${state.partyName ?? "No Party"}',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 14,
                                    color: AppColors.t1,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            GestureDetector(
                              onTap: () => _showLeavePartyDialog(context, state),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.red.withValues(alpha: 0.3), width: 0.5),
                                ),
                                child: Text(
                                  state.isPartyLeader ? 'Disband' : 'Keluar',
                                  style: TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${state.partyMembers.length} anggota · Quest aktif: ${activeBoss?.title ?? "Tidak ada"}',
                            style: TextStyle(fontSize: 11, color: AppColors.t3)),
                        const SizedBox(height: 14),

                        // Boss bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('💀 ${activeBoss?.title ?? "Tidak ada Boss"}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.red)),
                            Text(hpText,
                                style:
                                    TextStyle(fontSize: 10, color: AppColors.t3)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: hpValue,
                            minHeight: 8,
                            backgroundColor: AppColors.red.withValues(alpha: 0.12),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.red),
                          ),
                        ),
                        if (activeBoss != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                state.attackGlobalBoss(activeBoss.id);
                              },
                              icon: const Text('💥', style: TextStyle(fontSize: 14)),
                              label: const Text(
                                'SERANG BOSS (-10% HP)',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],

                        // Members
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Party Members',
                                style: TextStyle(fontSize: 11, color: AppColors.t3)),
                            if (state.isPartyLeader)
                              GestureDetector(
                                onTap: () => _showInviteSheet(context, state),
                                child: Text('+ Undang',
                                    style: TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.partyMembers.map((m) {
                            final isMe = m.uid == (FirebaseAuth.instance.currentUser?.uid ?? '');
                            return Container(
                              padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.07),
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
                                      style: TextStyle(
                                          fontSize: 11, color: AppColors.t1)),
                                  if (state.isPartyLeader && !isMe) ...[
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => state.removeMember(m.uid),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: AppColors.red.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text('❌', style: TextStyle(fontSize: 8)),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),

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
                if (rank == 1) borderColor = AppColors.gold.withValues(alpha: 0.35);
                if (rank == 2) {
                  borderColor =
                      const Color(0xFFB4B2A9).withValues(alpha: 0.3);
                }
                if (rank == 3) {
                  borderColor =
                      const Color(0xFFEF9F27).withValues(alpha: 0.3);
                }

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
                          color: m.avatarColor.withValues(alpha: 0.2),
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
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.t1)),
                            const SizedBox(height: 2),
                            Text(
                              'Lv.${m.level} · ${m.className} · 🔥 ${m.streak} streak',
                              style: TextStyle(
                                  fontSize: 10, color: AppColors.t3),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        m.xp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                        style: TextStyle(
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

  Widget _buildNoPartyWidget(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: 'Kelompok 6 — IF-A');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Invitations section (if any)
        if (state.pendingInvites.isNotEmpty) ...[
          _sectionTitle('Undangan Party'),
          ...state.pendingInvites.map((inv) {
            final leaderName = state.getLeaderName(inv['leaderId'] ?? '');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.c2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('🏰', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inv['name'] ?? 'Party', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.t1)),
                        const SizedBox(height: 2),
                        Text('Diundang oleh: $leaderName', style: TextStyle(fontSize: 10, color: AppColors.t3)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => state.acceptInvite(inv['partyId']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 0.5),
                          ),
                          child: const Text('Terima', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => state.declineInvite(inv['partyId']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.red.withValues(alpha: 0.3), width: 0.5),
                          ),
                          child: Text('Tolak', style: TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
        ],

        // Create Party section
        _sectionTitle('Buat Party Baru'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.c2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🏰 Buat Kelompok Petualangmu',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 13,
                    color: AppColors.t1,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 4),
              Text('Undang teman-temanmu untuk menyelesaikan Boss dan Quest bersama!',
                  style: TextStyle(fontSize: 10, color: AppColors.t3)),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                style: TextStyle(fontSize: 13, color: AppColors.t1),
                decoration: InputDecoration(
                  hintText: 'Nama Party...',
                  hintStyle: TextStyle(color: AppColors.t3),
                  filled: true,
                  fillColor: AppColors.c1,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border, width: 0.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gold, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isNotEmpty) {
                      state.createParty(name);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('Buat Party', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLeavePartyDialog(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.c2,
        title: Text(state.isPartyLeader ? 'Bubarkan Party?' : 'Keluar dari Party?',
            style: TextStyle(fontFamily: 'Cinzel', color: AppColors.t1, fontSize: 16)),
        content: Text(state.isPartyLeader 
            ? 'Apakah Anda yakin ingin membubarkan Party ini? Semua anggota akan dikeluarkan.' 
            : 'Apakah Anda yakin ingin keluar dari Party ini?', 
            style: TextStyle(color: AppColors.t2, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.t3)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () {
              Navigator.pop(ctx);
              state.leaveParty();
            },
            child: Text(state.isPartyLeader ? 'Bubarkan' : 'Keluar', 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context, AppState state) {
    final currentMemberIds = state.partyMemberIds;
    final availableUsers = state.allUsers.where((u) => !currentMemberIds.contains(u.uid)).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
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
              'Undang Anggota',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 16,
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (availableUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Tidak ada pengguna lain yang tersedia untuk diundang.',
                    style: TextStyle(fontSize: 12, color: AppColors.t3),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: availableUsers.length,
                  itemBuilder: (context, index) {
                    final u = availableUsers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.c1,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30, height: 30,
                            decoration: BoxDecoration(
                              color: u.avatarColor.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(child: Text(u.emoji, style: const TextStyle(fontSize: 14))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(u.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.t1)),
                                Text('Lv.${u.level} · ${u.className}', style: TextStyle(fontSize: 9, color: AppColors.t3)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              state.inviteUser(u.uid);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text('Undang', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
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