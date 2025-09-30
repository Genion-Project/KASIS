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
              content: const Text('Pelanggaran berhasil dicatat'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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
    
    // Pindah ke halaman yang sesuai
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Riwayat'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
                // Halaman Semua Pelanggaran
                _buildSemuaPelanggaranPage(),
                
                // Halaman Rekap
                _buildRekapPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Halaman Semua Pelanggaran
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

        const SizedBox(height: 8),

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

  // Halaman Rekap
  Widget _buildRekapPage() {
    return Column(
      children: [
        // Header untuk halaman Rekap
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 48,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 12),
              const Text(
                'Rekap Pelanggaran',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Per Kelas & Siswa',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Tombol lihat detail rekap
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showRekapAnggotaDialog,
            icon: const Icon(Icons.people_alt),
            label: const Text('Lihat Rekap Lengkap'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Statistik ringkas
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildRekapCard(
                title: 'XII IPA 1',
                totalSiswa: 32,
                totalPelanggaran: 8,
                icon: Icons.school,
                color: Colors.blue[700]!,
              ),
              _buildRekapCard(
                title: 'XI IPS 2',
                totalSiswa: 30,
                totalPelanggaran: 5,
                icon: Icons.school,
                color: Colors.green[700]!,
              ),
              _buildRekapCard(
                title: 'X IPA 3',
                totalSiswa: 28,
                totalPelanggaran: 12,
                icon: Icons.school,
                color: Colors.orange[700]!,
              ),
              _buildRekapCard(
                title: 'XII IPA 2',
                totalSiswa: 31,
                totalPelanggaran: 6,
                icon: Icons.school,
                color: Colors.purple[700]!,
              ),
            ],
          ),
        ),
      ],
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