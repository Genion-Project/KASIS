import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/rekap/rekap_anggota_dialog.dart';
import '../screens/rekap/input_pelanggaran_dialog.dart';
import 'detail_kelas_page.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    pelanggaranFuture = ApiService.getPelanggaran();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
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
            pelanggaranFuture = ApiService.getPelanggaran();
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

  void _onDateRangeChanged(DateTimeRange? dateRange) {
    setState(() {
      selectedDateRange = dateRange;
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

  List<Map<String, dynamic>> _filterByDateRange(List<Map<String, dynamic>> data) {
    if (selectedDateRange == null) {
      return _filterHariIni(data);
    }

    return data.where((item) {
      try {
        final tanggalString = (item['tanggal'] ?? '').toString();
        if (tanggalString.isEmpty) return false;

        final tanggal = DateTime.parse(tanggalString.split(' ')[0]);
        final startDate = DateTime(
          selectedDateRange!.start.year,
          selectedDateRange!.start.month,
          selectedDateRange!.start.day,
        );
        final endDate = DateTime(
          selectedDateRange!.end.year,
          selectedDateRange!.end.month,
          selectedDateRange!.end.day,
          23,
          59,
          59,
        );

        return tanggal.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
            tanggal.isBefore(endDate.add(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _filterHariIni(List<Map<String, dynamic>> data) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return data
        .where((item) => (item['tanggal'] ?? '').toString().startsWith(today))
        .toList();
  }

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

  // Helper methods untuk statistik
  int _getPelanggaranBulanIni(List<Map<String, dynamic>> data) {
    final now = DateTime.now();
    final thisMonth = DateFormat('yyyy-MM').format(now);
    return data.where((item) {
      final tanggal = item['tanggal']?.toString() ?? '';
      return tanggal.startsWith(thisMonth);
    }).length;
  }

  int _getPelanggaranMingguIni(List<Map<String, dynamic>> data) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return data.where((item) {
      try {
        final tanggal = DateTime.parse(item['tanggal']?.toString().split(' ')[0] ?? '');
        return tanggal.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    body: Row(
      children: [
        // Sidebar untuk desktop
        _buildDesktopSidebar(),

        // Konten utama
        Expanded(
          child: Column(
            children: [
              // AppBar untuk desktop
              Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),

                    // 🔙 Tombol kembali ke Home
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      tooltip: 'Kembali ke Home',
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                        // Jika kamu ingin langsung ke halaman Home tertentu:
                        // Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),

                    const SizedBox(width: 8),
                    const Text(
                      'Rekap Pelanggaran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Tabs
              FilterTabs(
                activeFilter: activeFilter,
                onFilterChanged: _onFilterChanged,
              ),

              // Konten PageView
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _buildDesktopSemuaPelanggaranPage(),
                    _buildDesktopRekapPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildDesktopSidebar() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 300,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? [];
        final filteredData = _filterByDateRange(data);
        
        return Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Summary dalam bentuk sidebar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.assessment_rounded, 
                                 color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Pelanggaran',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${filteredData.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDesktopStatCard(
                        icon: Icons.calendar_month_rounded,
                        iconBg: const Color(0xFFFFD93D),
                        value: '${_getPelanggaranBulanIni(data)}',
                        label: 'Bulan Ini',
                      ),
                      const SizedBox(height: 12),
                      _buildDesktopStatCard(
                        icon: Icons.calendar_today_rounded,
                        iconBg: const Color(0xFFFF6B6B),
                        value: '${_getPelanggaranMingguIni(data)}',
                        label: 'Minggu Ini',
                      ),
                    ],
                  ),
                ),
                
                // Filter Section dalam sidebar
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Date Range Picker
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.date_range_rounded, 
                                     size: 20, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  'Rentang Tanggal',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final DateTimeRange? picked = 
                                    await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                      initialDateRange: selectedDateRange,
                                    );
                                  if (picked != null) {
                                    _onDateRangeChanged(picked);
                                  }
                                },
                                icon: const Icon(Icons.calendar_today_rounded, size: 16),
                                label: Text(
                                  selectedDateRange != null
                                      ? '${DateFormat('dd MMM yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}'
                                      : 'Pilih Tanggal',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            if (selectedDateRange != null) ...[
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: _resetFilter,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text('Reset Filter'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Action Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showInputDialog,
                              icon: const Icon(Icons.add_circle_rounded),
                              label: Text('Input Pelanggaran'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showRekapAnggotaDialog,
                              icon: const Icon(Icons.people_alt_rounded),
                              label: Text('Rekap Anggota'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopStatCard({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSemuaPelanggaranPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Data pelanggaran kosong'));
        }

        final filteredData = _filterByDateRange(snapshot.data!);
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Pelanggaran',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data pelanggaran',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.6,
                        ),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final item = filteredData[index];
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
          ),
        );
      },
    );
  }

  Widget _buildDesktopRekapPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Data rekap kosong'));
        }

        final filteredData = _filterByDateRange(snapshot.data!);
        final Map<String, Map<String, int>> rekapKelas = {};
        
        for (var item in filteredData) {
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

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rekap per Kelas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showRekapAnggotaDialog,
                    icon: const Icon(Icons.people_alt_rounded),
                    label: Text('Rekap Lengkap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: rekapKelas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada data rekap',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: rekapKelas.length,
                        itemBuilder: (context, index) {
                          final entry = rekapKelas.entries.elementAt(index);
                          final kelas = entry.key;
                          final totalSiswa = entry.value['total_siswa']!;
                          final totalPelanggaran = entry.value['total_pelanggaran']!;
                          
                          return _buildDesktopRekapCard(
                            title: kelas,
                            totalSiswa: totalSiswa,
                            totalPelanggaran: totalPelanggaran,
                            onTap: () => _navigateToDetailKelas(kelas, filteredData),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopRekapCard({
    required String title,
    required int totalSiswa,
    required int totalPelanggaran,
    required VoidCallback onTap,
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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '$totalSiswa siswa',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: pelanggaranBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalPelanggaran poin',
                  style: TextStyle(
                    color: pelanggaranColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: pelanggaranColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity,
                  style: TextStyle(
                    color: pelanggaranColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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

                    final filteredData = _filterByDateRange(snapshot.data!);
                    return _buildSemuaPelanggaranPage(filteredData);
                  },
                ),
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

                    final filteredData = _filterByDateRange(snapshot.data!);
                    return _buildRekapPage(filteredData);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk mobile layout (yang sudah ada sebelumnya)
  Widget _buildSemuaPelanggaranPage(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: HeaderSummary(
              totalPelanggaran: data.length,
              pelanggaranBulanIni: data.length, // Logic can be improved
              pelanggaranMingguIni: data.length, // Logic can be improved
            ),
          ),
          SliverToBoxAdapter(
            child: FilterSection(
              selectedDateRange: selectedDateRange,
              onRekapPressed: _showRekapAnggotaDialog,
              onInputPressed: _showInputDialog,
              onResetFilter: _resetFilter,
              onDateRangeChanged: _onDateRangeChanged,
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada data pelanggaran',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedDateRange != null
                        ? 'pada rentang tanggal yang dipilih'
                        : 'pada hari ini',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );
    }

    // Responsive grid layout for tablet/desktop
    final width = MediaQuery.of(context).size.width;
    final isTablet = width > 600;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: HeaderSummary(
            totalPelanggaran: data.length,
            pelanggaranBulanIni: data.length, // You might want real counts here
            pelanggaranMingguIni: data.length, // You might want real counts here
          ),
        ),
        SliverToBoxAdapter(
          child: FilterSection(
            selectedDateRange: selectedDateRange,
            onRekapPressed: _showRekapAnggotaDialog,
            onInputPressed: _showInputDialog,
            onResetFilter: _resetFilter,
            onDateRangeChanged: _onDateRangeChanged,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(top: 8)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: isTablet
              ? SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 500,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
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
                    childCount: data.length,
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = data[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PelanggaranCard(
                          nama: item['nama'] ?? '-',
                          kelas: item['kelas'] ?? '-',
                          tanggal: item['tanggal'] ?? '-',
                          waktu: item['waktu'] ?? '-',
                          jenisPelanggaran: item['jenis_pelanggaran'] ?? '-',
                          poin: item['poin']?.toInt() ?? 0,
                          keterangan: item['keterangan'] ?? '-',
                          icon: Icons.warning_amber_outlined,
                          color: Colors.amber[700]!,
                        ),
                      );
                    },
                    childCount: data.length,
                  ),
                ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
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

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Collapsing Header
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFFF59E0B),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
            title: null,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFFB45309)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFF59E0B),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 12),
                  Text(
                    'Rekap Pelanggaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          ),
        ),

        // Action Button
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2563EB),
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
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
        ),

        // List Cards
        rekapKelas.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada data rekap',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedDateRange != null
                            ? 'pada rentang tanggal yang dipilih'
                            : 'pada hari ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = rekapKelas.entries.elementAt(index);
                      final kelas = entry.key;
                      final totalSiswa = entry.value['total_siswa']!;
                      final totalPelanggaran = entry.value['total_pelanggaran']!;
                      return _buildModernRekapCard(
                        title: kelas,
                        totalSiswa: totalSiswa,
                        totalPelanggaran: totalPelanggaran,
                        icon: Icons.school_rounded,
                        gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        onTap: () => _navigateToDetailKelas(kelas, data),
                      );
                    },
                    childCount: rekapKelas.length,
                  ),
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
    required VoidCallback onTap,
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
          onTap: onTap,
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