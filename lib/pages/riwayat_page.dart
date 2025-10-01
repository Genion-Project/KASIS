import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/rekap/rekap_anggota_dialog.dart';
import '../screens/rekap/input_pelanggaran_dialog.dart';
import 'detail_kelas_page.dart'; // Ubah import ini - file ada di folder yang sama (pages)
import '../widgets/rekap/header_summary.dart';
import '../widgets/rekap/filter_section.dart';
import '../widgets/rekap/filter_tabs.dart';
import '../widgets/rekap/pelanggaran_card.dart';
import '../services/api_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  DateTimeRange? selectedDateRange;
  String activeFilter = 'Semua';
  final PageController _pageController = PageController();
  late Future<List<Map<String, dynamic>>> pelanggaranFuture;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    pelanggaranFuture = apiService.getPelanggaran();
  }

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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
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
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              elevation: 8,
            ),
          );

          setState(() {
            pelanggaranFuture = apiService.getPelanggaran();
          });
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
      _pageController.animateToPage(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (filter == 'Rekap') {
      _pageController.animateToPage(1,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      activeFilter = index == 0 ? 'Semua' : 'Rekap';
    });
  }

  // Filter data hanya untuk tanggal hari ini
  List<Map<String, dynamic>> _filterHariIni(List<Map<String, dynamic>> data) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return data
        .where((item) => (item['tanggal'] ?? '').toString().startsWith(today))
        .toList();
  }

  // Navigasi ke halaman detail kelas
  void _navigateToDetailKelas(String kelas, List<Map<String, dynamic>> allData) {
    final dataSiswaKelas = allData.where((item) => item['kelas'] == kelas).toList();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailKelasPage(
          namaKelas: kelas,
          dataSiswa: dataSiswaKelas,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
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
          preferredSize: const Size.fromHeight(1),
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
                // Halaman Semua Pelanggaran
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: pelanggaranFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Data pelanggaran kosong'));
                    }

                    final dataHariIni = _filterHariIni(snapshot.data!);
                    return _buildSemuaPelanggaranPage(dataHariIni);
                  },
                ),

                // Halaman Rekap
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: pelanggaranFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Data rekap kosong'));
                    }

                    final dataHariIni = _filterHariIni(snapshot.data!);
                    return _buildRekapPage(dataHariIni);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemuaPelanggaranPage(List<Map<String, dynamic>> data) {
    return Column(
      children: [
        HeaderSummary(
          totalPelanggaran: data.length,
          pelanggaranBulanIni: data.length,
          pelanggaranMingguIni: data.length,
        ),
        FilterSection(
          selectedDateRange: selectedDateRange,
          onRekapPressed: _showRekapAnggotaDialog,
          onInputPressed: _showInputDialog,
          onResetFilter: _resetFilter,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return PelanggaranCard(
                nama: item['nama'] ?? '-',
                kelas: item['kelas'] ?? '-',
                tanggal: item['tanggal'] ?? '-',
                waktu: item['waktu'] ?? '-',
                jenisPelanggaran: item['jenis_pelanggaran'] ?? '-',
                poin: item['poin']?.toInt() ?? 0,
                keterangan: item['keterangan'] ?? '-',
                icon: Icons.warning_amber_outlined,
                color: Colors.amber[700]!,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRekapPage(List<Map<String, dynamic>> data) {
    final Map<String, Map<String, int>> rekapKelas = {};
    for (var item in data) {
      final kelas = item['kelas'] ?? 'Tidak diketahui';
      if (!rekapKelas.containsKey(kelas)) {
        rekapKelas[kelas] = {
          'total_siswa': 1,
          'total_pelanggaran': item['poin']?.toInt() ?? 0
        };
      } else {
        rekapKelas[kelas]!['total_siswa'] =
            rekapKelas[kelas]!['total_siswa']! + 1;
        rekapKelas[kelas]!['total_pelanggaran'] =
            (rekapKelas[kelas]!['total_pelanggaran']! +
                    (item['poin']?.toInt() ?? 0))
                .toInt();
      }
    }

    return Column(
      children: [
        // Modern Header dengan Gradient
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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

        // Action Button modern
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
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
                      horizontal: 24, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.people_alt_rounded,
                          color: Colors.white, size: 22),
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
                      Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Statistik Cards
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: rekapKelas.entries.map((entry) {
              final kelas = entry.key;
              final totalSiswa = entry.value['total_siswa']!;
              final totalPelanggaran = entry.value['total_pelanggaran']!;
              return _buildModernRekapCard(
                title: kelas,
                totalSiswa: totalSiswa,
                totalPelanggaran: totalPelanggaran,
                icon: Icons.school_rounded,
                gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                onTap: () => _navigateToDetailKelas(kelas, data), // Tambahkan navigasi
              );
            }).toList(),
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
    required VoidCallback onTap, // Tambahkan parameter onTap
  }) {
    Color pelanggaranColor;
    Color pelanggaranBgColor;
    String severity;

    if (totalPelanggaran >= 50) {
      pelanggaranColor = const Color(0xFFDC2626);
      pelanggaranBgColor = const Color(0xFFFEE2E2);
      severity = 'Tinggi';
    } else if (totalPelanggaran >= 30) {
      pelanggaranColor = const Color(0xFFF59E0B);
      pelanggaranBgColor = const Color(0xFFFEF3C7);
      severity = 'Sedang';
    } else {
      pelanggaranColor = const Color(0xFF10B981);
      pelanggaranBgColor = const Color(0xFFD1FAE5);
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, // Gunakan onTap yang dikirim sebagai parameter
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
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
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.2)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.people_outline,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('$totalSiswa siswa',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500)),
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
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: pelanggaranBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('$totalPelanggaran',
                          style: TextStyle(
                              color: pelanggaranColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: pelanggaranColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(severity,
                          style: TextStyle(
                              color: pelanggaranColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
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
}