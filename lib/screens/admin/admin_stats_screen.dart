import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminStatsScreen extends StatefulWidget {
  const AdminStatsScreen({super.key});

  @override
  State<AdminStatsScreen> createState() => _AdminStatsScreenState();
}

class _AdminStatsScreenState extends State<AdminStatsScreen> {
  String _period = 'Minggu ini';
  final _periods = ['Hari ini', 'Minggu ini', 'Bulan ini'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Statistik'),
        titleTextStyle: const TextStyle(
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
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.t2,
                    fontWeight: FontWeight.w500),
                items: _periods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _period = v!),
                icon: const Icon(Icons.keyboard_arrow_down,
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
                    value: '230',
                    change: '+18%',
                    positive: true,
                    emoji: '✅'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                    label: 'User Baru',
                    value: '12',
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
                    label: 'Habit Rate',
                    value: '74%',
                    change: '-2%',
                    positive: false,
                    emoji: '🔥'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KpiCard(
                    label: 'Retensi',
                    value: '68%',
                    change: '+5%',
                    positive: true,
                    emoji: '📌'),
              ),
            ],
          ),

          // ── Task Completion Bar Chart ──────────────────────────────────
          const SectionTitle('Task Selesai per Hari'),
          _BarChartCard(
            data: const [
              _BarData(label: 'Sen', value: 0.65, count: 28),
              _BarData(label: 'Sel', value: 0.80, count: 35),
              _BarData(label: 'Rab', value: 0.55, count: 24),
              _BarData(label: 'Kam', value: 0.90, count: 39),
              _BarData(label: 'Jum', value: 1.0, count: 43),
              _BarData(label: 'Sab', value: 0.40, count: 17),
              _BarData(label: 'Min', value: 0.30, count: 13),
            ],
            color: AppColors.accent,
          ),

          // ── XP Earned Chart ───────────────────────────────────────────
          const SectionTitle('XP Diperoleh per Hari'),
          _BarChartCard(
            data: const [
              _BarData(label: 'Sen', value: 0.50, count: 1200),
              _BarData(label: 'Sel', value: 0.75, count: 1800),
              _BarData(label: 'Rab', value: 0.60, count: 1440),
              _BarData(label: 'Kam', value: 0.85, count: 2040),
              _BarData(label: 'Jum', value: 0.95, count: 2280),
              _BarData(label: 'Sab', value: 0.35, count: 840),
              _BarData(label: 'Min', value: 0.25, count: 600),
            ],
            color: AppColors.xp,
            showXp: true,
          ),

          // ── Class Distribution ────────────────────────────────────────
          const SectionTitle('Distribusi Class'),
          _ClassDistributionCard(),

          // ── Top Users ─────────────────────────────────────────────────
          const SectionTitle('Top 5 User Minggu Ini'),
          ..._topUsers.asMap().entries.map(
                (e) => _TopUserTile(rank: e.key + 1, data: e.value),
              ),

          // ── Reports ───────────────────────────────────────────────────
          const SectionTitle('Laporan Masuk'),
          _ReportCard(
            emoji: '🚩',
            title: 'Konten tidak pantas',
            sub: 'Dilaporkan oleh 2 user · Perlu ditinjau',
            urgent: true,
          ),
          _ReportCard(
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
                      ? AppColors.xp.withOpacity(0.12)
                      : AppColors.red.withOpacity(0.12),
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
              style: const TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.t1,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: AppColors.t3)),
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
                            color: color.withOpacity(0.7),
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
                    style: const TextStyle(fontSize: 9, color: AppColors.t3)),
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
  const _ClassDistributionCard();

  @override
  Widget build(BuildContext context) {
    final classes = [
      ('⚔️', 'Warrior', 0.38, AppColors.accent),
      ('🧙', 'Mage', 0.30, const Color(0xFF185FA5)),
      ('🏹', 'Rogue', 0.20, AppColors.gold),
      ('💚', 'Healer', 0.12, AppColors.xp),
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
                      style: const TextStyle(
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

// ── Top Users ─────────────────────────────────────────────────────────────────
final _topUsers = [
  {'name': 'Zhielton', 'class': '🧙 Mage', 'xp': '4,200 XP', 'streak': '14'},
  {'name': 'Lingga', 'class': '⚔️ Warrior', 'xp': '3,580 XP', 'streak': '7'},
  {'name': 'Yafi', 'class': '🏹 Rogue', 'xp': '3,100 XP', 'streak': '5'},
  {'name': 'Agus M.', 'class': '🧙 Mage', 'xp': '2,800 XP', 'streak': '4'},
  {'name': 'Andy', 'class': '⚔️ Warrior', 'xp': '2,560 XP', 'streak': '3'},
];

class _TopUserTile extends StatelessWidget {
  final int rank;
  final Map<String, String> data;
  const _TopUserTile({required this.rank, required this.data});

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    if (rank == 1)
      rankColor = AppColors.gold;
    else if (rank == 2)
      rankColor = const Color(0xFFB4B2A9);
    else if (rank == 3)
      rankColor = const Color(0xFFEF9F27);
    else
      rankColor = AppColors.t3;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? rankColor.withOpacity(0.3) : AppColors.border,
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
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                Text(data['class']!,
                    style: const TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(data['xp']!,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.xp)),
              Text('🔥 ${data['streak']!} streak',
                  style: const TextStyle(fontSize: 9, color: AppColors.gold2)),
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
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
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
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                Text(sub,
                    style: const TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
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
