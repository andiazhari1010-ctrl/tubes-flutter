import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  void _showAddFriendDialog(BuildContext context, AppState state) {
    final emailCtrl = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.c1,
          title: const Text('Tambah Teman', style: TextStyle(color: AppColors.t1)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Masukkan email temanmu untuk mengirim permintaan pertemanan.',
                  style: TextStyle(fontSize: 12, color: AppColors.t3)),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                style: const TextStyle(color: AppColors.t1),
                decoration: InputDecoration(
                  hintText: 'email@contoh.com',
                  hintStyle: const TextStyle(color: AppColors.t3),
                  filled: true,
                  fillColor: AppColors.c2,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: AppColors.t3))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              onPressed: isLoading ? null : () async {
                setState(() => isLoading = true);
                try {
                  await state.sendFriendRequest(emailCtrl.text);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permintaan pertemanan terkirim!'), backgroundColor: AppColors.accent),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
                    );
                  }
                } finally {
                  if (ctx.mounted) setState(() => isLoading = false);
                }
              },
              child: isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Kirim', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final sorted = [...state.partyMembers]..sort((a, b) => b.xp.compareTo(a.xp));
        final requests = state.friendRequests;

        return Scaffold(
          backgroundColor: AppColors.c0,
          appBar: AppBar(
            title: const Text('Party & Friends'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add, color: AppColors.accent2),
                onPressed: () => _showAddFriendDialog(context, state),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (requests.isNotEmpty) ...[
                _sectionTitle('Permintaan Pertemanan'),
                ...requests.map((req) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.c2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Text(req['emoji'] ?? '👤', style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(req['name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 14, color: AppColors.t1)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            minimumSize: const Size(0, 32),
                          ),
                          onPressed: () {
                            state.acceptFriendRequest(req['uid'], req['name']);
                          },
                          child: const Text('Terima', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              _sectionTitle('Friends Leaderboard'),
              if (sorted.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('Belum ada teman. Tambahkan teman untuk bersaing XP!',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.t3)),
                  ),
                ),
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

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.c1,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: rank <= 3 ? rankColor.withOpacity(0.3) : AppColors.border, width: 0.5),
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
                        child: Center(child: Text(m.emoji, style: const TextStyle(fontSize: 18))),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.t1)),
                            const SizedBox(height: 2),
                            Text(
                              'Lv.${m.level} · ${m.className} · 🔥 ${m.streak} streak',
                              style: const TextStyle(fontSize: 10, color: AppColors.t3),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${m.xp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.xp),
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
          Expanded(child: Container(height: 0.5, color: AppColors.border)),
        ],
      ),
    );
  }
}
