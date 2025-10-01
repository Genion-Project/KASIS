import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/rekap/rekap_anggota_dialog.dart';
import '../screens/rekap/input_pelanggaran_dialog.dart';
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
              content: const Text('Pelanggaran berhasil dicatat'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          // refresh data
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

  // Filter data hanya untuk tanggal hari ini
  List<Map<String, dynamic>> _filterHariIni(List<Map<String, dynamic>> data) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return data.where((item) {
      final tanggal = item['tanggal'] ?? '';
      return tanggal.startsWith(today);
    }).toList();
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
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: pelanggaranFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Data pelanggaran kosong'));
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
    // buat rekap per kelas
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
           (rekapKelas[kelas]!['total_pelanggaran']! + (item['poin']?.toInt() ?? 0)).toInt();
      }
    }

    return Column(
      children: [
        // Header
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // List rekap
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: rekapKelas.entries.map((entry) {
              final kelas = entry.key;
              final totalSiswa = entry.value['total_siswa']!;
              final totalPelanggaran = entry.value['total_pelanggaran']!;
              return _buildRekapCard(
                title: kelas,
                totalSiswa: totalSiswa,
                totalPelanggaran: totalPelanggaran,
                icon: Icons.school,
                color: Colors.blue[700]!,
              );
            }).toList(),
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
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text('$totalSiswa siswa',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.red[50], borderRadius: BorderRadius.circular(20)),
              child: Text('$totalPelanggaran',
                  style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
