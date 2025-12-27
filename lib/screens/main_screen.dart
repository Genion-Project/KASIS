import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../pages/riwayat_page.dart';
import 'members_screen.dart';
import '../pages/pemasukan_page.dart';
import '../pages/pengeluaran_page.dart';
import 'rekap/input_pelanggaran_dialog.dart';

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
    _NavItem(icon: Icons.add_circle_rounded, label: 'Tambah', activeIcon: Icons.add_circle), // Changed to Add
    _NavItem(icon: Icons.people_outline_rounded, label: 'Anggota', activeIcon: Icons.people_rounded),
  ];

  void _onNavTap(int index) {
    if (index == 1) {
      _showAddOptions();
    } else if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Tambah Transaksi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionItem(
                  icon: Icons.arrow_downward_rounded,
                  color: Colors.green,
                  label: 'Pemasukan',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PemasukanPage()),
                    );
                  },
                ),
                _buildOptionItem(
                  icon: Icons.arrow_upward_rounded,
                  color: Colors.red,
                  label: 'Pengeluaran',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PengeluaranPage()),
                    );
                  },
                ),
                _buildOptionItem(
                  icon: Icons.warning_rounded,
                  color: Colors.orange,
                  label: 'Pelanggaran',
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => InputPelanggaranDialog(
                        onSaved: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pelanggaran berhasil dicatat'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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