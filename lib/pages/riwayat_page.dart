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

class _RiwayatPageState extends State<RiwayatPage> with SingleTickerProviderStateMixin {
  DateTimeRange? selectedDateRange;
  String activeFilter = 'Semua';
  final PageController _pageController = PageController();
  late Future<List<Map<String, dynamic>>> pelanggaranFuture;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Constants
  static const _primaryColor = Color(0xFF6366F1);
  static const _secondaryColor = Color(0xFF8B5CF6);
  static const _accentColor = Color(0xFF06B6D4);
  static const _backgroundColor = Color(0xFFF1F5F9);
  static const _cardRadius = 16.0;
  static const _sidebarWidth = 320.0;

  @override
  void initState() {
    super.initState();
    pelanggaranFuture = ApiService.getPelanggaran();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showRekapAnggotaDialog() {
    showDialog(
      context: context,
      builder: (context) => const RekapAnggotaDialog(),
    );
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (context) => InputPelanggaranDialog(
        onSaved: () {
          _showSuccessSnackBar('Pelanggaran berhasil dicatat');
          setState(() => pelanggaranFuture = ApiService.getPelanggaran());
        },
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetFilter() => setState(() => selectedDateRange = null);

  void _onDateRangeChanged(DateTimeRange? dateRange) {
    setState(() => selectedDateRange = dateRange);
  }

  void _onFilterChanged(String filter) {
    setState(() => activeFilter = filter);
    _pageController.animateToPage(
      filter == 'Semua' ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => activeFilter = index == 0 ? 'Semua' : 'Rekap');
  }

  List<Map<String, dynamic>> _filterByDateRange(List<Map<String, dynamic>> data) {
    if (selectedDateRange == null) return _filterHariIni(data);

    return data.where((item) {
      try {
        final tanggalString = (item['tanggal'] ?? '').toString();
        if (tanggalString.isEmpty) return false;

        final tanggal = DateTime.parse(tanggalString.split(' ')[0]);
        final start = DateTime(
          selectedDateRange!.start.year,
          selectedDateRange!.start.month,
          selectedDateRange!.start.day,
        );
        final end = DateTime(
          selectedDateRange!.end.year,
          selectedDateRange!.end.month,
          selectedDateRange!.end.day,
          23, 59, 59,
        );

        return tanggal.isAfter(start.subtract(const Duration(seconds: 1))) &&
            tanggal.isBefore(end.add(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  List<Map<String, dynamic>> _filterHariIni(List<Map<String, dynamic>> data) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return data.where((item) => 
      (item['tanggal'] ?? '').toString().startsWith(today)
    ).toList();
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

  int _getPelanggaranBulanIni(List<Map<String, dynamic>> data) {
    final thisMonth = DateFormat('yyyy-MM').format(DateTime.now());
    return data.where((item) => 
      (item['tanggal']?.toString() ?? '').startsWith(thisMonth)
    ).length;
  }

  int _getPelanggaranMingguIni(List<Map<String, dynamic>> data) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return data.where((item) {
      try {
        final tanggal = DateTime.parse(
          item['tanggal']?.toString().split(' ')[0] ?? ''
        );
        return tanggal.isAfter(startOfWeek.subtract(const Duration(seconds: 1)));
      } catch (e) {
        return false;
      }
    }).length;
  }

  Map<String, dynamic> _getSeverityConfig(int totalPelanggaran) {
    if (totalPelanggaran >= 50) {
      return {
        'color': const Color(0xFFEF4444),
        'bgColor': const Color(0xFFFEE2E2),
        'label': 'Kritis',
        'icon': Icons.error_rounded,
      };
    } else if (totalPelanggaran >= 30) {
      return {
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
        'label': 'Tinggi',
        'icon': Icons.warning_rounded,
      };
    }
    return {
      'color': const Color(0xFF10B981),
      'bgColor': const Color(0xFFD1FAE5),
      'label': 'Normal',
      'icon': Icons.check_circle_rounded,
    };
  }

  Map<String, Map<String, int>> _groupByKelas(List<Map<String, dynamic>> data) {
    final Map<String, Map<String, int>> rekapKelas = {};
    
    for (var item in data) {
      final kelas = item['kelas'] ?? 'Tidak diketahui';
      final poin = (item['poin'] as num?)?.toInt() ?? 0;
      
      if (!rekapKelas.containsKey(kelas)) {
        rekapKelas[kelas] = {'total_siswa': 1, 'total_pelanggaran': poin};
      } else {
        rekapKelas[kelas]!['total_siswa'] = rekapKelas[kelas]!['total_siswa']! + 1;
        rekapKelas[kelas]!['total_pelanggaran'] = 
            (rekapKelas[kelas]!['total_pelanggaran']! + poin).toInt();
      }
    }
    
    return rekapKelas;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Row(
        children: [
          _buildModernSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildModernAppBar(),
                _buildModernTabs(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    children: [
                      _buildDesktopSemuaPage(),
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

  Widget _buildModernAppBar() {
    return Container(
      height: 80,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: _primaryColor,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekap Pelanggaran',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Monitoring & Analisis',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Row(
        children: [
          _buildTabButton('Semua', Icons.list_alt_rounded),
          const SizedBox(width: 8),
          _buildTabButton('Rekap', Icons.analytics_rounded),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon) {
    final isActive = activeFilter == label;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onFilterChanged(label),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [_primaryColor, _secondaryColor],
                      )
                    : null,
                color: isActive ? null : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isActive ? Colors.white : Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernSidebar() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            width: _sidebarWidth,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data ?? [];
        final filteredData = _filterByDateRange(data);

        return Container(
          width: _sidebarWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCompactHeader(filteredData.length, data),
                const SizedBox(height: 16),
                _buildModernFilters(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompactHeader(int total, List<Map<String, dynamic>> allData) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryColor, _secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.description_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Pelanggaran',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  _getPelanggaranBulanIni(allData),
                  'Bulan Ini',
                  Icons.calendar_month,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStat(
                  _getPelanggaranMingguIni(allData),
                  'Minggu Ini',
                  Icons.today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(int value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FILTER',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildDateSelector(),
          const SizedBox(height: 20),
          Text(
            'AKSI CEPAT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey[600],
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickAction(
            icon: Icons.add_circle_outline,
            label: 'Tambah Kasus',
            color: const Color(0xFF10B981),
            onTap: _showInputDialog,
          ),
          const SizedBox(height: 8),
          _buildQuickAction(
            icon: Icons.groups_rounded,
            label: 'Lihat Rekap',
            color: _accentColor,
            onTap: _showRekapAnggotaDialog,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
              initialDateRange: selectedDateRange,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(primary: _primaryColor),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) _onDateRangeChanged(picked);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.date_range, size: 20, color: _primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedDateRange != null
                            ? '${DateFormat('dd MMM').format(selectedDateRange!.start)} - ${DateFormat('dd MMM yy').format(selectedDateRange!.end)}'
                            : 'Hari Ini',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _resetFilter,
                    color: Colors.grey[600],
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopSemuaPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Belum ada data');
        }

        final filteredData = _filterByDateRange(snapshot.data!);

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Semua Pelanggaran',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredData.length} Kasus',
                        style: const TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredData.isEmpty
                      ? _buildEmptyState('Tidak ada data pada periode ini')
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.5,
                          ),
                          itemCount: filteredData.length,
                          itemBuilder: (context, index) => 
                              _buildModernPelanggaranCard(filteredData[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernPelanggaranCard(Map<String, dynamic> item) {
    final poin = item['poin']?.toInt() ?? 0;
    final severity = _getSeverityConfig(poin);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (severity['color'] as Color).withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (severity['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          severity['icon'] as IconData,
                          color: severity['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'] ?? '-',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item['kelas'] ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['jenis_pelanggaran'] ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            item['waktu'] ?? '-',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: severity['bgColor'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '$poin',
                              style: TextStyle(
                                color: severity['color'],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'poin',
                              style: TextStyle(
                                color: severity['color'],
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
  }

  Widget _buildDesktopRekapPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Belum ada data');
        }

        final filteredData = _filterByDateRange(snapshot.data!);
        final rekapKelas = _groupByKelas(filteredData);

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Rekap per Kelas',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showRekapAnggotaDialog,
                      icon: const Icon(Icons.groups, size: 18),
                      label: const Text('Detail Lengkap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: rekapKelas.isEmpty
                      ? _buildEmptyState('Tidak ada data pada periode ini')
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: rekapKelas.length,
                          itemBuilder: (context, index) {
                            final entry = rekapKelas.entries.elementAt(index);
                            return _buildModernRekapCard(
                              kelas: entry.key,
                              data: entry.value,
                              onTap: () => _navigateToDetailKelas(entry.key, filteredData),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernRekapCard({
    required String kelas,
    required Map<String, int> data,
    required VoidCallback onTap,
  }) {
    final severity = _getSeverityConfig(data['total_pelanggaran']!);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryColor, _secondaryColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kelas,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${data['total_siswa']} siswa',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Poin',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data['total_pelanggaran']}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: severity['color'],
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: severity['bgColor'],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (severity['color'] as Color).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            severity['icon'] as IconData,
                            size: 14,
                            color: severity['color'] as Color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            severity['label'] as String,
                            style: TextStyle(
                              color: severity['color'],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Rekap Pelanggaran',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // Show filter bottom sheet
            },
          ),
        ],
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
                _buildMobileSemuaPage(),
                _buildMobileRekapPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showInputDialog,
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildMobileSemuaPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Belum ada data');
        }

        final filteredData = _filterByDateRange(snapshot.data!);

        return Column(
          children: [
            HeaderSummary(
              totalPelanggaran: filteredData.length,
              pelanggaranBulanIni: _getPelanggaranBulanIni(snapshot.data!),
              pelanggaranMingguIni: _getPelanggaranMingguIni(snapshot.data!),
            ),
            FilterSection(
              selectedDateRange: selectedDateRange,
              onRekapPressed: _showRekapAnggotaDialog,
              onInputPressed: _showInputDialog,
              onResetFilter: _resetFilter,
              onDateRangeChanged: _onDateRangeChanged,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredData.isEmpty
                  ? _buildEmptyState('Tidak ada data pada periode ini')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) => 
                          _buildMobilePelanggaranCard(filteredData[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobilePelanggaranCard(Map<String, dynamic> item) {
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
  }

  Widget _buildMobileRekapPage() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: pelanggaranFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('Belum ada data');
        }

        final filteredData = _filterByDateRange(snapshot.data!);
        final rekapKelas = _groupByKelas(filteredData);

        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_primaryColor, _secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.analytics, color: Colors.white, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Rekap per Kelas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showRekapAnggotaDialog,
                      icon: const Icon(Icons.groups, size: 18),
                      label: const Text('Lihat Detail Lengkap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            rekapKelas.isEmpty
                ? SliverFillRemaining(
                    child: _buildEmptyState('Tidak ada data pada periode ini'),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = rekapKelas.entries.elementAt(index);
                          return _buildMobileRekapCard(
                            kelas: entry.key,
                            data: entry.value,
                            onTap: () => _navigateToDetailKelas(entry.key, filteredData),
                          );
                        },
                        childCount: rekapKelas.length,
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildMobileRekapCard({
    required String kelas,
    required Map<String, int> data,
    required VoidCallback onTap,
  }) {
    final severity = _getSeverityConfig(data['total_pelanggaran']!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_primaryColor, _secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${data['total_siswa']} siswa',
                            style: TextStyle(
                              fontSize: 12,
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
                    Text(
                      '${data['total_pelanggaran']}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: severity['color'],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: severity['bgColor'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        severity['label'] as String,
                        style: TextStyle(
                          color: severity['color'],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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

  // ==================== SHARED WIDGETS ====================
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          ),
          const SizedBox(height: 20),
          Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}