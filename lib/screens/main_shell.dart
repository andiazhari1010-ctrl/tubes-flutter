import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/app_state.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'party_screen.dart';
import 'hero_screen.dart';
<<<<<<< HEAD
import 'inventory_screen.dart';
=======
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518

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
<<<<<<< HEAD
    InventoryScreen(),
=======
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
    PartyScreen(),
    HeroScreen(),
  ];

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Scaffold(
      backgroundColor: AppColors.c0,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xF50D0D1A),
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
=======
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Scaffold(
        backgroundColor: AppColors.c0,
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: const Color(0xF50D0D1A),
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
>>>>>>> 5fd606cb57a6114a3116f136f5cf02c2f4a7e518
        ),
      ),
    );
  }
}
