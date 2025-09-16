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
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person_outline, color: Colors.blue[600]),
              title: Text('Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.settings_outlined, color: Colors.grey[600]),
              title: Text('Pengaturan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Colors.grey[600]),
              title: Text('Bantuan'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[400]),
              title: Text('Keluar', style: TextStyle(color: Colors.red[400])),
              onTap: () async {
                // hapus flag login
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // atau hanya prefs.remove('isLoggedIn')

                // arahkan ke halaman login
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()), // hapus const
                    (route) => false,
                  );
                }
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[700]!, Colors.blue[600]!],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        FutureBuilder<Map<String, dynamic>>(
                          future: ApiService.getLaporan(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final laporan = snapshot.data!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Saldo',
                                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Rp ${laporan['saldo']}',
                                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showProfileMenu(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.blue[600],
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Quick Actions with enhanced styling
            Container(
              color: Colors.blue[700],
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickActionWidget(
                    icon: Icons.add_circle_outline,
                    label: 'Pemasukan',
                    color: Colors.green[500]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PemasukanPage()),
                      );
                    },
                  ),
                  QuickActionWidget(
                    icon: Icons.remove_circle_outline,
                    label: 'Pengeluaran',
                    color: Colors.red[500]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PengeluaranPage()),
                      );
                    },
                  ),
                  QuickActionWidget(
                    icon: Icons.history_outlined,
                    label: 'Riwayat',
                    color: Colors.purple[500]!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RiwayatPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content with improved container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small indicator at top
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20),

                      // Statistics Card
                      StatCardWidget(),

                      SizedBox(height: 25),

                      // Recent Activities with improved header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aktivitas Terbaru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                              letterSpacing: 0.2,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 15),

                      // Activity items with enhanced spacing
                      ActivityItemWidget(
                        title: 'Iuran Bulanan - Ahmad',
                        amount: 'Rp 50.000',
                        color: Colors.green[500]!,
                        icon: Icons.arrow_downward,
                        time: '2 jam lalu',
                      ),
                      SizedBox(height: 8),
                      ActivityItemWidget(
                        title: 'Pembelian Perlengkapan',
                        amount: 'Rp 125.000',
                        color: Colors.red[500]!,
                        icon: Icons.arrow_upward,
                        time: '5 jam lalu',
                      ),
                      SizedBox(height: 8),
                      ActivityItemWidget(
                        title: 'Iuran Bulanan - Sari',
                        amount: 'Rp 50.000',
                        color: Colors.green[500]!,
                        icon: Icons.arrow_downward,
                        time: '1 hari lalu',
                      ),

                      SizedBox(height: 100), // Bottom padding for FAB
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
}