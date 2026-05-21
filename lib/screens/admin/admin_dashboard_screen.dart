import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

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
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: AppColors.c0,
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final docs = snapshot.data!.docs;
        final totalUsers = docs.length;
        int totalTasks = 0;
        int totalQuests = 0;
        int totalXp = 0;
        int activeUsers = 0;
        List<Map<String, String>> recent = [];
        // Process each user document
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalTasks += (data['totalTasksCompleted'] ?? 0) as int;
          totalQuests += (data['totalQuestsCompleted'] ?? 0) as int;
          final hero = data['hero'] as Map<String, dynamic>?;
          if (hero != null) {
            totalXp += (hero['xp'] ?? 0) as int;
            if ((hero['streak'] ?? 0) as int > 0) activeUsers++;
          }
        }
        // Recent activity: newest users by createdAt
        final sorted = docs.where((d) => (d.data() as Map<String, dynamic>)['createdAt'] != null).toList();
        sorted.sort((a, b) {
          final at = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
          final bt = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp;
          return bt.compareTo(at);
        });
        for (var doc in sorted.take(5)) {
          final data = doc.data() as Map<String, dynamic>;
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Admin Panel', style: TextStyle(fontSize: 11, color: AppColors.t3, fontWeight: FontWeight.w500)),
                          Text('HeroQuest 🛡️', style: TextStyle(fontFamily: 'Cinzel', fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.5)),
                        ],
                      ),
                      Row(
                        children: [_iconBtn('🔔'), const SizedBox(width: 8), _adminAvatar()],
                      ),
                    ],
                  ),
                ),
                // Admin Badge Banner (unchanged)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.07), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 0.5)),
                  child: Row(
                    children: const [
                      Text('🛡️', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 10),
                      Expanded(child: Text('Anda masuk sebagai Administrator', style: TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w500))),
                      Text('Kelompok 6', style: TextStyle(fontSize: 10, color: AppColors.t3)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      SectionTitle('Ringkasan Platform'),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
                        children: [
                          _StatCard(emoji: '👥', value: '$totalUsers', label: 'Total User', sub: '+$totalUsers baru', valueColor: AppColors.accent2),
                          _StatCard(emoji: '✅', value: '$totalTasks', label: 'Task Selesai', sub: '+$totalTasks hari ini', valueColor: AppColors.xp),
                          _StatCard(emoji: '🔥', value: '${(activeUsers / (totalUsers == 0 ? 1 : totalUsers) * 100).toStringAsFixed(0)}%', label: 'User Aktif', sub: '$activeUsers dari $totalUsers', valueColor: AppColors.gold),
                          _StatCard(emoji: '⚔️', value: '$totalXp', label: 'Total XP', sub: '', valueColor: AppColors.accent),
                        ],
                      ),
                       SectionTitle('Aksi Cepat'),
                      Row(
                        children: [
                          Expanded(child: _QuickAction(emoji: '➕', label: 'Tambah Quest', color: AppColors.accent, onTap: () {})),
                          const SizedBox(width: 10),
                          Expanded(child: _QuickAction(emoji: '💀', label: 'Spawn Boss', color: AppColors.red, onTap: () {})),
                          const SizedBox(width: 10),
                          Expanded(child: _QuickAction(emoji: '📢', label: 'Broadcast', color: AppColors.gold, onTap: () {})),
                        ],
                      ),
                       SectionTitle('Aktivitas Terbaru'),
                      ...recent.map((a) => _ActivityTile(data: a)),
                       SectionTitle('Status Boss Aktif'),
                      _BossStatusCard(name: 'Deadline Boss Lv.3', hp: 1400, maxHp: 2000, parties: 3, color: AppColors.red),
                      _BossStatusCard(name: 'UTS Boss Lv.2', hp: 800, maxHp: 1500, parties: 2, color: AppColors.gold),
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
        color: AppColors.gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 0.5),
      ),
      child: const Center(
        child: Text('🛡️', style: TextStyle(fontSize: 15)),
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
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.t1)),
              const SizedBox(height: 2),
              Text(sub,
                  style: const TextStyle(fontSize: 9, color: AppColors.t3)),
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
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 0.5),
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
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                Text(data['sub']!,
                    style: const TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Text(data['time']!,
              style: const TextStyle(fontSize: 10, color: AppColors.t3)),
        ],
      ),
    );
  }
}

final _recentActivity = [
  {
    'emoji': '👤',
    'title': 'User baru terdaftar',
    'sub': 'agus.mahendra@student.telkomuniversity.ac.id',
    'time': '2m lalu'
  },
  {
    'emoji': '⚔️',
    'title': 'Party baru dibentuk',
    'sub': 'Kelompok 7 — IF-B bergabung',
    'time': '15m lalu'
  },
  {
    'emoji': '💀',
    'title': 'Boss dikalahkan',
    'sub': 'Quiz Boss Lv.1 · Kelompok 3',
    'time': '1j lalu'
  },
  {
    'emoji': '🛒',
    'title': 'Item dibeli',
    'sub': 'XP Scroll · Lingga the Brave',
    'time': '2j lalu'
  },
  {
    'emoji': '🚩',
    'title': 'Laporan masuk',
    'sub': 'Konten tidak pantas · perlu ditinjau',
    'time': '3j lalu'
  },
];

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
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
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
                  style: const TextStyle(fontSize: 10, color: AppColors.t3)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 5,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(ratio * 100).round()}% HP tersisa',
                  style: const TextStyle(fontSize: 10, color: AppColors.t3)),
              Text('$parties party terlibat',
                  style: const TextStyle(fontSize: 10, color: AppColors.t3)),
            ],
          ),
        ],
      ),
    );
  }
}
