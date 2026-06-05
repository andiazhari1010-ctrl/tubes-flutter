import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../services/firestore_service.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  String _period = 'Minggu ini';
  final _periods = ['Hari ini', 'Minggu ini', 'Bulan ini'];

  // Dynamic fields loaded from Firestore
  int _totalTasksCompleted = 0;
  int _totalUsersCount = 0;
  int _activeUsersCount = 0;
  int _totalXpEarned = 0;
  double _warriorRatio = 0.38;
  double _mageRatio = 0.30;
  double _rogueRatio = 0.20;
  double _healerRatio = 0.12;
  List<Map<String, String>> _dynamicTopUsers = [];

  late final StreamSubscription<QuerySnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    final service = FirestoreService();
    _subscription = service.getAllUsersStream().listen((snapshot) {
      int tasks = 0;
      int xp = 0;
      int active = 0;
      int warriorCount = 0;
      int mageCount = 0;
      int rogueCount = 0;
      int healerCount = 0;

      final usersData = snapshot.docs.map((doc) {
        final data = doc.data();
        final hero = data['hero'] as Map<String, dynamic>?;
        final email = data['email'] ?? '';
        final fullName = data['fullName'] ?? '';
        String name = 'Unknown';
        if (fullName.toString().isNotEmpty) {
          name = fullName.toString();
        } else if (email.toString().isNotEmpty) {
          name = email.toString().split('@').first;
        }

        int uXp = 0;
        int uStreak = 0;
        String heroCls = 'Warrior';
        if (hero != null) {
          uXp = (hero['xp'] ?? 0) as int;
          uStreak = (hero['streak'] ?? 0) as int;
          heroCls = hero['heroClass'] ?? 'Warrior';
        }

        tasks += (data['totalTasksCompleted'] ?? 0) as int;
        xp += uXp;
        if (uStreak > 0) active++;

        switch (heroCls.toLowerCase()) {
          case 'warrior':
            warriorCount++;
            break;
          case 'mage':
            mageCount++;
            break;
          case 'rogue':
            rogueCount++;
            break;
          case 'healer':
            healerCount++;
            break;
          default:
            warriorCount++;
            break;
        }

        return {
          'name': name,
          'class': heroCls,
          'xp': uXp,
          'streak': uStreak,
        };
      }).toList();

      // Sort and pick top 5 users
      usersData.sort((a, b) => (b['xp'] as int).compareTo(a['xp'] as int));
      final top5 = usersData.take(5).map((u) {
        String clsEmoji = '⚔️';
        String clsName = u['class'] as String;
        switch (clsName.toLowerCase()) {
          case 'warrior':
            clsEmoji = '⚔️ Warrior';
            break;
          case 'mage':
            clsEmoji = '🧙 Mage';
            break;
          case 'rogue':
            clsEmoji = '🏹 Rogue';
            break;
          case 'healer':
            clsEmoji = '💚 Healer';
            break;
          default:
            clsEmoji = '⚔️ Warrior';
            break;
        }
        return {
          'name': u['name'] as String,
          'class': clsEmoji,
          'xp': '${u['xp']} XP',
          'streak': '${u['streak']}',
        };
      }).toList();

      final totalCount = snapshot.docs.length;
      final divisor = totalCount == 0 ? 1 : totalCount;

      setState(() {
        _totalUsersCount = totalCount;
        _totalTasksCompleted = tasks;
        _totalXpEarned = xp;
        _activeUsersCount = active;
        _warriorRatio = warriorCount / divisor;
        _mageRatio = mageCount / divisor;
        _rogueRatio = rogueCount / divisor;
        _healerRatio = healerCount / divisor;
        _dynamicTopUsers = top5;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Statistik'),
        titleTextStyle: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.c2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _period,
                dropdownColor: AppColors.c2,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.t2,
                    fontWeight: FontWeight.w500),
                items: _periods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _period = v!),
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColors.t3, size: 16),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // ── KPI Cards ──────────────────────────────────────────────────
          const SectionTitle('KPI Utama'),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                    label: 'Task Selesai',
                    value: '$_totalTasksCompleted',
                    change: '+18%',
                    positive: true,
                    emoji: '✅'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                    label: 'Total User',
                    value: '$_totalUsersCount',
                    change: '+4%',
                    positive: true,
                    emoji: '👤'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                    label: 'User Aktif',
                    value: _totalUsersCount == 0 ? '0%' : '${(_activeUsersCount / _totalUsersCount * 100).toStringAsFixed(0)}%',
                    change: '+6%',
                    positive: true,
                    emoji: '🔥'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                    label: 'Total XP',
                    value: '$_totalXpEarned',
                    change: '+5%',
                    positive: true,
                    emoji: '📌'),
              ),
            ],
          ),

          // ── Task Completion Bar Chart ──────────────────────────────────
          const SectionTitle('Task Selesai per Hari'),
          _BarChartCard(
            data: [
              const _BarData(label: 'Sen', value: 0.65, count: 28),
              const _BarData(label: 'Sel', value: 0.80, count: 35),
              const _BarData(label: 'Rab', value: 0.55, count: 24),
              const _BarData(label: 'Kam', value: 0.90, count: 39),
              const _BarData(label: 'Jum', value: 1.0, count: 43),
              const _BarData(label: 'Sab', value: 0.40, count: 17),
              const _BarData(label: 'Min', value: 0.30, count: 13),
            ],
            color: AppColors.accent,
          ),

          // ── XP Earned Chart ───────────────────────────────────────────
          const SectionTitle('XP Diperoleh per Hari'),
          _BarChartCard(
            data: [
              const _BarData(label: 'Sen', value: 0.50, count: 1200),
              const _BarData(label: 'Sel', value: 0.75, count: 1800),
              const _BarData(label: 'Rab', value: 0.60, count: 1440),
              const _BarData(label: 'Kam', value: 0.85, count: 2040),
              const _BarData(label: 'Jum', value: 0.95, count: 2280),
              const _BarData(label: 'Sab', value: 0.35, count: 840),
              const _BarData(label: 'Min', value: 0.25, count: 600),
            ],
            color: AppColors.xp,
            showXp: true,
          ),

          // ── Class Distribution ────────────────────────────────────────
          const SectionTitle('Distribusi Class'),
          _ClassDistributionCard(
            warriorRatio: _warriorRatio,
            mageRatio: _mageRatio,
            rogueRatio: _rogueRatio,
            healerRatio: _healerRatio,
          ),

          // ── Top Users ─────────────────────────────────────────────────
          const SectionTitle('Top 5 User Minggu Ini'),
          ..._dynamicTopUsers.asMap().entries.map(
                (e) => _TopUserTile(rank: e.key + 1, data: e.value),
              ),

          // ── Reports ───────────────────────────────────────────────────
          const SectionTitle('Laporan Masuk'),
          const _ReportCard(
            emoji: '🚩',
            title: 'Konten tidak pantas',
            sub: 'Dilaporkan oleh 2 user · Perlu ditinjau',
            urgent: true,
          ),
          const _ReportCard(
            emoji: '⚠️',
            title: 'Bug: HP tidak berkurang',
            sub: 'Dilaporkan 1x · Class Healer',
            urgent: false,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────────
class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool positive;
  final String emoji;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.change,
    required this.positive,
    required this.emoji,
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: positive
                      ? AppColors.xp.withValues(alpha: 0.12)
                      : AppColors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(change,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: positive ? AppColors.xp : AppColors.red)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.t1,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10, color: AppColors.t3)),
        ],
      ),
    );
  }
}

// ── Bar Data ──────────────────────────────────────────────────────────────────
class _BarData {
  final String label;
  final double value; // 0.0–1.0
  final int count;
  const _BarData(
      {required this.label, required this.value, required this.count});
}

// ── Bar Chart Card ────────────────────────────────────────────────────────────
class _BarChartCard extends StatelessWidget {
  final List<_BarData> data;
  final Color color;
  final bool showXp;

  const _BarChartCard({
    required this.data,
    required this.color,
    this.showXp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.c2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((d) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          showXp
                              ? '${(d.count / 1000).toStringAsFixed(1)}k'
                              : '${d.count}',
                          style: TextStyle(
                              fontSize: 8,
                              color: color,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 80 * d.value,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: data.map((d) {
              return Expanded(
                child: Text(d.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9, color: AppColors.t3)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Class Distribution Card ───────────────────────────────────────────────────
class _ClassDistributionCard extends StatelessWidget {
  final double warriorRatio;
  final double mageRatio;
  final double rogueRatio;
  final double healerRatio;

  const _ClassDistributionCard({
    required this.warriorRatio,
    required this.mageRatio,
    required this.rogueRatio,
    required this.healerRatio,
  });

  @override
  Widget build(BuildContext context) {
    final classes = [
      ('⚔️', 'Warrior', warriorRatio, AppColors.accent),
      ('🧙', 'Mage', mageRatio, const Color(0xFF185FA5)),
      ('🏹', 'Rogue', rogueRatio, AppColors.gold),
      ('💚', 'Healer', healerRatio, AppColors.xp),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.c2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: classes.map((c) {
          final (emoji, name, ratio, color) = c;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 54,
                  child: Text(name,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.t2)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppColors.c3,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 32,
                  child: Text('${(ratio * 100).round()}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Top User Tile ─────────────────────────────────────────────────────────────
class _TopUserTile extends StatelessWidget {
  final int rank;
  final Map<String, String> data;
  const _TopUserTile({required this.rank, required this.data});

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    if (rank == 1) {
      rankColor = AppColors.gold;
    } else if (rank == 2) {
      rankColor = const Color(0xFFB4B2A9);
    } else if (rank == 3) {
      rankColor = const Color(0xFFEF9F27);
    } else {
      rankColor = AppColors.t3;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? rankColor.withValues(alpha: 0.3) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$rank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: rankColor,
                )),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['name']!,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                Text(data['class']!,
                    style: TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data['xp']!,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.xp)),
              Text('🔥 ${data['streak']!} streak',
                  style: TextStyle(fontSize: 9, color: AppColors.gold2)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Report Card ───────────────────────────────────────────────────────────────
class _ReportCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String sub;
  final bool urgent;

  const _ReportCard({
    required this.emoji,
    required this.title,
    required this.sub,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    final color = urgent ? AppColors.red : AppColors.gold;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                Text(sub,
                    style: TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(urgent ? 'Urgent' : 'Review',
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}