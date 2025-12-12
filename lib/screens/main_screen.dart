import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../pages/riwayat_page.dart';  // Import RiwayatPage
import 'members_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    RiwayatPage(), // Use RiwayatPage instead of AddTransactionScreen
    MembersScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', activeIcon: Icons.home),
    _NavItem(icon: Icons.assignment_late_outlined, label: 'Pelanggaran', activeIcon: Icons.assignment_late_rounded), // Updated icon and label
    _NavItem(icon: Icons.people_outline_rounded, label: 'Anggota', activeIcon: Icons.people_rounded),
  ];

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Background universal
      body: Stack(
        children: [
          // Content Layer
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Floating Navbar Layer
          Positioned(
            left: 50,
            right: 50,
            bottom: 24,
            child: _buildFloatingNavbar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavbar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = _currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onNavTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Color(0xFF6C63FF).withOpacity(0.1) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Color(0xFF6C63FF) : Colors.grey[400],
                    size: 24,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.label,
    required this.activeIcon,
  });
}