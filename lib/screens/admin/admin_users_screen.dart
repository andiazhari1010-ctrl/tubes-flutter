import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

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

  List<_UserData> _users = [];

  // Firestore listener
  late final StreamSubscription<QuerySnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    final service = FirestoreService();
    _subscription = service.getAllUsersStream().listen((snapshot) {
      final list = snapshot.docs.map((doc) {
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
        return _UserData(
          uid: doc.id,
          name: name,
          email: email,
          heroClass: hero != null ? _classFromString(hero['heroClass'] ?? '') : 'Warrior',
          level: hero != null ? (hero['level'] ?? 1) as int : 1,
          isActive: (data['isActive'] ?? true) as bool,
          isAdmin: (data['role'] == 'admin'),
          streak: hero != null ? (hero['streak'] ?? 0) as int : 0,
          gold: hero != null ? (hero['gold'] ?? 0) as int : 0,
          isBanned: (data['isBanned'] ?? false) as bool,
        );
      }).toList();
      setState(() {
        _users = list;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  String _classFromString(String cls) {
    switch (cls.toLowerCase()) {
      case 'warrior':
        return 'Warrior';
      case 'mage':
        return 'Mage';
      case 'healer':
        return 'Healer';
      case 'rogue':
        return 'Rogue';
      default:
        return 'Warrior';
    }
  }

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
        titleTextStyle: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
        ),
        actions: [
          GestureDetector(
            onTap: () => _showUserForm(context),
            child: Container(
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
              style: TextStyle(fontSize: 13, color: AppColors.t1),
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Cari nama atau email...',
                hintStyle: TextStyle(color: AppColors.t3),
                prefixIcon:
                    Icon(Icons.search, color: AppColors.t3, size: 18),
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
                      BorderSide(color: AppColors.accent, width: 1),
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
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.c2,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: sel
                              ? AppColors.gold.withValues(alpha: 0.5)
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
                  style: TextStyle(fontSize: 11, color: AppColors.t3),
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
                onBanToggle: () {},
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
                        style: TextStyle(
                          fontFamily: 'Cinzel',
                          fontSize: 15,
                          color: AppColors.t1,
                        )),
                    const SizedBox(height: 3),
                    Text(user.email,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.t3)),
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
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUserForm(context, userToEdit: user);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Edit User',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'isBanned': !user.isBanned,
                          'isActive': user.isBanned,
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(user.isBanned
                                  ? 'Berhasil membuka blokir user!'
                                  : 'Berhasil memblokir user!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengubah status: $e'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      }
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.c1,
                          title: const Text('Hapus User',
                              style: TextStyle(
                                  fontFamily: 'Cinzel',
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          content: Text(
                              'Apakah Anda yakin ingin menghapus user ${user.name} dari database Firestore? Tindakan ini tidak dapat dibatalkan.',
                              style: TextStyle(color: AppColors.t3, fontSize: 13)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Batal',
                                  style: TextStyle(color: AppColors.t3)),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red),
                              child: const Text('Hapus',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil menghapus user dari database!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus user: $e'),
                                backgroundColor: AppColors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Hapus User',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUserForm(BuildContext context, {_UserData? userToEdit}) {
    final nameCtrl = TextEditingController(text: userToEdit?.name ?? '');
    final emailCtrl = TextEditingController(text: userToEdit?.email ?? '');
    final levelCtrl = TextEditingController(text: userToEdit != null ? '${userToEdit.level}' : '1');
    final streakCtrl = TextEditingController(text: userToEdit != null ? '${userToEdit.streak}' : '0');
    final goldCtrl = TextEditingController(text: userToEdit != null ? '${userToEdit.gold}' : '0');
    String roleVal = userToEdit != null && userToEdit.isAdmin ? 'admin' : 'user';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.c2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 36,
          ),
          child: SingleChildScrollView(
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
                  userToEdit != null ? 'Edit Profil User' : 'Tambah User Baru',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 16,
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFormInput(nameCtrl, 'Nama Lengkap', Icons.badge_outlined),
                const SizedBox(height: 10),
                _buildFormInput(emailCtrl, 'Email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildFormInput(levelCtrl, 'Level', Icons.trending_up, keyboardType: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildFormInput(streakCtrl, 'Streak', Icons.local_fire_department, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFormInput(goldCtrl, 'Gold', Icons.monetization_on_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Text(
                  'Peran (Role)',
                  style: TextStyle(fontSize: 11, color: AppColors.t3, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => roleVal = 'user'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: roleVal == 'user' ? AppColors.accent.withValues(alpha: 0.15) : AppColors.c1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: roleVal == 'user' ? AppColors.accent : AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'USER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: roleVal == 'user' ? AppColors.accent : AppColors.t3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => roleVal = 'admin'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: roleVal == 'admin' ? AppColors.gold.withValues(alpha: 0.15) : AppColors.c1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: roleVal == 'admin' ? AppColors.gold : AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: roleVal == 'admin' ? AppColors.gold : AppColors.t3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      final email = emailCtrl.text.trim();
                      final level = int.tryParse(levelCtrl.text.trim()) ?? 1;
                      final streak = int.tryParse(streakCtrl.text.trim()) ?? 0;
                      final gold = int.tryParse(goldCtrl.text.trim()) ?? 0;

                      if (name.isEmpty || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama dan Email tidak boleh kosong!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(ctx);
                      try {
                        if (userToEdit != null) {
                          // Update Firestore existing user doc
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userToEdit.uid)
                              .update({
                            'fullName': name,
                            'email': email,
                            'role': roleVal,
                            'hero.name': name,
                            'hero.level': level,
                            'hero.streak': streak,
                            'hero.gold': gold,
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil memperbarui data pengguna!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          // Add brand new user doc to Firestore
                          final newUid = FirebaseFirestore.instance.collection('users').doc().id;
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(newUid)
                              .set({
                            'email': email,
                            'role': roleVal,
                            'username': email.split('@').first,
                            'fullName': name,
                            'phone': '',
                            'createdAt': FieldValue.serverTimestamp(),
                            'hero': {
                              'name': name,
                              'heroClass': 'warrior',
                              'level': level,
                              'hp': 100,
                              'maxHp': 100,
                              'xp': 0,
                              'maxXp': 100,
                              'mp': 50,
                              'maxMp': 50,
                              'gold': gold,
                              'gems': 0,
                              'streak': streak,
                            }
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Berhasil menambahkan pengguna baru!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menyimpan data: $e'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: const Color(0xFF2A1A00),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      userToEdit != null ? 'Perbarui User' : 'Tambah User',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormInput(TextEditingController ctrl, String hint, IconData icon,
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
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.t3)),
          Text(value,
              style: TextStyle(
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
  final String uid;
  final String name;
  final String email;
  final String heroClass;
  final int level;
  final bool isActive;
  final bool isAdmin;
  final int streak;
  final int gold;
  final bool isBanned;

  _UserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.heroClass,
    required this.level,
    required this.isActive,
    required this.isAdmin,
    required this.streak,
    required this.gold,
    required this.isBanned,
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
      color: u.avatarColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: u.avatarColor.withValues(alpha: 0.4), width: 0.5),
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
                ? AppColors.red.withValues(alpha: 0.25)
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
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.t1)),
                      if (user.isAdmin) ...[
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('ADMIN',
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
                    style: TextStyle(fontSize: 10, color: AppColors.t3),
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
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: statusColor)),
                ),
                const SizedBox(height: 5),
                Text('Detail →',
                    style: TextStyle(fontSize: 9, color: AppColors.accent2)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}