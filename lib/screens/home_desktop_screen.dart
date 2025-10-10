import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:bendahara_app/pages/pemasukan_page.dart';
import 'package:bendahara_app/pages/pengeluaran_page.dart';
import 'package:bendahara_app/pages/riwayat_page.dart';
import 'package:bendahara_app/pages/profile_page.dart';
import 'package:bendahara_app/pages/about_page.dart';
import '../pages/login_page.dart';
import 'package:intl/intl.dart';

class HomeDesktopScreen extends StatefulWidget {
  const HomeDesktopScreen({super.key});

  @override
  State<HomeDesktopScreen> createState() => _HomeDesktopScreenState();
}

class _HomeDesktopScreenState extends State<HomeDesktopScreen> {
  late Future<List<Map<String, dynamic>>> _aktivitasFuture;
  String _userName = 'Bendahara';
  String _jabatan = 'OSIS';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    print('\n🖥️ [HOME-DESKTOP] HomeScreen initialized');
    _loadUserData();
    _loadAktivitas();
  }

  Future<void> _loadUserData() async {
    print('👤 [HOME-DESKTOP] Memuat data user dari SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Bendahara';
      _jabatan = prefs.getString('jabatan') ?? 'OSIS';
    });
    print('✅ [HOME-DESKTOP] User data loaded: $_userName - $_jabatan\n');
  }

  void _loadAktivitas() {
    print('🔄 [HOME-DESKTOP] Memuat ulang aktivitas...');
    setState(() {
      _aktivitasFuture = _fetchAktivitas();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAktivitas() async {
    try {
      final results = await Future.wait([
        ApiService.getPemasukan(),
        ApiService.getPengeluaran(),
      ]);

      final pemasukan = results[0] as List<dynamic>;
      final pengeluaran = results[1] as List<dynamic>;

      List<Map<String, dynamic>> aktivitas = [];

      for (var item in pemasukan) {
        aktivitas.add({
          'title': 'Pemasukan - ${item['keterangan'] ?? 'Tidak ada keterangan'}',
          'amount': item['jumlah'] ?? 0,
          'type': 'pemasukan',
          'tanggal': item['tanggal'] ?? DateTime.now().toString(),
          'waktu': item['waktu'] ?? '',
        });
      }

      for (var item in pengeluaran) {
        aktivitas.add({
          'title': 'Pengeluaran - ${item['keterangan'] ?? 'Tidak ada keterangan'}',
          'amount': item['jumlah'] ?? 0,
          'type': 'pengeluaran',
          'tanggal': item['tanggal'] ?? DateTime.now().toString(),
          'waktu': item['waktu'] ?? '',
        });
      }

      aktivitas.sort((a, b) {
        try {
          DateTime dateA = DateTime.parse(a['tanggal']);
          DateTime dateB = DateTime.parse(b['tanggal']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      return aktivitas.take(10).toList();
    } catch (e) {
      throw Exception('Gagal memuat aktivitas: $e');
    }
  }

  String _formatRelativeTime(String tanggalStr) {
    try {
      final tanggal = DateTime.parse(tanggalStr.split(' ')[0]);
      final now = DateTime.now();
      final difference = now.difference(tanggal);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Baru saja';
          } else {
            return '${difference.inMinutes} menit lalu';
          }
        } else {
          return '${difference.inHours} jam lalu';
        }
      } else if (difference.inDays == 1) {
        return '1 hari lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari lalu';
      } else {
        return DateFormat('dd MMM yyyy').format(tanggal);
      }
    } catch (e) {
      return 'Tidak diketahui';
    }
  }

  String _formatCurrency(dynamic amount) {
    try {
      final number = amount is int ? amount : int.parse(amount.toString());
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(number);
    } catch (e) {
      return 'Rp 0';
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red[600],
                    size: 40,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'Keluar dari Aplikasi?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);

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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),

          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo & App Title
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bendahara App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                    ),
                    Text(
                      'OSIS Management',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // User Info
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _jabatan,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildMenuItem(icon: Icons.dashboard_rounded, title: 'Dashboard', index: 0),
                _buildMenuItem(icon: Icons.add_circle_outline_rounded, title: 'Pemasukan', index: 1),
                _buildMenuItem(icon: Icons.remove_circle_outline_rounded, title: 'Pengeluaran', index: 2),
                _buildMenuItem(icon: Icons.assessment_outlined, title: 'Rekap Data', index: 3),
                Divider(height: 32, color: Colors.grey[200]),
                _buildMenuItem(icon: Icons.person_outline_rounded, title: 'Profil', index: 4),
                _buildMenuItem(icon: Icons.info_outline_rounded, title: 'Tentang', index: 5),
              ],
            ),
          ),

          // Logout Button
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: InkWell(
              onTap: () => _showLogoutConfirmation(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red[600], size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });

          // Navigate based on selection
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PemasukanPage()),
            ).then((_) => _loadAktivitas());
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PengeluaranPage()),
            ).then((_) => _loadAktivitas());
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RiwayatPage()),
            );
          } else if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfilePage()),
            );
          } else if (index == 5) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutPage()),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[50] : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue[700] : Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.blue[700] : Colors.grey[700],
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // Top Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () {
                    _loadAktivitas();
                  },
                  icon: Icon(Icons.refresh_rounded),
                  color: Colors.grey[700],
                  tooltip: 'Refresh',
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[700]),
                      SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Kas',
                          icon: Icons.account_balance_wallet_outlined,
                          color: Colors.blue[700]!,
                          future: ApiService.getLaporan(),
                          valueKey: 'saldo',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Pemasukan',
                          icon: Icons.trending_up_rounded,
                          color: Colors.green[600]!,
                          future: ApiService.getLaporan(),
                          valueKey: 'total_pemasukan',
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Pengeluaran',
                          icon: Icons.trending_down_rounded,
                          color: Colors.red[600]!,
                          future: ApiService.getLaporan(),
                          valueKey: 'total_pengeluaran',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Quick Actions
                  Text(
                    'Aksi Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Tambah Pemasukan',
                          color: Colors.green[600]!,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PemasukanPage()),
                            );
                            _loadAktivitas();
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.remove_circle_outline_rounded,
                          label: 'Tambah Pengeluaran',
                          color: Colors.red[600]!,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => PengeluaranPage()),
                            );
                            _loadAktivitas();
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.assessment_outlined,
                          label: 'Lihat Rekap',
                          color: Colors.blue[700]!,
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

                  SizedBox(height: 32),

                  // Recent Activities
                  Text(
                    'Aktivitas Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 16),

                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _aktivitasFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          padding: EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.red[100]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red[600],
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Terjadi Kesalahan',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat aktivitas',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(48),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum Ada Aktivitas',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Transaksi Anda akan muncul di sini',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final aktivitas = snapshot.data!;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: aktivitas.length,
                          separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            final item = aktivitas[index];
                            final isPemasukan = item['type'] == 'pemasukan';

                            return ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              leading: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isPemasukan ? Colors.green[50] : Colors.red[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isPemasukan ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                  color: isPemasukan ? Colors.green[600] : Colors.red[600],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      _formatRelativeTime(item['tanggal']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Text(
                                _formatCurrency(item['amount']),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isPemasukan ? Colors.green[600] : Colors.red[600],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Future<Map<String, dynamic>> future,
    required String valueKey,
  }) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Update',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          FutureBuilder<Map<String, dynamic>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 28,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                );
              } else {
                final data = snapshot.data!;
                final value = _formatCurrency(data[valueKey]);
                return Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
