import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'admin/manage_shop_screen.dart'; // Import ManageShopScreen
import 'admin/manage_quests_screen.dart';
import 'admin/manage_users_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthService().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      appBar: AppBar(
        backgroundColor: AppColors.c1,
        title: const Text('Admin Dashboard', style: TextStyle(fontFamily: 'Cinzel', color: AppColors.t1)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.t3),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel Kontrol Admin',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.t1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola Quests, Items, dan Users',
                style: TextStyle(color: AppColors.t3),
              ),
              const SizedBox(height: 32),
              
              _buildAdminCard(
                icon: '📜',
                title: 'Kelola Quests Global',
                subtitle: 'Tambah atau edit quest untuk semua party',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageQuestsScreen()));
                },
              ),
              const SizedBox(height: 16),
              
              _buildAdminCard(
                icon: '📦',
                title: 'Kelola Shop Items',
                subtitle: 'Atur harga dan tambah item baru',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageShopScreen()));
                },
              ),
              const SizedBox(height: 16),
              
              _buildAdminCard(
                icon: '👥',
                title: 'Daftar Pengguna',
                subtitle: 'Lihat semua hero yang terdaftar',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard({required String icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.c2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.t1)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.t3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.t3),
          ],
        ),
      ),
    );
  }
}
