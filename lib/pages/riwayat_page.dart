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
import '../widgets/rekap/weekly_trend_chart.dart';
import 'package:provider/provider.dart';
import '../providers/violation_provider.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  DateTimeRange? selectedDateRange;
  String activeFilter = 'Semua';
  String _searchQuery = '';
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViolationProvider>().fetchViolations();
    });
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

          context.read<ViolationProvider>().fetchViolations();
        },
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      selectedDateRange = null;
    });
  }

  Future<void> _refreshData() async {
    await context.read<ViolationProvider>().fetchViolations();
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

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> filtered = data;

    // Filter by Date Range
    if (selectedDateRange == null) {
      filtered = _filterHariIni(filtered);
    } else {
      filtered = filtered.where((item) {
        try {
          final tanggalString = (item['tanggal'] ?? '').toString();
          if (tanggalString.isEmpty) return false;

          // Parse only date part to avoid timezone issues
          final datePart = tanggalString.split(' ')[0];
          final tanggal = DateTime.parse(datePart);
          
          final start = DateTime(
            selectedDateRange!.start.year,
            selectedDateRange!.start.month,
            selectedDateRange!.start.day,
          );
          
          final end = DateTime(
            selectedDateRange!.end.year,
            selectedDateRange!.end.month,
            selectedDateRange!.end.day,
            23, 59, 59 // End of day
          );

          return (tanggal.isAtSameMomentAs(start) || tanggal.isAfter(start)) && 
                 (tanggal.isAtSameMomentAs(end) || tanggal.isBefore(end));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final nama = (item['nama'] ?? '').toString().toLowerCase();
        final kelas = (item['kelas'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return nama.contains(query) || kelas.contains(query);
      }).toList();
    }

    return filtered;
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInputDialog,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Input Pelanggaran'),
        elevation: 4,
        highlightElevation: 8,
      ),
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
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 🔙 Tombol kembali ke Home
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                          color: Colors.grey[700],
                          tooltip: 'Kembali ke Home',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      const SizedBox(width: 20),
                      
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekap Pelanggaran',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            'Kelola data pelanggaran siswa',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      // Search Bar
                      Container(
                        width: 300,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari siswa atau kelas...',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Tabs
                Container(
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  child: FilterTabs(
                    activeFilter: activeFilter,
                    onFilterChanged: _onFilterChanged,
                  ),
                ),

                // Konten PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe to avoid conflict
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
    return Consumer<ViolationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return SizedBox(
            width: 380,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = provider.violations;
        final filteredData = _applyFilters(data);
        
        return Container(
          width: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(4, 0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Summary dengan Card Putih di atas Background Biru
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Total Pelanggan Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.assessment_rounded, 
                                           color: Colors.blue[700], size: 24),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Total Pelanggaran',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${filteredData.length}',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kasus tercatat',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Stat Cards (Bulan Ini & Minggu Ini)
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStatCard(
                              title: 'Bulan Ini',
                              value: '${_getPelanggaranBulanIni(data)}',
                              icon: Icons.calendar_month_rounded,
                              color: Colors.amber[700]!,
                              bgColor: Colors.amber[50]!,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMiniStatCard(
                              title: 'Minggu Ini',
                              value: '${_getPelanggaranMingguIni(data)}',
                              icon: Icons.calendar_today_rounded,
                              color: Colors.red[600]!,
                              bgColor: Colors.red[50]!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Weekly Trend Chart Section
                Container(
                  width: double.infinity,
                  color: Colors.blue[50]?.withOpacity(0.3),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.show_chart_rounded, size: 20, color: Colors.grey[800]),
                          const SizedBox(width: 8),
                          Text(
                            'Tren Mingguan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: WeeklyTrendChart(data: data),
                      ),
                    ],
                  ),
                ),
                
                // Filter Section within sidebar
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Data',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date Range Picker
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                final DateTimeRange? picked = 
                                  await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2100),
                                    initialDateRange: selectedDateRange,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: const Color(0xFF2563EB),
                                            onPrimary: Colors.white,
                                            onSurface: Colors.grey[900]!,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                if (picked != null) {
                                  _onDateRangeChanged(picked);
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, 
                                         size: 18, color: Colors.grey[600]),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedDateRange != null
                                            ? '${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(selectedDateRange!.end)}'
                                            : 'Pilih Rentang Tanggal',
                                        style: TextStyle(
                                          color: selectedDateRange != null 
                                            ? Colors.grey[900] 
                                            : Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            if (selectedDateRange != null) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  onPressed: _resetFilter,
                                  icon: const Icon(Icons.refresh_rounded, size: 16),
                                  label: const Text('Reset Filter'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Secondary Action Button (Rekap Anggota)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showRekapAnggotaDialog,
                          icon: const Icon(Icons.people_alt_rounded, size: 20),
                          label: const Text('Rekap Anggota Lengkap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFF2563EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildDesktopSemuaPelanggaranPage() {
    return Consumer<ViolationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Koneksi Gagal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 8),
                Text(provider.error!, style: TextStyle(color: Colors.grey[500])),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchViolations(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        } else if (provider.violations.isEmpty) {
          return const Center(child: Text('Data pelanggaran kosong'));
        }

        final filteredData = _applyFilters(provider.violations);
        filteredData.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
        
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
    return Consumer<ViolationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Koneksi Gagal',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 8),
                Text(provider.error!, style: TextStyle(color: Colors.grey[500])),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.fetchViolations(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        } else if (provider.violations.isEmpty) {
          return const Center(child: Text('Data rekap kosong'));
        }

        final filteredData = _applyFilters(provider.violations);
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
    return Consumer<ViolationProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                    ),
                    child: Icon(Icons.wifi_off_rounded, size: 64, color: Colors.blue[300]),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Koneksi Terputus',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchViolations(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isLoading = provider.isLoading;
        final data = provider.violations;
        final filteredData = _applyFilters(data);
        
        // Perhitungan Statistik Real-time
        final totalPelanggaran = filteredData.length;
        final bulanIni = _getPelanggaranBulanIni(data);
        final mingguIni = _getPelanggaranMingguIni(data);

        return Scaffold(
          backgroundColor: const Color(0xFFF1F5F9), // Slate 100
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showInputDialog,
            backgroundColor: const Color(0xFF2563EB),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Input', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 300.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF1E3A8A),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, 
                               color: Colors.white, size: 18),
                    ),
                  ),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                    child: const Text(
                      'Rekap Pelanggaran',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  flexibleSpace: ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 50,
                          bottom: 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Kasus Tercatat',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLoading ? '-' : '$totalPelanggaran',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(child: _buildHeaderStatItem(
                                  'Bulan Ini', 
                                  isLoading ? '-' : '$bulanIni', 
                                  Icons.calendar_month_rounded,
                                  const Color(0xFF60A5FA)
                                )),
                                const SizedBox(width: 16),
                                Expanded(child: _buildHeaderStatItem(
                                  'Minggu Ini', 
                                  isLoading ? '-' : '$mingguIni', 
                                  Icons.access_time_filled_rounded,
                                  const Color(0xFFFACC15)
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                const SizedBox(height: 16),
                // Filter Tabs & Date Picker Row (Sticky-like behavior in UI flow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      // Date Filter Button
                      InkWell(
                        onTap: () async {
                          final DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDateRange: selectedDateRange,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: const Color(0xFF2563EB),
                                    onPrimary: Colors.white,
                                    onSurface: Colors.grey[900]!,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            _onDateRangeChanged(picked);
                          }
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: selectedDateRange != null 
                                ? Border.all(color: const Color(0xFF2563EB), width: 1.5)
                                : null,
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            color: selectedDateRange != null ? const Color(0xFF2563EB) : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Navigation Tabs
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              _buildTabItem('Semua', activeFilter == 'Semua'),
                              _buildTabItem('Rekap', activeFilter == 'Rekap'),
                            ],
                          ),
                        ),
                      ),
                      if (selectedDateRange != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _resetFilter,
                          borderRadius: BorderRadius.circular(14),
                           child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: Colors.red[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Content
                Expanded(
                  child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        children: [
                          filteredData.isEmpty 
                              ? _buildEmptyState('Belum ada data', 'Coba ubah filter tanggal') 
                              : _buildSemuaPelanggaranPage(filteredData),
                          
                          // Halaman Rekap (Group by Class)
                          _buildRekapPageKelas(data),
                        ],
                      ),
                ),
              ],
            ),
          ),
        ),
        );
      }
    );
  }

  // Improved Rekap Page (Group by Kelas)
  Widget _buildRekapPageKelas(List<Map<String, dynamic>> data) {
    // Filter data if date range is selected
    final listToProcess = _applyFilters(data);

    if (listToProcess.isEmpty) {
       // Jika kosong karena filter hari ini, tampilkan pesan yang sesuai
       if (selectedDateRange == null) {
         return _buildEmptyState('Belum ada data hari ini', 'Gunakan filter tanggal untuk melihat rekap');
       }
       return _buildEmptyState('Tidak ada data', 'Pada rentang tanggal ini');
    }

    // Grouping Data by Class
    final Map<String, Map<String, dynamic>> rekapKelas = {};
    
    for (var item in listToProcess) {
      final kelas = item['kelas'] ?? 'Tanpa Kelas';
      final nama = item['nama'] ?? 'Tanpa Nama';
      final poin = int.tryParse(item['poin'].toString()) ?? 0;
      
      if (!rekapKelas.containsKey(kelas)) {
        rekapKelas[kelas] = {
           'kelas': kelas,
           'total_poin': 0,
           'total_kasus': 0,
           'siswa': <String, Map<String, dynamic>>{} // Map of student name -> stats
        };
      }
      
      rekapKelas[kelas]!['total_poin'] += poin;
      rekapKelas[kelas]!['total_kasus'] += 1;
      
      // Update data siswa dalam kelas tersebut
      var siswaMap = rekapKelas[kelas]!['siswa'] as Map<String, Map<String, dynamic>>;
      if (!siswaMap.containsKey(nama)) {
         siswaMap[nama] = {'nama': nama, 'poin': 0, 'kasus': 0};
      }
      siswaMap[nama]!['poin'] += poin;
      siswaMap[nama]!['kasus'] += 1;
    }
    
    // Sort kelas berdasarkan total poin tertinggi
    final sortedKelas = rekapKelas.values.toList()
      ..sort((a, b) => b['total_poin'].compareTo(a['total_poin']));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 80, left: 24, right: 24),
      itemCount: sortedKelas.length,
      itemBuilder: (context, index) {
        final dataKelas = sortedKelas[index];
        final totalPoinKelas = dataKelas['total_poin'] as int;
        
        // Convert map siswa to list and sort
        final Map<String, Map<String, dynamic>> siswaMap = dataKelas['siswa'];
        final List<Map<String, dynamic>> sortedSiswa = siswaMap.values.toList()
           ..sort((a, b) => b['poin'].compareTo(a['poin']));

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              childrenPadding: const EdgeInsets.only(bottom: 16),
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dataKelas['kelas'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                    fontSize: 16,
                  ),
                ),
              ),
              title: Text(
                '${dataKelas['total_kasus']} Pelanggaran',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
              subtitle: Text(
                'Total Poin: $totalPoinKelas',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              children: sortedSiswa.map((siswa) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: (siswa['poin'] >= 50) ? Colors.red : Colors.blue[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          siswa['nama'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${siswa['poin']} Poin',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onFilterChanged(title),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatItem(String label, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded, size: 48, color: Colors.blue[300]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
          ],
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
            child: FilterSection(
              selectedDateRange: selectedDateRange,
              onRekapPressed: _showRekapAnggotaDialog,
              onInputPressed: _showInputDialog,
              onResetFilter: _resetFilter,
              onDateRangeChanged: _onDateRangeChanged,
            ),
          ),
          SliverFillRemaining(
            child: _buildEmptyState('Tidak ada data', 'Silakan ubah filter atau input baru'),
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
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: FilterSection(
              selectedDateRange: selectedDateRange,
              onRekapPressed: _showRekapAnggotaDialog,
              onInputPressed: _showInputDialog,
              onResetFilter: _resetFilter,
              onDateRangeChanged: _onDateRangeChanged,
            ),
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
                      String displayDate = item['tanggal']?.toString() ?? '-';
                      // Jika tanggal tidak punya info jam, coba ambil dari created_at
                      if (!displayDate.contains(' ') && !displayDate.contains('T') && item['created_at'] != null) {
                        displayDate = item['created_at'].toString();
                      }
                      
                      // Coba ambil waktu dari berbagai kemungkinan key
                      String infoWaktu = item['waktu']?.toString() ?? 
                                         item['jam']?.toString() ?? 
                                         item['time']?.toString() ?? '-';

                      return PelanggaranCard(
                        nama: item['nama'] ?? '-',
                        kelas: item['kelas'] ?? '-',
                        tanggal: displayDate,
                        waktu: infoWaktu,
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
                      String displayDate = item['tanggal']?.toString() ?? '-';
                      // Jika tanggal tidak punya info jam, coba ambil dari created_at
                      if (!displayDate.contains(' ') && !displayDate.contains('T') && item['created_at'] != null) {
                        displayDate = item['created_at'].toString();
                      }

                      // Coba ambil waktu dari berbagai kemungkinan key
                      String infoWaktu = item['waktu']?.toString() ?? 
                                         item['jam']?.toString() ?? 
                                         item['time']?.toString() ?? '-';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PelanggaranCard(
                          nama: item['nama'] ?? '-',
                          kelas: item['kelas'] ?? '-',
                          tanggal: displayDate,
                          waktu: infoWaktu,
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
          backgroundColor: const Color(0xFF1E3A8A),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.zero,
            title: null,
            background: Container(

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)], // Slate & Blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2563EB),
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