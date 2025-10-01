import 'package:flutter/material.dart';
import '../screens/rekap/rekap_anggota_dialog.dart';
import '../screens/rekap/input_pelanggaran_dialog.dart';
import '../widgets/rekap/header_summary.dart';
import '../widgets/rekap/filter_section.dart';
import '../widgets/rekap/filter_tabs.dart';
import '../widgets/rekap/pelanggaran_card.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  DateTimeRange? selectedDateRange;
  String activeFilter = 'Semua';
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showRekapAnggotaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const RekapAnggotaDialog(),
    );
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => InputPelanggaranDialog(
        onSaved: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pelanggaran berhasil dicatat',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              elevation: 8,
            ),
          );
        },
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      selectedDateRange = null;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      activeFilter = filter;
    });
    
    if (filter == 'Semua') {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (filter == 'Rekap') {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      activeFilter = index == 0 ? 'Semua' : 'Rekap';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Rekap Pelanggaran',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          FilterTabs(
            activeFilter: activeFilter,
            onFilterChanged: _onFilterChanged,
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildSemuaPelanggaranPage(),
                _buildRekapPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemuaPelanggaranPage() {
    return Column(
      children: [
        const HeaderSummary(
          totalPelanggaran: 12,
          pelanggaranBulanIni: 5,
          pelanggaranMingguIni: 2,
        ),
        
        FilterSection(
          selectedDateRange: selectedDateRange,
          onRekapPressed: _showRekapAnggotaDialog,
          onInputPressed: _showInputDialog,
          onResetFilter: _resetFilter,
        ),

        const SizedBox(height: 4),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PelanggaranCard(
                nama: 'Ahmad Rizki Pratama',
                kelas: 'XII IPA 1',
                tanggal: '28 Sep 2025',
                waktu: '07:15',
                jenisPelanggaran: 'Tidak Memakai Dasi',
                poin: 5,
                keterangan: 'Dasi tertinggal di rumah',
                icon: Icons.style,
                color: Colors.amber[700]!,
              ),
              PelanggaranCard(
                nama: 'Siti Nurhaliza',
                kelas: 'XI IPS 2',
                tanggal: '27 Sep 2025',
                waktu: '07:30',
                jenisPelanggaran: 'Sepatu Tidak Sesuai',
                poin: 10,
                keterangan: 'Memakai sepatu warna putih',
                icon: Icons.shopping_bag,
                color: Colors.red[600]!,
              ),
              PelanggaranCard(
                nama: 'Budi Santoso',
                kelas: 'XII IPA 2',
                tanggal: '25 Sep 2025',
                waktu: '07:10',
                jenisPelanggaran: 'Rambut Tidak Rapi',
                poin: 5,
                keterangan: 'Rambut melebihi batas ketentuan',
                icon: Icons.face,
                color: Colors.amber[700]!,
              ),
              PelanggaranCard(
                nama: 'Dewi Lestari',
                kelas: 'X IPA 3',
                tanggal: '23 Sep 2025',
                waktu: '07:45',
                jenisPelanggaran: 'Tidak Memakai Ikat Pinggang',
                poin: 5,
                keterangan: 'Ikat pinggang tidak dipakai saat upacara',
                icon: Icons.straighten,
                color: Colors.amber[700]!,
              ),
              PelanggaranCard(
                nama: 'Eko Prasetyo',
                kelas: 'XI IPS 1',
                tanggal: '20 Sep 2025',
                waktu: '07:20',
                jenisPelanggaran: 'Baju Tidak Dimasukkan',
                poin: 5,
                keterangan: 'Baju keluar dari celana saat pembelajaran',
                icon: Icons.checkroom,
                color: Colors.amber[700]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRekapPage() {
    return Column(
      children: [
        // Modern Header dengan Gradient
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF59E0B),
                Color(0xFFD97706),
                Color(0xFFB45309),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.assessment_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rekap Pelanggaran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Per Kelas & Siswa',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Action Button dengan design modern
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF2563EB).withOpacity(0.4),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showRekapAnggotaDialog,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.people_alt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Lihat Rekap Lengkap',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Section Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xFFF59E0B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Statistik Per Kelas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ),

        // Statistik Cards
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildModernRekapCard(
                title: 'XII IPA 1',
                totalSiswa: 32,
                totalPelanggaran: 8,
                icon: Icons.school_rounded,
                gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
              ),
              _buildModernRekapCard(
                title: 'XI IPS 2',
                totalSiswa: 30,
                totalPelanggaran: 5,
                icon: Icons.school_rounded,
                gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              _buildModernRekapCard(
                title: 'X IPA 3',
                totalSiswa: 28,
                totalPelanggaran: 12,
                icon: Icons.school_rounded,
                gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              _buildModernRekapCard(
                title: 'XII IPA 2',
                totalSiswa: 31,
                totalPelanggaran: 6,
                icon: Icons.school_rounded,
                gradientColors: [Color(0xFFA855F7), Color(0xFF9333EA)],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernRekapCard({
    required String title,
    required int totalSiswa,
    required int totalPelanggaran,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    // Tentukan severity berdasarkan jumlah pelanggaran
    Color pelanggaranColor;
    Color pelanggaranBgColor;
    String severity;
    
    if (totalPelanggaran >= 10) {
      pelanggaranColor = Color(0xFFDC2626);
      pelanggaranBgColor = Color(0xFFFEE2E2);
      severity = 'Tinggi';
    } else if (totalPelanggaran >= 6) {
      pelanggaranColor = Color(0xFFF59E0B);
      pelanggaranBgColor = Color(0xFFFEF3C7);
      severity = 'Sedang';
    } else {
      pelanggaranColor = Color(0xFF10B981);
      pelanggaranBgColor = Color(0xFFD1FAE5);
      severity = 'Rendah';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showRekapAnggotaDialog,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon dengan gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors[0].withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            '$totalSiswa siswa',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: pelanggaranBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalPelanggaran',
                        style: TextStyle(
                          color: pelanggaranColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: pelanggaranColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          color: pelanggaranColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRekapCard({
    required String title,
    required int totalSiswa,
    required int totalPelanggaran,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalSiswa siswa',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalPelanggaran',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}