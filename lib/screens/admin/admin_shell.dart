import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_content_screen.dart';
import 'admin_stats_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminContentScreen(),
    AdminStatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.c0,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF50D0D1A),
          border: Border(
            top: BorderSide(color: AppColors.gold.withValues(alpha: 0.2), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.t3,
          selectedLabelStyle: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
          unselectedLabelStyle: const TextStyle(
              fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text('📊', style: TextStyle(fontSize: 20)),
              ),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text('👥', style: TextStyle(fontSize: 20)),
              ),
              label: 'USERS',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text('🗡️', style: TextStyle(fontSize: 20)),
              ),
              label: 'KONTEN',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text('📈', style: TextStyle(fontSize: 20)),
              ),
              label: 'STATISTIK',
            ),
          ],
        ),
      ),
    );
  }
}
