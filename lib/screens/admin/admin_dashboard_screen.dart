import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../auth_wrapper.dart';

// Custom widget for section titles
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirestoreService().getAllUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.c0,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🔒', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Izin Database Ditolak',
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          color: AppColors.gold,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase memblokir akses ke database. Harap salin file rules lokal Anda (firestore.rules) ke menu Rules di Firebase Console online agar akun ini diizinkan sebagai Admin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.t3, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .set({
                                  'email': user.email ?? 'admin@gmail.com',
                                  'role': 'admin',
                                  'username': (user.email ?? 'admin').split('@').first,
                                  'fullName': user.displayName ?? 'Admin Hero',
                                }, SetOptions(merge: true));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Berhasil mengklaim hak akses Admin! Silakan muat ulang halaman.'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal mengklaim: Pastikan rules di Firebase Console sudah di-Publish. ($e)'),
                                backgroundColor: AppColors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold),
                      child: const Text('Klaim Hak Akses Admin Database', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                      child: Text('Kembali ke Login', style: TextStyle(color: AppColors.t3)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.c0,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data!.docs;
        final totalUsers = docs.length;
        int totalTasks = 0;
        int totalXp = 0;
        int activeUsers = 0;
        List<Map<String, String>> recent = [];
        // Process each user document
        for (var doc in docs) {
          final data = doc.data();
          totalTasks += (data['totalTasksCompleted'] ?? 0) as int;
          final hero = data['hero'] as Map<String, dynamic>?;
          if (hero != null) {
            totalXp += (hero['xp'] ?? 0) as int;
            if ((hero['streak'] ?? 0) as int > 0) activeUsers++;
          }
        }
        // Recent activity: newest users by createdAt
        final sorted =
            docs.where((d) => (d.data())['createdAt'] != null).toList();
        sorted.sort((a, b) {
          final at = (a.data())['createdAt'] as Timestamp;
          final bt = (b.data())['createdAt'] as Timestamp;
          return bt.compareTo(at);
        });
        for (var doc in sorted.take(5)) {
          final data = doc.data();
          recent.add({
            'emoji': '👤',
            'title': 'User baru terdaftar',
            'sub': data['email'] ?? 'unknown',
            'time': 'baru',
          });
        }
        return Scaffold(
          backgroundColor: AppColors.c0,
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar (unchanged)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Panel',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.t3,
                                  fontWeight: FontWeight.w500)),
                          Text('HeroQuest 🛡️',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                      Row(
                        children: [
                          _iconBtn('🔔'),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showLogoutDialog(context),
                            child: _iconBtn('🚪'),
                          ),
                          const SizedBox(width: 8),
                          _adminAvatar()
                        ],
                      ),
                    ],
                  ),
                ),
                // Admin Badge Banner (unchanged)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.3),
                          width: 0.5)),
                  child: Row(
                    children: [
                      Text('🛡️', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      Expanded(
                          child: Text('Anda masuk sebagai Administrator',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w500))),
                      Text('Kelompok 6',
                          style: TextStyle(fontSize: 10, color: AppColors.t3)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SectionTitle('Ringkasan Platform'),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
                        children: [
                          _StatCard(
                              emoji: '👥',
                              value: '$totalUsers',
                              label: 'Total User',
                              sub: '+$totalUsers baru',
                              valueColor: AppColors.accent2),
                          _StatCard(
                              emoji: '✅',
                              value: '$totalTasks',
                              label: 'Task Selesai',
                              sub: '+$totalTasks hari ini',
                              valueColor: AppColors.xp),
                          _StatCard(
                              emoji: '🔥',
                              value:
                                  '${(activeUsers / (totalUsers == 0 ? 1 : totalUsers) * 100).toStringAsFixed(0)}%',
                              label: 'User Aktif',
                              sub: '$activeUsers dari $totalUsers',
                              valueColor: AppColors.gold),
                          _StatCard(
                              emoji: '⚔️',
                              value: '$totalXp',
                              label: 'Total XP',
                              sub: '',
                              valueColor: AppColors.accent),
                        ],
                      ),
                      const SectionTitle('Aksi Cepat'),
                      Row(
                        children: [
                          Expanded(
                              child: _QuickAction(
                                  emoji: '➕',
                                  label: 'Tambah Quest',
                                  color: AppColors.accent,
                                  onTap: () {})),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _QuickAction(
                                  emoji: '💀',
                                  label: 'Spawn Boss',
                                  color: AppColors.red,
                                  onTap: () {})),
                          const SizedBox(width: 10),
                          Expanded(
                              child: _QuickAction(
                                  emoji: '📢',
                                  label: 'Broadcast',
                                  color: AppColors.gold,
                                  onTap: () {})),
                        ],
                      ),
                      const SectionTitle('Aktivitas Terbaru'),
                      ...recent.map((a) => _ActivityTile(data: a)),
                      const SectionTitle('Status Boss Aktif'),
                      _BossStatusCard(
                          name: 'Deadline Boss Lv.3',
                          hp: 1400,
                          maxHp: 2000,
                          parties: 3,
                          color: AppColors.red),
                      _BossStatusCard(
                          name: 'UTS Boss Lv.2',
                          hp: 800,
                          maxHp: 1500,
                          parties: 2,
                          color: AppColors.gold),
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
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.c2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Center(child: Text(icon, style: const TextStyle(fontSize: 15))),
    );
  }

  Widget _adminAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4), width: 0.5),
      ),
      child: const Center(
        child: Text('🛡️', style: TextStyle(fontSize: 15)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.c2,
        title: Text('Keluar dari Admin?', style: TextStyle(fontFamily: 'Cinzel', color: AppColors.t1, fontSize: 16)),
        content: Text('Apakah Anda yakin ingin keluar dari Panel Admin?', style: TextStyle(color: AppColors.t2, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: AppColors.t3)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final String sub;
  final Color valueColor;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.sub,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.c2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              Text(value,
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  )),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.t1)),
              const SizedBox(height: 2),
              Text(sub,
                  style: TextStyle(fontSize: 9, color: AppColors.t3)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Action ─────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Activity Tile ─────────────────────────────────────────────────────────────
class _ActivityTile extends StatelessWidget {
  final Map<String, String> data;
  const _ActivityTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Text(data['emoji']!, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title']!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                Text(data['sub']!,
                    style: TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Text(data['time']!,
              style: TextStyle(fontSize: 10, color: AppColors.t3)),
        ],
      ),
    );
  }
}

// ── Boss Status Card ──────────────────────────────────────────────────────────
class _BossStatusCard extends StatelessWidget {
  final String name;
  final int hp;
  final int maxHp;
  final int parties;
  final Color color;

  const _BossStatusCard({
    required this.name,
    required this.hp,
    required this.maxHp,
    required this.parties,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = hp / maxHp;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💀', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(name,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: color)),
                ],
              ),
              Text('$hp / $maxHp HP',
                  style: TextStyle(fontSize: 10, color: AppColors.t3)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(ratio * 100).round()}% HP tersisa',
                  style: TextStyle(fontSize: 10, color: AppColors.t3)),
              Text('$parties party terlibat',
                  style: TextStyle(fontSize: 10, color: AppColors.t3)),
            ],
          ),
        ],
      ),
    );
  }
}