import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_icons.dart';
import '../../models/app_state.dart';
import '../../models/models.dart';

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
    final state = Provider.of<AppState>(context);
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Manajemen Konten'),
        titleTextStyle: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
        actions: [
          GestureDetector(
            onTap: () => _showAddDialog(context, state: state, tabIdx: _tab.index),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.3), width: 0.5),
              ),
              child: Center(
                child: Icon(AppIcons.add, size: 18, color: AppColors.gold),
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
          _QuestTab(
            onAdd: () => _showAddDialog(context, state: state, tabIdx: 0),
            onEdit: (item) => _showAddDialog(context, state: state, tabIdx: 0, itemToEdit: item),
          ),
          _BossTab(
            onAdd: () => _showAddDialog(context, state: state, tabIdx: 1),
            onEdit: (item) => _showAddDialog(context, state: state, tabIdx: 1, itemToEdit: item),
          ),
          _ItemTab(
            onAdd: () => _showAddDialog(context, state: state, tabIdx: 2),
            onEdit: (item) => _showAddDialog(context, state: state, tabIdx: 2, itemToEdit: item),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, {required AppState state, required int tabIdx, _ContentItem? itemToEdit}) {
    final titleCtrl = TextEditingController(text: itemToEdit?.title ?? '');
    final xpCtrl = TextEditingController(text: itemToEdit != null ? '${itemToEdit.rewardOrPrice}' : '');

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
            Text(itemToEdit != null ? 'Edit Konten' : 'Tambah Konten Baru',
                style: TextStyle(
                  fontFamily: 'Cinzel',
                  fontSize: 16,
                  color: AppColors.gold,
                )),
            const SizedBox(height: 16),
            _buildInput(titleCtrl, 'Nama / Judul konten', Icons.title),
            const SizedBox(height: 10),
            _buildInput(xpCtrl, tabIdx == 2 ? 'Harga (Gold)' : 'XP Reward', Icons.star_outline,
                keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final valStr = xpCtrl.text.trim();
                  if (title.isNotEmpty) {
                    final val = int.tryParse(valStr) ?? 100;
                    if (itemToEdit != null) {
                      // Edit Mode
                      if (tabIdx == 0) {
                        state.updateGlobalQuest(itemToEdit.id, title, val);
                      } else if (tabIdx == 1) {
                        state.updateGlobalBoss(itemToEdit.id, title, val);
                      } else if (tabIdx == 2) {
                        state.updateShopItem(itemToEdit.id, title, val);
                      }
                    } else {
                      // Add Mode
                      final newId = DateTime.now().millisecondsSinceEpoch.toString();
                      if (tabIdx == 0) {
                        state.addGlobalQuest(QuestModel(
                          id: newId,
                          title: title,
                          progress: 100,
                          xpReward: val,
                          timeLeft: '7 Hari Tersisa',
                          isBoss: false,
                        ));
                      } else if (tabIdx == 1) {
                        state.addGlobalBoss(QuestModel(
                          id: newId,
                          title: title,
                          progress: 100,
                          xpReward: val,
                          timeLeft: '1 Party',
                          isBoss: true,
                        ));
                      } else if (tabIdx == 2) {
                        state.addShopItem(ShopItem(
                          id: newId,
                          name: title,
                          description: 'Item Baru',
                          emoji: '',
                          price: val,
                          category: ItemCategory.armor,
                          rarity: ItemRarity.rare,
                        ));
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(itemToEdit != null
                            ? 'Konten berhasil diperbarui!'
                            : 'Konten berhasil ditambahkan!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: const Color(0xFF2A1A00),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(itemToEdit != null ? 'Perbarui Konten' : 'Simpan Konten',
                    style:
                        const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
      style: TextStyle(fontSize: 13, color: AppColors.t1),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.t3),
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
          borderSide: BorderSide(color: AppColors.gold, width: 1),
        ),
      ),
    );
  }
}

// ── Quest Tab ─────────────────────────────────────────────────────────────────
class _QuestTab extends StatefulWidget {
  final VoidCallback onAdd;
  final Function(_ContentItem) onEdit;
  const _QuestTab({required this.onAdd, required this.onEdit});

  @override
  State<_QuestTab> createState() => _QuestTabState();
}

class _QuestTabState extends State<_QuestTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final list = state.globalQuests.map((q) => _ContentItem(
          id: q.id,
          icon: q.isBoss ? AppIcons.boss : AppIcons.quest,
          title: q.title,
          sub: q.progress == 0 ? 'Nonaktif · Draft' : 'Aktif · ${q.timeLeft} · ${q.xpReward} XP',
          isActive: q.progress > 0,
          rewardOrPrice: q.xpReward,
        )).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryRow(
                active: list.where((q) => q.isActive).length,
                total: list.length,
                label: 'Quest'),
            const SizedBox(height: 12),
            ...list.map((q) => _ContentCard(
                  item: q,
                  accentColor: AppColors.accent,
                  onToggle: () => state.toggleGlobalQuest(q.id),
                  onEdit: () => widget.onEdit(q),
                  onDelete: () => state.deleteGlobalQuest(q.id),
                )),
          ],
        );
      },
    );
  }
}

// ── Boss Tab ──────────────────────────────────────────────────────────────────
class _BossTab extends StatefulWidget {
  final VoidCallback onAdd;
  final Function(_ContentItem) onEdit;
  const _BossTab({required this.onAdd, required this.onEdit});

  @override
  State<_BossTab> createState() => _BossTabState();
}

class _BossTabState extends State<_BossTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final list = state.globalBosses.map((b) => _ContentItem(
          id: b.id,
          icon: AppIcons.boss,
          title: b.title,
          sub: b.progress == 0 ? 'Belum aktif · 5000 HP · ${b.xpReward} XP' : 'Aktif · ${b.progress}% HP · ${b.xpReward} XP · ${b.timeLeft}',
          isActive: b.progress > 0,
          hp: b.progress,
          rewardOrPrice: b.xpReward,
        )).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryRow(
                active: list.where((b) => b.isActive).length,
                total: list.length,
                label: 'Boss'),
            const SizedBox(height: 12),
            ...list.map((b) => _BossCard(
                  item: b,
                  onToggle: () => state.toggleGlobalBoss(b.id),
                  onEdit: () => widget.onEdit(b),
                  onDelete: () => state.deleteGlobalBoss(b.id),
                )),
          ],
        );
      },
    );
  }
}

// ── Item Tab ──────────────────────────────────────────────────────────────────
class _ItemTab extends StatefulWidget {
  final VoidCallback onAdd;
  final Function(_ContentItem) onEdit;
  const _ItemTab({required this.onAdd, required this.onEdit});

  @override
  State<_ItemTab> createState() => _ItemTabState();
}

class _ItemTabState extends State<_ItemTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final list = state.shopItems.map((i) => _ContentItem(
          id: i.id,
          icon: AppIcons.itemCategory(i.category),
          title: i.name,
          sub: '${i.description} · ${i.price} Gold',
          isActive: !i.owned,
          rewardOrPrice: i.price,
        )).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryRow(
                active: list.where((i) => i.isActive).length,
                total: list.length,
                label: 'Item'),
            const SizedBox(height: 12),
            ...list.map((item) => _ContentCard(
                  item: item,
                  accentColor: AppColors.gold,
                  onToggle: () => state.toggleShopItem(item.id),
                  onEdit: () => widget.onEdit(item),
                  onDelete: () => state.deleteShopItem(item.id),
                )),
          ],
        );
      },
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────
class _ContentItem {
  String id;
  IconData icon;
  String title;
  String sub;
  bool isActive;
  int hp;
  int rewardOrPrice;

  _ContentItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.sub,
    this.isActive = true,
    this.hp = 0,
    this.rewardOrPrice = 100,
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContentCard({
    required this.item,
    required this.accentColor,
    required this.onToggle,
    required this.onEdit,
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
              item.isActive ? accentColor.withValues(alpha: 0.2) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(item.icon, size: 18, color: accentColor),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.t1)),
                const SizedBox(height: 2),
                Text(item.sub,
                    style: TextStyle(fontSize: 10, color: AppColors.t3)),
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
                    ? AppColors.xp.withValues(alpha: 0.12)
                    : AppColors.t3.withValues(alpha: 0.12),
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
            onTap: onEdit,
            child: Icon(Icons.edit_outlined,
                color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline,
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BossCard({
    required this.item,
    required this.onToggle,
    required this.onEdit,
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
              item.isActive ? AppColors.red.withValues(alpha: 0.3) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 22, color: item.isActive ? AppColors.red : AppColors.t2),
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
                            TextStyle(fontSize: 10, color: AppColors.t3)),
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
                        ? AppColors.red.withValues(alpha: 0.12)
                        : AppColors.t3.withValues(alpha: 0.1),
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
                onTap: onEdit,
                child: Icon(Icons.edit_outlined,
                    color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline,
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
                backgroundColor: AppColors.red.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
              ),
            ),
            const SizedBox(height: 4),
            Text('${item.hp}% HP tersisa',
                style: TextStyle(fontSize: 9, color: AppColors.t3)),
          ],
        ],
      ),
    );
  }
}