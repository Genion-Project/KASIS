import 'package:flutter/material.dart';
import '../widgets/quick_action_widget.dart';
import '../widgets/stat_card_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/activity_item_widget.dart';
import '../pages/login_page.dart'; 
import '../services/api_service.dart';
import 'package:bendahara_app/pages/pemasukan_page.dart';
import 'package:bendahara_app/pages/pengeluaran_page.dart';
import 'package:bendahara_app/pages/riwayat_page.dart';

class HomeScreen extends StatelessWidget {
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(Icons.person, color: Colors.white, size: 32),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Administrator',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Bendahara Osis',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: 'Profile',
              iconColor: Colors.blue[600]!,
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: 'Pengaturan',
              iconColor: Colors.grey[700]!,
              onTap: () => Navigator.pop(context),
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Bantuan',
              iconColor: Colors.grey[700]!,
              onTap: () => Navigator.pop(context),
            ),
            Divider(height: 32, thickness: 1),
            _buildMenuItem(
              context,
              icon: Icons.logout_rounded,
              title: 'Keluar',
              iconColor: Colors.red[500]!,
              textColor: Colors.red[500]!,
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.grey[800],
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced Header with modern gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Bendahara Osis',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _showProfileMenu(context),
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.blue[50],
                              child: Icon(
                                Icons.person_rounded,
                                color: Colors.blue[700],
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Balance Card
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: ApiService.getLaporan(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white70),
                            );
                          } else {
                            final laporan = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Total Saldo Kelas',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.95),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Rp ${laporan['saldo']}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions with modern cards
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModernQuickAction(
                      context,
                      icon: Icons.add_circle_rounded,
                      label: 'Pemasukan',
                      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PemasukanPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildModernQuickAction(
                      context,
                      icon: Icons.remove_circle_rounded,
                      label: 'Pengeluaran',
                      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PengeluaranPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildModernQuickAction(
                      context,
                      icon: Icons.warning_rounded,
                      label: 'Rekap Pelanggaran',
                      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RiwayatPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: Container(
                color: Colors.grey[50],
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Statistics Card
                      StatCardWidget(),

                      SizedBox(height: 28),

                      // Recent Activities Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.blue[600],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Aktivitas Terbaru',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[900],
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.arrow_forward_rounded, size: 18),
                            label: Text('Lihat Semua'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[600],
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),

                      // Activity items
                      ActivityItemWidget(
                        title: 'Iuran Bulanan - Ahmad',
                        amount: 'Rp 50.000',
                        color: Colors.green[500]!,
                        icon: Icons.arrow_downward,
                        time: '2 jam lalu',
                      ),
                      SizedBox(height: 12),
                      ActivityItemWidget(
                        title: 'Pembelian Perlengkapan',
                        amount: 'Rp 125.000',
                        color: Colors.red[500]!,
                        icon: Icons.arrow_upward,
                        time: '5 jam lalu',
                      ),
                      SizedBox(height: 12),
                      ActivityItemWidget(
                        title: 'Iuran Bulanan - Sari',
                        amount: 'Rp 50.000',
                        color: Colors.green[500]!,
                        icon: Icons.arrow_downward,
                        time: '1 hari lalu',
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}