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
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _saveProfile(AppState state) {
    if (_nameCtrl.text.trim().isEmpty) return;
    state.updateHeroName(_nameCtrl.text.trim());
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
        title: const Text('Keluar Akun?', style: TextStyle(fontFamily: 'Cinzel', color: AppColors.t1, fontSize: 16)),
        content: const Text('Apakah Anda yakin ingin keluar dari petualangan Anda?', style: TextStyle(color: AppColors.t2, fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.t3)),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.t2),
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
                const Text(
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
                            color: isSelected ? AppColors.accent.withOpacity(0.2) : AppColors.c3,
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
                const Text(
                  'Nama Hero:',
                  style: TextStyle(fontSize: 10, color: AppColors.t3, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(fontSize: 13, color: AppColors.t1),
                  decoration: InputDecoration(
                    hintText: 'Nama Hero kamu',
                    hintStyle: const TextStyle(color: AppColors.t3),
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.t3, size: 18),
                    filled: true,
                    fillColor: AppColors.c1,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accent, width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                    setState(() {
                      _isDarkMode = val;
                    });
                    state.addNotification("🌌 Dark Mode forced for futuristic style");
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
                    setState(() {
                      _isMusicOn = val;
                    });
                    state.addNotification(val ? "🎵 Music Track Enabled" : "🔇 Music Track Muted");
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                _settingSwitch(
                  title: 'Sound Effects (SFX)',
                  subtitle: 'Suara notifikasi dan level up.',
                  value: _isSfxOn,
                  onChanged: (val) {
                    setState(() {
                      _isSfxOn = val;
                    });
                    state.addNotification(val ? "🔊 SFX Enabled" : "🔇 SFX Muted");
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Logout Action ──────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, size: 16, color: AppColors.red),
            label: const Text('Keluar dari HeroQuest', style: TextStyle(fontWeight: FontWeight.w700)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red, width: 0.5),
              backgroundColor: AppColors.red.withOpacity(0.05),
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
        style: const TextStyle(
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
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.t1)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.t3)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
            inactiveThumbColor: AppColors.t3,
            inactiveTrackColor: AppColors.c1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
