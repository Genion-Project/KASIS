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
import 'package:bendahara_app/pages/profile_page.dart';
import 'package:bendahara_app/pages/about_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _aktivitasFuture;
  String _userName = 'Bendahara';
  String _jabatan = 'OSIS';

  @override
  void initState() {
    super.initState();
    print('\n🚀 [HOME] HomeScreen initialized');
    _loadUserData();
    _loadAktivitas();
  }

  Future<void> _loadUserData() async {
    print('👤 [HOME] Memuat data user dari SharedPreferences...');
    await initializeDateFormatting('id_ID', null);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Bendahara';
      _jabatan = prefs.getString('jabatan') ?? 'OSIS';
    });
    print('✅ [HOME] User data loaded: $_userName - $_jabatan\n');
  }

  void _loadAktivitas() {
    print('🔄 [HOME] Memuat ulang aktivitas...');
    setState(() {
      _aktivitasFuture = _fetchAktivitas();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAktivitas() async {
    print('🔄 [AKTIVITAS] Mulai fetch data aktivitas...');
    
    try {
      print('📡 [AKTIVITAS] Mengirim request ke API...');
      final results = await Future.wait([
        ApiService.getPemasukan(),
        ApiService.getPengeluaran(),
      ]);

      final pemasukan = results[0] as List<dynamic>;
      final pengeluaran = results[1] as List<dynamic>;

      print('✅ [AKTIVITAS] Data berhasil diambil:');
      print('   - Pemasukan: ${pemasukan.length} item');
      print('   - Pengeluaran: ${pengeluaran.length} item');

      List<Map<String, dynamic>> aktivitas = [];

      print('🔨 [AKTIVITAS] Memproses data pemasukan...');
      for (var item in pemasukan) {
        print('   📥 Pemasukan: ${item['keterangan']} - Rp ${item['jumlah']} (${item['tanggal']})');
        aktivitas.add({
          'title': 'Pemasukan - ${item['keterangan'] ?? 'Tidak ada keterangan'}',
          'amount': item['jumlah'] ?? 0,
          'type': 'pemasukan',
          'tanggal': item['tanggal'] ?? DateTime.now().toString(),
          'waktu': item['waktu'] ?? '',
        });
      }

      print('🔨 [AKTIVITAS] Memproses data pengeluaran...');
      for (var item in pengeluaran) {
        print('   📤 Pengeluaran: ${item['keterangan']} - Rp ${item['jumlah']} (${item['tanggal']})');
        aktivitas.add({
          'title': 'Pengeluaran - ${item['keterangan'] ?? 'Tidak ada keterangan'}',
          'amount': item['jumlah'] ?? 0,
          'type': 'pengeluaran',
          'tanggal': item['tanggal'] ?? DateTime.now().toString(),
          'waktu': item['waktu'] ?? '',
        });
      }

      print('📊 [AKTIVITAS] Total aktivitas sebelum sorting: ${aktivitas.length}');

      print('🔄 [AKTIVITAS] Mengurutkan berdasarkan tanggal...');
      aktivitas.sort((a, b) {
        try {
          DateTime dateA = DateTime.parse(a['tanggal']);
          DateTime dateB = DateTime.parse(b['tanggal']);
          return dateB.compareTo(dateA);
        } catch (e) {
          print('⚠️ [AKTIVITAS] Error parsing tanggal: $e');
          return 0;
        }
      });

      final result = aktivitas.take(5).toList();
      print('✅ [AKTIVITAS] Berhasil! Menampilkan ${result.length} aktivitas terbaru');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      return result;
    } catch (e) {
      print('❌ [AKTIVITAS] ERROR: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      throw Exception('Gagal memuat aktivitas: $e');
    }
  }

  String _formatRelativeTime(String tanggalStr) {
    try {
      print('🕐 [FORMAT] Memformat waktu: $tanggalStr');
      final tanggal = DateTime.parse(tanggalStr.split(' ')[0]);
      final now = DateTime.now();
      final difference = now.difference(tanggal);

      String result;
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            result = 'Baru saja';
          } else {
            result = '${difference.inMinutes} menit lalu';
          }
        } else {
          result = '${difference.inHours} jam lalu';
        }
      } else if (difference.inDays == 1) {
        result = '1 hari lalu';
      } else if (difference.inDays < 7) {
        result = '${difference.inDays} hari lalu';
      } else {
        result = DateFormat('dd MMM yyyy').format(tanggal);
      }
      
      print('   ✅ Hasil: $result');
      return result;
    } catch (e) {
      print('   ❌ Error format waktu: $e');
      return 'Tidak diketahui';
    }
  }

  String _formatCurrency(dynamic amount) {
    try {
      print('💰 [FORMAT] Memformat currency: $amount (${amount.runtimeType})');
      final number = amount is int ? amount : int.parse(amount.toString());
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      final result = formatter.format(number);
      print('   ✅ Hasil: $result');
      return result;
    } catch (e) {
      print('   ❌ Error format currency: $e');
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
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red[600],
                    size: 32,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Keluar dari Aplikasi?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
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
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Keluar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
              blurRadius: 25,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 8),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              SizedBox(height: 8),
              
              // Profile Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person_rounded, 
                          color: Colors.white, 
                          size: 32
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _jabatan,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.person_outline_rounded,
                title: 'Profil Saya',
                subtitle: 'Lihat dan edit profil',
                iconColor: Colors.blue[600]!,
                bgColor: Colors.blue[50]!,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProfilePage()),
                  );
                },
              ),
              
              _buildMenuItem(
                context,
                icon: Icons.info_outline_rounded,
                title: 'Tentang Aplikasi',
                subtitle: 'Informasi & versi app',
                iconColor: Colors.purple[600]!,
                bgColor: Colors.purple[50]!,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutPage()),
                  );
                },
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Divider(
                  height: 1, 
                  color: Colors.grey[200],
                  thickness: 1,
                ),
              ),
              
              _buildMenuItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Keluar',
                subtitle: 'Logout dari aplikasi',
                iconColor: Colors.red[600]!,
                bgColor: Colors.red[50]!,
                textColor: Colors.red[600]!,
                onTap: () => _showLogoutConfirmation(context),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    required Color bgColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.grey[900],
                      letterSpacing: 0.2,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded, 
                color: Colors.grey[400], 
                size: 20
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey[100] : Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            print('🔄 [HOME] Pull to refresh triggered');
            _loadAktivitas();
            await Future.delayed(Duration(milliseconds: 500));
            print('✅ [HOME] Refresh completed\n');
          },
          color: Colors.blue[700],
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(isTablet),
        ),
      ),
    );
  }

  // Desktop Layout - Grid dengan Sidebar
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar Kiri
        Container(
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
              // Profile Section di Sidebar
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.blue[700],
                        size: 40,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      _userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _jabatan,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildSidebarItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Dashboard',
                      isActive: true,
                    ),
                    _buildSidebarItem(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'Pemasukan',
                      color: Colors.green[600],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PemasukanPage()),
                        );
                        _loadAktivitas();
                      },
                    ),
                    _buildSidebarItem(
                      icon: Icons.remove_circle_outline_rounded,
                      label: 'Pengeluaran',
                      color: Colors.red[600],
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PengeluaranPage()),
                        );
                        _loadAktivitas();
                      },
                    ),
                    _buildSidebarItem(
                      icon: Icons.assessment_outlined,
                      label: 'Rekap',
                      color: Colors.blue[700],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RiwayatPage()),
                        );
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(),
                    ),
                    _buildSidebarItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profil',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ProfilePage()),
                        );
                      },
                    ),
                    _buildSidebarItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Tentang',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AboutPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Logout Button
              Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _showLogoutConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red[600],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Keluar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan Welcome Message
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Overview',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Kelola keuangan OSIS dengan mudah',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, 
                            size: 18, 
                            color: Colors.blue[700]
                          ),
                          SizedBox(width: 8),
                          Text(
                            DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32),
                
                // Top Cards Row - Balance & Quick Stats
                Row(
                  children: [
                    // Balance Card - Lebih besar
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue[700]!, Colors.blue[500]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
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
                                'Error loading balance',
                                style: TextStyle(color: Colors.white70),
                              );
                            } else {
                              final laporan = snapshot.data!;
                              final saldo = _formatCurrency(laporan['saldo']);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet_rounded,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Total Kas OSIS',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    saldo,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.trending_up_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Saldo Terkini',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 20),
                    
                    // Quick Actions - Vertical
                    Expanded(
                      child: Column(
                        children: [
                          _buildDesktopQuickAction(
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
                          SizedBox(height: 12),
                          _buildDesktopQuickAction(
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
                          SizedBox(height: 12),
                          _buildDesktopQuickAction(
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
                        ],
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 32),
                
                // Statistics Card (Full Width)
                StatCardWidget(),
                
                SizedBox(height: 32),
                
                // Recent Activities
                Container(
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 20,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.history_rounded,
                                  color: Colors.blue[700],
                                  size: 20,
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => RiwayatPage()),
                              );
                            },
                            icon: Icon(Icons.arrow_forward_rounded, size: 18),
                            label: Text('Lihat Semua'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildActivitiesList(isDesktop: true),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Mobile/Tablet Layout (Original yang sudah diupdate)
  Widget _buildMobileLayout(bool isTablet) {
    return Column(
      children: [
        // Clean Header
        Container(
          decoration: BoxDecoration(
            color: Colors.blue[700],
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  _userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showProfileMenu(context),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.blue[700],
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Balance Card
              Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: ApiService.getLaporan(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        );
                      } else {
                        final laporan = snapshot.data!;
                        final saldo = _formatCurrency(laporan['saldo']);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Total Kas Osis',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              saldo,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 36 : 32,
                                fontWeight: FontWeight.bold,
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

        // Quick Actions
        Container(
          color: Colors.grey[50],
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: isTablet ? _buildTabletQuickActions() : _buildMobileQuickActions(),
        ),

        // Main Content
        Expanded(
          child: Container(
            color: Colors.grey[50],
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Card
                  StatCardWidget(),

                  SizedBox(height: 24),

                  // Activities Header
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Aktivitas Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),

                  // Activity items
                  _buildActivitiesList(isDesktop: false),

                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk Quick Actions Mobile
  Widget _buildMobileQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAction(
            context,
            icon: Icons.add_circle_outline_rounded,
            label: 'Pemasukan',
            color: Colors.green[600]!,
            onTap: () async {
              print('➕ [HOME] Navigasi ke halaman Pemasukan');
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PemasukanPage()),
              );
              print('🔙 [HOME] Kembali dari halaman Pemasukan, refresh data...');
              _loadAktivitas();
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickAction(
            context,
            icon: Icons.remove_circle_outline_rounded,
            label: 'Pengeluaran',
            color: Colors.red[600]!,
            onTap: () async {
              print('➖ [HOME] Navigasi ke halaman Pengeluaran');
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PengeluaranPage()),
              );
              print('🔙 [HOME] Kembali dari halaman Pengeluaran, refresh data...');
              _loadAktivitas();
            },
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildQuickAction(
            context,
            icon: Icons.assessment_outlined,
            label: 'Rekap',
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
    );
  }

  // Widget untuk Quick Actions Tablet (2 kolom)
  Widget _buildTabletQuickActions() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildQuickAction(
          context,
          icon: Icons.add_circle_outline_rounded,
          label: 'Pemasukan',
          color: Colors.green[600]!,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PemasukanPage()),
            );
            _loadAktivitas();
          },
        ),
        _buildQuickAction(
          context,
          icon: Icons.remove_circle_outline_rounded,
          label: 'Pengeluaran',
          color: Colors.red[600]!,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PengeluaranPage()),
            );
            _loadAktivitas();
          },
        ),
        _buildQuickAction(
          context,
          icon: Icons.assessment_outlined,
          label: 'Rekap',
          color: Colors.blue[700]!,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RiwayatPage()),
            );
          },
        ),
      ],
    );
  }

  // Activities List (Reusable untuk Mobile & Desktop)
  Widget _buildActivitiesList({required bool isDesktop}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _aktivitasFuture,
      builder: (context, snapshot) {
        print('📱 [HOME] FutureBuilder state: ${snapshot.connectionState}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('⏳ [HOME] Loading aktivitas...');
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          print('❌ [HOME] Error di FutureBuilder: ${snapshot.error}');
          return Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red[600],
                    size: 22,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Gagal memuat aktivitas',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('📭 [HOME] Data aktivitas kosong');
          return Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Belum Ada Aktivitas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Transaksi Anda akan muncul di sini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        final aktivitas = snapshot.data!;
        print('✅ [HOME] Menampilkan ${aktivitas.length} aktivitas');
        
        return Column(
          children: aktivitas.map((item) {
            final isPemasukan = item['type'] == 'pemasukan';
            print('   📌 ${isPemasukan ? "Pemasukan" : "Pengeluaran"}: ${item['title']} - ${item['amount']}');
            
            return Padding(
              padding: EdgeInsets.only(bottom: isDesktop ? 12 : 10),
              child: _buildActivityItem(
                title: item['title'],
                amount: _formatCurrency(item['amount']),
                isPemasukan: isPemasukan,
                time: _formatRelativeTime(item['tanggal']),
                isDesktop: isDesktop,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Sidebar Item untuk Desktop
  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    Color? color,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.blue[700] : (color ?? Colors.grey[600]),
              size: 22,
            ),
            SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.blue[700] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop Quick Action Widget
  Widget _buildDesktopQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  // Activity Item Widget (Updated dengan parameter isDesktop)
  Widget _buildActivityItem({
    required String title,
    required String amount,
    required bool isPemasukan,
    required String time,
    bool isDesktop = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 18 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isDesktop ? 14 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 12 : 10),
            decoration: BoxDecoration(
              color: isPemasukan ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isPemasukan ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: isPemasukan ? Colors.green[600] : Colors.red[600],
              size: isDesktop ? 22 : 20,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Text(
            amount,
            style: TextStyle(
              fontSize: isDesktop ? 15 : 14,
              fontWeight: FontWeight.bold,
              color: isPemasukan ? Colors.green[600] : Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Widget (untuk Mobile/Tablet)
  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 22,
              ),
            ),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[800],
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