import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'party_screen.dart';
import 'hero_screen.dart';
import 'inventory_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TasksScreen(),
    InventoryScreen(),
    PartyScreen(),
    HeroScreen(),
  ];

  Widget _buildToast(String message) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xEE09090E), // sleek translucent dark
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent2.withValues(alpha: 0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent2.withValues(alpha: 0.25),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accent2.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: AppColors.accent2,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: AppColors.t1,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppColors.c0,
          body: Stack(
            children: [
              IndexedStack(index: _index, children: _screens),
              if (state.notifications.isNotEmpty)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: state.notifications
                        .map((msg) => _buildToast(msg))
                        .toList(),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Color(0xF50D0D1A),
              border: Border(
                top: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.accent2,
              unselectedItemColor: AppColors.t3,
              selectedLabelStyle: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
              unselectedLabelStyle: const TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4),
              items: const [
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('🏠', style: TextStyle(fontSize: 20)),
                    ),
                    label: 'HOME'),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('📋', style: TextStyle(fontSize: 20)),
                    ),
                    label: 'TASKS'),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('🎒', style: TextStyle(fontSize: 20)),
                    ),
                    label: 'INVENTORY'),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('⚔️', style: TextStyle(fontSize: 20)),
                    ),
                    label: 'PARTY'),
                BottomNavigationBarItem(
                    icon: Padding(
                      padding: EdgeInsets.only(bottom: 2),
                      child: Text('🧙', style: TextStyle(fontSize: 20)),
                    ),
                    label: 'HERO'),
              ],
            ),
          ),
        );
      },
    );
  }
}