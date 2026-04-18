import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'Semua';
  String _search = '';

  final _filters = ['Semua', 'Aktif', 'Banned', 'Admin'];

  final List<_UserData> _users = [
    _UserData(
        name: 'Tubagus Lingga',
        email: 'lingga@student.telkomuniversity.ac.id',
        heroClass: 'Warrior',
        level: 12,
        isActive: true,
        isAdmin: false,
        streak: 7,
        gold: 340),
    _UserData(
        name: 'Muhammad Zhielton',
        email: 'zhielton@student.telkomuniversity.ac.id',
        heroClass: 'Mage',
        level: 15,
        isActive: true,
        isAdmin: true,
        streak: 14,
        gold: 520),
    _UserData(
        name: 'Yafi Zakaria',
        email: 'yafi@student.telkomuniversity.ac.id',
        heroClass: 'Rogue',
        level: 11,
        isActive: true,
        isAdmin: false,
        streak: 5,
        gold: 210),
    _UserData(
        name: 'Andy Azhari',
        email: 'andy@student.telkomuniversity.ac.id',
        heroClass: 'Warrior',
        level: 10,
        isActive: true,
        isAdmin: false,
        streak: 3,
        gold: 180),
    _UserData(
        name: 'Disha Aziz',
        email: 'disha@student.telkomuniversity.ac.id',
        heroClass: 'Healer',
        level: 9,
        isActive: false,
        isAdmin: false,
        streak: 0,
        gold: 90,
        isBanned: true),
    _UserData(
        name: 'Agus Mahendra',
        email: 'agus.m@student.telkomuniversity.ac.id',
        heroClass: 'Mage',
        level: 7,
        isActive: true,
        isAdmin: false,
        streak: 2,
        gold: 120),
    _UserData(
        name: 'Rizky Pratama',
        email: 'rizky.p@student.telkomuniversity.ac.id',
        heroClass: 'Rogue',
        level: 5,
        isActive: false,
        isAdmin: false,
        streak: 0,
        gold: 60),
  ];

  List<_UserData> get _filtered {
    return _users.where((u) {
      final matchFilter = _filter == 'Semua' ||
          (_filter == 'Aktif' && u.isActive && !u.isBanned) ||
          (_filter == 'Banned' && u.isBanned) ||
          (_filter == 'Admin' && u.isAdmin);
      final matchSearch = _search.isEmpty ||
          u.name.toLowerCase().contains(_search.toLowerCase()) ||
          u.email.toLowerCase().contains(_search.toLowerCase());
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        title: const Text('Manajemen User'),
        titleTextStyle: const TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.c2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: const Center(
              child: Text('➕', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 13, color: AppColors.t1),
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                hintStyle: const TextStyle(color: AppColors.t3),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.t3, size: 18),
                filled: true,
                fillColor: AppColors.c2,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border2, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 1),
                ),
              ),
            ),
          ),

          // ── Filter chips ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _filters.map((f) {
                  final sel = _filter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.gold.withOpacity(0.15)
                            : AppColors.c2,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: sel
                              ? AppColors.gold.withOpacity(0.5)
                              : AppColors.border,
                          width: sel ? 1 : 0.5,
                        ),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: sel ? AppColors.gold : AppColors.t3)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Count label ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              children: [
                Text(
                  '${_filtered.length} user ditemukan',
                  style: const TextStyle(fontSize: 11, color: AppColors.t3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── User List ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) => _UserCard(
                user: _filtered[i],
                onBanToggle: () => setState(() {
                  _filtered[i].isBanned = !_filtered[i].isBanned;
                }),
                onDetail: () => _showUserDetail(ctx, _filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(BuildContext context, _UserData user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
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
            const SizedBox(height: 20),
            Row(
              children: [
                _avatarCircle(user),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 15,
                          color: AppColors.t1,
                        )),
                    const SizedBox(height: 3),
                    Text(user.email,
                        style:
                            const TextStyle(fontSize: 11, color: AppColors.t3)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _detailRow('Class', '${user.classEmoji}  ${user.heroClass}'),
            _detailRow('Level', 'Lv.${user.level}'),
            _detailRow('Streak', '🔥 ${user.streak} hari'),
            _detailRow('Gold', '🪙 ${user.gold}'),
            _detailRow(
                'Status',
                user.isBanned
                    ? '🚫 Banned'
                    : (user.isActive ? '🟢 Aktif' : '⚫ Tidak Aktif')),
            _detailRow('Role', user.isAdmin ? '🛡️ Admin' : '⚔️ User'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.t2,
                      side: BorderSide(color: AppColors.border2, width: 0.5),
                      backgroundColor: AppColors.c1,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Tutup', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => user.isBanned = !user.isBanned);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          user.isBanned ? AppColors.xp : AppColors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(user.isBanned ? 'Unban User' : 'Ban User',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.t3)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.t1)),
        ],
      ),
    );
  }
}

// ── User Data model ───────────────────────────────────────────────────────────
class _UserData {
  final String name;
  final String email;
  final String heroClass;
  final int level;
  final bool isActive;
  final bool isAdmin;
  final int streak;
  final int gold;
  bool isBanned;

  _UserData({
    required this.name,
    required this.email,
    required this.heroClass,
    required this.level,
    required this.isActive,
    required this.isAdmin,
    required this.streak,
    required this.gold,
    this.isBanned = false,
  });

  String get classEmoji {
    switch (heroClass) {
      case 'Warrior':
        return '⚔️';
      case 'Mage':
        return '🧙';
      case 'Healer':
        return '💚';
      case 'Rogue':
        return '🏹';
      default:
        return '❓';
    }
  }

  Color get avatarColor {
    switch (heroClass) {
      case 'Warrior':
        return AppColors.accent;
      case 'Mage':
        return const Color(0xFF185FA5);
      case 'Healer':
        return const Color(0xFF0F6E56);
      case 'Rogue':
        return const Color(0xFF854F0B);
      default:
        return AppColors.t3;
    }
  }
}

// ── Avatar Circle ─────────────────────────────────────────────────────────────
Widget _avatarCircle(_UserData u) {
  return Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: u.avatarColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: u.avatarColor.withOpacity(0.4), width: 0.5),
    ),
    child: Center(
      child: Text(u.classEmoji, style: const TextStyle(fontSize: 18)),
    ),
  );
}

// ── User Card ─────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final _UserData user;
  final VoidCallback onBanToggle;
  final VoidCallback onDetail;

  const _UserCard({
    required this.user,
    required this.onBanToggle,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    if (user.isBanned) {
      statusColor = AppColors.red;
      statusText = 'Banned';
    } else if (user.isAdmin) {
      statusColor = AppColors.gold;
      statusText = 'Admin';
    } else if (user.isActive) {
      statusColor = AppColors.xp;
      statusText = 'Aktif';
    } else {
      statusColor = AppColors.t3;
      statusText = 'Tidak Aktif';
    }

    return GestureDetector(
      onTap: onDetail,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.c1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: user.isBanned
                ? AppColors.red.withOpacity(0.25)
                : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            _avatarCircle(user),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(user.name,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.t1)),
                      if (user.isAdmin) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('ADMIN',
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                  letterSpacing: 0.3)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lv.${user.level} · ${user.heroClass} · 🔥${user.streak}',
                    style: const TextStyle(fontSize: 10, color: AppColors.t3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ),
                const SizedBox(height: 5),
                const Text('Detail →',
                    style: TextStyle(fontSize: 9, color: AppColors.accent2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
