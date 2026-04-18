import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key});

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Manajemen Konten'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
        actions: [
          GestureDetector(
            onTap: () => _showAddDialog(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.gold.withOpacity(0.3), width: 0.5),
              ),
              child: const Center(
                child: Text('➕', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColors.gold,
          unselectedLabelColor: AppColors.t3,
          labelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3),
          tabs: const [
            Tab(text: 'QUEST'),
            Tab(text: 'BOSS'),
            Tab(text: 'ITEM SHOP'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _QuestTab(onAdd: () => _showAddDialog(context)),
          _BossTab(onAdd: () => _showAddDialog(context)),
          _ItemTab(onAdd: () => _showAddDialog(context)),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final xpCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 36,
        ),
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
            const Text('Tambah Konten Baru',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppColors.gold,
                )),
            const SizedBox(height: 16),
            _buildInput(titleCtrl, 'Nama / Judul konten', Icons.title),
            const SizedBox(height: 10),
            _buildInput(xpCtrl, 'XP Reward', Icons.star_outline,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: const Color(0xFF2A1A00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Simpan Konten',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13, color: AppColors.t1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.t3),
        prefixIcon: Icon(icon, color: AppColors.t3, size: 18),
        filled: true,
        fillColor: AppColors.c1,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1),
        ),
      ),
    );
  }
}

// ── Quest Tab ─────────────────────────────────────────────────────────────────
class _QuestTab extends StatefulWidget {
  final VoidCallback onAdd;
  const _QuestTab({required this.onAdd});

  @override
  State<_QuestTab> createState() => _QuestTabState();
}

class _QuestTabState extends State<_QuestTab> {
  final List<_ContentItem> _quests = [
    _ContentItem(
        emoji: '📚',
        title: 'UTS Pemrograman Mobile',
        sub: 'Aktif · 3 hari tersisa · 200 XP',
        isActive: true),
    _ContentItem(
        emoji: '🧪',
        title: 'Laporan Praktikum Jaringan',
        sub: 'Aktif · 5 hari tersisa · 150 XP',
        isActive: true),
    _ContentItem(
        emoji: '📝',
        title: 'Quiz Basis Data',
        sub: 'Nonaktif · Draft',
        isActive: false),
    _ContentItem(
        emoji: '🎯',
        title: 'Project Akhir RPL',
        sub: 'Aktif · 14 hari tersisa · 500 XP',
        isActive: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(
            active: _quests.where((q) => q.isActive).length,
            total: _quests.length,
            label: 'Quest'),
        const SizedBox(height: 12),
        ..._quests.map((q) => _ContentCard(
              item: q,
              accentColor: AppColors.accent,
              onToggle: () => setState(() => q.isActive = !q.isActive),
              onDelete: () => setState(() => _quests.remove(q)),
            )),
      ],
    );
  }
}

// ── Boss Tab ──────────────────────────────────────────────────────────────────
class _BossTab extends StatefulWidget {
  final VoidCallback onAdd;
  const _BossTab({required this.onAdd});

  @override
  State<_BossTab> createState() => _BossTabState();
}

class _BossTabState extends State<_BossTab> {
  final List<_ContentItem> _bosses = [
    _ContentItem(
        emoji: '💀',
        title: 'Deadline Boss Lv.3',
        sub: 'Aktif · 2000 HP · 500 XP · 3 Party',
        isActive: true,
        hp: 70),
    _ContentItem(
        emoji: '👾',
        title: 'UTS Boss Lv.2',
        sub: 'Aktif · 1500 HP · 350 XP · 2 Party',
        isActive: true,
        hp: 53),
    _ContentItem(
        emoji: '🐉',
        title: 'Final Project Boss Lv.5',
        sub: 'Belum aktif · 5000 HP · 1000 XP',
        isActive: false,
        hp: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(
            active: _bosses.where((b) => b.isActive).length,
            total: _bosses.length,
            label: 'Boss'),
        const SizedBox(height: 12),
        ..._bosses.map((b) => _BossCard(
              item: b,
              onToggle: () => setState(() => b.isActive = !b.isActive),
              onDelete: () => setState(() => _bosses.remove(b)),
            )),
      ],
    );
  }
}

// ── Item Tab ──────────────────────────────────────────────────────────────────
class _ItemTab extends StatefulWidget {
  final VoidCallback onAdd;
  const _ItemTab({required this.onAdd});

  @override
  State<_ItemTab> createState() => _ItemTabState();
}

class _ItemTabState extends State<_ItemTab> {
  final List<_ContentItem> _items = [
    _ContentItem(
        emoji: '🗡️',
        title: 'Iron Sword',
        sub: '+15 ATK · 80 Gold · Warrior',
        isActive: true),
    _ContentItem(
        emoji: '🛡️',
        title: 'Study Shield',
        sub: '+20 DEF · 120 Gold · Semua Class',
        isActive: true),
    _ContentItem(
        emoji: '🧪',
        title: 'HP Potion',
        sub: 'Restore 30 HP · 50 Gold',
        isActive: true),
    _ContentItem(
        emoji: '📜',
        title: 'XP Scroll',
        sub: '+100 XP instan · 200 Gold',
        isActive: true),
    _ContentItem(
        emoji: '🎩',
        title: 'Wizard Hat',
        sub: '+10 MP · 90 Gold · Mage',
        isActive: false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(
            active: _items.where((i) => i.isActive).length,
            total: _items.length,
            label: 'Item'),
        const SizedBox(height: 12),
        ..._items.map((item) => _ContentCard(
              item: item,
              accentColor: AppColors.gold,
              onToggle: () => setState(() => item.isActive = !item.isActive),
              onDelete: () => setState(() => _items.remove(item)),
            )),
      ],
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────
class _ContentItem {
  String emoji;
  String title;
  String sub;
  bool isActive;
  int hp;

  _ContentItem({
    required this.emoji,
    required this.title,
    required this.sub,
    this.isActive = true,
    this.hp = 0,
  });
}

// ── Summary Row ───────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final int active;
  final int total;
  final String label;

  const _SummaryRow(
      {required this.active, required this.total, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('$active Aktif', AppColors.xp),
        const SizedBox(width: 8),
        _chip('${total - active} Nonaktif', AppColors.t3),
        const SizedBox(width: 8),
        _chip('$total Total $label', AppColors.accent2),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Content Card ──────────────────────────────────────────────────────────────
class _ContentCard extends StatelessWidget {
  final _ContentItem item;
  final Color accentColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ContentCard({
    required this.item,
    required this.accentColor,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              item.isActive ? accentColor.withOpacity(0.2) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                const SizedBox(height: 2),
                Text(item.sub,
                    style: const TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Toggle active
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.isActive
                    ? AppColors.xp.withOpacity(0.12)
                    : AppColors.t3.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.isActive ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: item.isActive ? AppColors.xp : AppColors.t3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline,
                color: AppColors.red, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Boss Card ─────────────────────────────────────────────────────────────────
class _BossCard extends StatelessWidget {
  final _ContentItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _BossCard({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.c1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              item.isActive ? AppColors.red.withOpacity(0.3) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                item.isActive ? AppColors.red : AppColors.t2)),
                    Text(item.sub,
                        style:
                            const TextStyle(fontSize: 10, color: AppColors.t3)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isActive
                        ? AppColors.red.withOpacity(0.12)
                        : AppColors.t3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.isActive ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: item.isActive ? AppColors.red : AppColors.t3),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    color: AppColors.red, size: 18),
              ),
            ],
          ),
          if (item.isActive && item.hp > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: item.hp / 100,
                minHeight: 4,
                backgroundColor: AppColors.red.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.red),
              ),
            ),
            const SizedBox(height: 4),
            Text('${item.hp}% HP tersisa',
                style: const TextStyle(fontSize: 9, color: AppColors.t3)),
          ],
        ],
      ),
    );
  }
}
