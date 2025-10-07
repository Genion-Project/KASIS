import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_transaction_screen.dart';
import 'members_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  AnimationController? _fabAnimController;
  Animation<double>? _fabScaleAnimation;

  final List<Widget> _screens = [
    HomeScreen(),
    AddTransactionScreen(),
    MembersScreen(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', activeIcon: Icons.home),
    _NavItem(icon: Icons.add_circle_outline, label: 'Transaksi', activeIcon: Icons.add_circle),
    _NavItem(icon: Icons.people_outline_rounded, label: 'Anggota', activeIcon: Icons.people_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabAnimController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimController?.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      
      // Animate FAB when switching to transaction screen
      if (index == 1 && _fabAnimController != null) {
        _fabAnimController!.forward().then((_) => _fabAnimController!.reverse());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: _fabScaleAnimation != null
          ? ScaleTransition(
              scale: _fabScaleAnimation!,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _currentIndex == 1 ? 0.25 : 0.0),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, rotation, child) {
                  return Transform.rotate(
                    angle: rotation * 3.14159, // π radians = 180 degrees
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF1976D2).withOpacity(_currentIndex == 1 ? 0.5 : 0.4),
                            blurRadius: _currentIndex == 1 ? 25 : 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onNavTap(1),
                          customBorder: CircleBorder(),
                          child: Icon(
                            _currentIndex == 1 ? Icons.close_rounded : Icons.add_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildModernBottomBar(),
    );
  }

  Widget _buildModernBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(_navItems[0], 0),
              SizedBox(width: 80),
              _buildNavItem(_navItems[2], 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, int index) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () => _onNavTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Color(0xFF1976D2).withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with scale animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isSelected ? 1.15 : 1.0),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Color(0xFF1976D2) : Colors.grey[600],
                    size: 26,
                  ),
                );
              },
            ),
            SizedBox(height: 4),
            // Label with fade animation
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected ? Color(0xFF1976D2) : Colors.grey[600],
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
              child: Text(item.label),
            ),
          ],
        ),
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