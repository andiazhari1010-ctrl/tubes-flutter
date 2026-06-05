import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'auth_wrapper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isMusicOn = true;
  bool _isSfxOn = true;
  bool _isDarkMode = true;
  String _selectedAvatar = '🧙';
  
  final List<String> _avatars = ['⚔️', '🧙', '💚', '🏹', '🛡️', '👑', '🔥', '🌟'];

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _nameCtrl.text = state.hero.name;
    _selectedAvatar = state.hero.classEmoji;
    _usernameCtrl.text = state.username;
    _fullNameCtrl.text = state.fullName;
    _phoneCtrl.text = state.phone;
    _emailCtrl.text = FirebaseAuth.instance.currentUser?.email ?? '';
    _isDarkMode = state.isDarkMode;
    _isMusicOn = state.isMusicOn;
    _isSfxOn = state.isSfxOn;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _saveProfile(AppState state) {
    if (_nameCtrl.text.trim().isEmpty) return;
    state.updateHeroName(_nameCtrl.text.trim());
    state.updateUserInfo(
      newUsername: _usernameCtrl.text.trim(),
      newFullName: _fullNameCtrl.text.trim(),
      newPhone: _phoneCtrl.text.trim(),
    );
    state.addNotification("👤 Profile Updated Successfully!");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui!'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.c2,
        title: Text('Keluar Akun?', style: TextStyle(fontFamily: 'Cinzel', color: AppColors.t1, fontSize: 16)),
        content: Text('Apakah Anda yakin ingin keluar dari petualangan Anda?', style: TextStyle(color: AppColors.t2, fontSize: 12)),
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
              if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('SETTINGS'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.t2),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 10),

          // ── Profile Settings ───────────────────────────────────────
          _sectionHeader('USER PROFILE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.c2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Selection Row
                Text(
                  'Pilih Avatar / Simbol:',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _avatars.length,
                    itemBuilder: (ctx, index) {
                      final av = _avatars[index];
                      final isSelected = _selectedAvatar == av;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = av;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent.withValues(alpha: 0.2) : AppColors.c3,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.accent : AppColors.border,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Center(child: Text(av, style: const TextStyle(fontSize: 22))),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Name Input
                Text(
                  'Nama Hero:',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  style: TextStyle(fontSize: 13, color: AppColors.t1),
                  decoration: InputDecoration(
                    hintText: 'Nama Hero kamu',
                    hintStyle: TextStyle(color: AppColors.t3),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.t3, size: 18),
                    filled: true,
                    fillColor: AppColors.c1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: AppColors.border, thickness: 0.5),
                ),

                // Account Information Section
                Text(
                  'INFORMASI PENGGUNA',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold2,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 14),

                // Username input
                Text(
                  'Username:',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameCtrl,
                  style: TextStyle(fontSize: 13, color: AppColors.t1),
                  decoration: InputDecoration(
                    hintText: 'Username kamu',
                    hintStyle: TextStyle(color: AppColors.t3),
                    prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.t3, size: 18),
                    filled: true,
                    fillColor: AppColors.c1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nama Lengkap input
                Text(
                  'Nama Lengkap:',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _fullNameCtrl,
                  style: TextStyle(fontSize: 13, color: AppColors.t1),
                  decoration: InputDecoration(
                    hintText: 'Nama Lengkap kamu',
                    hintStyle: TextStyle(color: AppColors.t3),
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.t3, size: 18),
                    filled: true,
                    fillColor: AppColors.c1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Nomor Telepon input
                Text(
                  'Nomor Telepon:',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 13, color: AppColors.t1),
                  decoration: InputDecoration(
                    hintText: 'Nomor Telepon kamu',
                    hintStyle: TextStyle(color: AppColors.t3),
                    prefixIcon: Icon(Icons.phone_android_rounded, color: AppColors.t3, size: 18),
                    filled: true,
                    fillColor: AppColors.c1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Email input (read-only)
                Text(
                  'Email (Tidak dapat diubah):',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailCtrl,
                  readOnly: true,
                  style: TextStyle(fontSize: 13, color: AppColors.t2),
                  decoration: InputDecoration(
                    hintText: 'Email kamu',
                    hintStyle: TextStyle(color: AppColors.t3),
                    prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.t3, size: 18),
                    filled: true,
                    fillColor: AppColors.c0.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3), width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.3), width: 0.5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Save Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _saveProfile(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan Profil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Appearance Settings ────────────────────────────────────
          _sectionHeader('APPEARANCE'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.c2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                _settingSwitch(
                  title: 'Dark Mode Dominant',
                  subtitle: 'Tampilan cyberpunk gelap neon.',
                  value: _isDarkMode,
                  onChanged: (val) {
                    state.setDarkMode(val);
                    setState(() {
                      _isDarkMode = val;
                    });
                    state.addNotification(val ? "🌌 Dark Mode Enabled" : "☀️ Light Mode Enabled");
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Sound Settings ─────────────────────────────────────────
          _sectionHeader('SOUND & AUDIO'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.c2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                _settingSwitch(
                  title: 'Background Music',
                  subtitle: 'Mainkan musik atmosfir RPG.',
                  value: _isMusicOn,
                  onChanged: (val) {
                    state.setMusicOn(val);
                    setState(() {
                      _isMusicOn = val;
                    });
                    state.addNotification(val ? "🎵 Music Track Enabled" : "🔇 Music Track Muted");
                  },
                ),
                Divider(height: 1, color: AppColors.border),
                _settingSwitch(
                  title: 'Sound Effects (SFX)',
                  subtitle: 'Suara notifikasi dan level up.',
                  value: _isSfxOn,
                  onChanged: (val) {
                    state.setSfxOn(val);
                    setState(() {
                      _isSfxOn = val;
                    });
                    state.addNotification(val ? "🔊 SFX Enabled" : "🔇 SFX Muted");
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Game Terminology / Glossary ────────────────────────────
          _sectionHeader('GAME TERMINOLOGY'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.c2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGlossaryItem('XP (Experience)', 'Poin pengalaman. Kumpulkan hingga 100 XP untuk naik Level. Saat naik level, XP akan reset ke 0 dan Max HP & MP akan pulih sepenuhnya.'),
                const SizedBox(height: 12),
                _buildGlossaryItem('HP (Health Points)', 'Nyawa karakter (Maks 150). Berkurang jika kamu gagal melakukan Habit yang baik atau diserang Boss.'),
                const SizedBox(height: 12),
                _buildGlossaryItem('MP (Mana Points)', 'Energi magis (Maks 100). Saat ini dapat direstore dengan item tertentu seperti Coffee Cup.'),
                const SizedBox(height: 12),
                _buildGlossaryItem('MM (Momentum)', 'Semangat/fokus kamu (0-100). Momentum tinggi memberikan bonus XP dan Gold saat kamu menyelesaikan Task.'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Logout Action ──────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout_rounded, size: 16, color: AppColors.red),
            label: const Text('Keluar dari HeroQuest', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: BorderSide(color: AppColors.red, width: 0.5),
              backgroundColor: AppColors.red.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cinzel',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.t3,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _settingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.t1)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.t3,
            inactiveTrackColor: AppColors.c1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildGlossaryItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent)),
        const SizedBox(height: 4),
        Text(description, style: TextStyle(fontSize: 11, color: AppColors.t2, height: 1.4)),
      ],
    );
  }
}