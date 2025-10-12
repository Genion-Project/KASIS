import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../pages/member_detail_page.dart';
import '../widgets/stat_header_widget.dart';
import '../widgets/member_item_widget.dart';
import 'package:bendahara_app/pages/AddMemberPage.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late Future<List<Map<String, dynamic>>> _membersFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _membersFuture = ApiService.getMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  // Method untuk reload data members
  void _reloadMembers() {
    if (!mounted) return;
    setState(() {
      _membersFuture = ApiService.getMembers();
    });
  }

  // Method untuk filter dan sort members
  List<Map<String, dynamic>> _filterAndSortMembers(List<Map<String, dynamic>> members) {
    // Filter berdasarkan search query
    List<Map<String, dynamic>> filtered = members;
    
    if (_searchQuery.isNotEmpty) {
      filtered = members.where((member) {
        final name = (member['name'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort A-Z berdasarkan nama
    filtered.sort((a, b) {
      final nameA = (a['name'] ?? '').toString().toLowerCase();
      final nameB = (b['name'] ?? '').toString().toLowerCase();
      return nameA.compareTo(nameB);
    });

    return filtered;
  }

  // Method untuk generate PDF Rekap Kas
  Future<void> _generateRekapKasPDF() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.blue[700]),
                const SizedBox(height: 16),
                Text(
                  'Membuat PDF...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Ambil data members
      final members = await _membersFuture;
      
      // Sort members A-Z untuk PDF
      final sortedMembers = List<Map<String, dynamic>>.from(members);
      sortedMembers.sort((a, b) {
        final nameA = (a['name'] ?? '').toString().toLowerCase();
        final nameB = (b['name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });

      // Hitung statistik
      int totalAnggota = sortedMembers.length;
      int sudahBayar = sortedMembers.where((m) => (m['amount'] ?? 0) > 0).length;
      int belumBayar = totalAnggota - sudahBayar;
      int totalKas = sortedMembers.fold<int>(0, (sum, m) {
        final amount = m['amount'];
        final amountInt = (amount is int) ? amount : (amount is double ? amount.toInt() : 0);
        return sum + amountInt;
      });

      final pdf = pw.Document();

      // Create PDF content
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  gradient: const pw.LinearGradient(
                    colors: [PdfColors.blue700, PdfColors.blue900],
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REKAP KAS ANGGOTA',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Tanggal Export: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Summary Statistik
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.blue200, width: 2),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildPdfStatItem(
                      'Total Anggota',
                      totalAnggota.toString(),
                      PdfColors.blue900,
                    ),
                    pw.Container(
                      width: 1,
                      height: 50,
                      color: PdfColors.blue200,
                    ),
                    _buildPdfStatItem(
                      'Sudah Bayar',
                      sudahBayar.toString(),
                      PdfColors.green700,
                    ),
                    pw.Container(
                      width: 1,
                      height: 50,
                      color: PdfColors.blue200,
                    ),
                    _buildPdfStatItem(
                      'Belum Bayar',
                      belumBayar.toString(),
                      PdfColors.red700,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Total Kas
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  gradient: const pw.LinearGradient(
                    colors: [PdfColors.green600, PdfColors.green800],
                  ),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'TOTAL KAS TERKUMPUL',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Rp ${NumberFormat('#,###', 'id_ID').format(totalKas)}',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Judul Tabel
              pw.Text(
                'Daftar Anggota dan Pembayaran (A-Z)',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Tabel Anggota
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue700,
                    ),
                    children: [
                      _buildTableHeader('No'),
                      _buildTableHeader('Nama Anggota'),
                      _buildTableHeader('Jumlah Bayar'),
                      _buildTableHeader('Status'),
                    ],
                  ),
                  // Data
                  ...sortedMembers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;
                    final int totalPaid = member['amount'] ?? 0;
                    final status = totalPaid > 0 ? 'Sudah Bayar' : 'Belum Bayar';
                    final statusColor = totalPaid > 0 ? PdfColors.green700 : PdfColors.red700;

                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                      ),
                      children: [
                        _buildTableCell((index + 1).toString()),
                        _buildTableCell(member['name'] ?? 'Tidak Diketahui', align: pw.TextAlign.left),
                        _buildTableCell('Rp ${NumberFormat('#,###', 'id_ID').format(totalPaid)}', align: pw.TextAlign.right),
                        _buildTableCellColored(status, statusColor),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 24),

              // Footer
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Dicetak oleh: Sistem Bendahara',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Halaman 1',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),

              // Catatan
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber50,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.amber300),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '⚠️ ',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Catatan: Data ini menampilkan total pembayaran kas yang telah terkumpul dari masing-masing anggota.',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show preview and print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      // Close loading dialog if still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]),
                const SizedBox(width: 12),
                const Text('Error'),
              ],
            ),
            content: Text('Gagal membuat PDF: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  pw.Widget _buildPdfStatItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 11,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {pw.TextAlign align = pw.TextAlign.center}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 10,
        ),
        textAlign: align,
      ),
    );
  }

  pw.Widget _buildTableCellColored(String text, PdfColor color) {
    PdfColor bgColor;
    if (color == PdfColors.green700) {
      bgColor = PdfColors.green50;
    } else {
      bgColor = PdfColors.red50;
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: pw.BoxDecoration(
          color: bgColor,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = _isDesktop(context);
    final isTablet = _isTablet(context);

    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey[100] : Colors.blue[600],
      appBar: isDesktop ? null : _buildMobileAppBar(),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(isTablet),
    );
  }

  // Mobile AppBar
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: const Text(
        'Daftar Anggota',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.blue[600],
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: [
        // Tombol Export PDF
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: 'Export Rekap Kas',
            onPressed: _generateRekapKasPDF,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            tooltip: 'Tambah Anggota',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddMemberPage()),
              ).then((result) {
                if (result == true && mounted) _reloadMembers();
              });
            },
          ),
        ),
      ],
    );
  }

  // Desktop Layout
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar Header dengan Stats
        Container(
          width: 320,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon & Title
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.people_rounded,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Anggota',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'Management',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Kelola data dan pembayaran kas anggota OSIS dengan mudah',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Statistics Widget
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: StatHeaderWidget(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Text(
                    'AKSI CEPAT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tambah Anggota Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddMemberPage()),
                      ).then((result) {
                        if (result == true && mounted) _reloadMembers();
                      });
                    },
                    icon: const Icon(Icons.person_add_rounded, size: 20),
                    label: const Text(
                      'Tambah Anggota',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Export PDF Button
                  OutlinedButton.icon(
                    onPressed: _generateRekapKasPDF,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                    label: const Text(
                      'Export PDF',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.5), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 52),
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white.withOpacity(0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Klik pada kartu anggota untuk melihat detail dan riwayat pembayaran',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.4,
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
        ),

        // Main Content Area
        Expanded(
          child: Container(
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search Bar Header
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          style: TextStyle(color: Colors.grey[800], fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Cari anggota berdasarkan nama...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: Container(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                Icons.search_rounded, 
                                color: Colors.blue[700],
                                size: 22,
                              ),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear_rounded, color: Colors.grey[600]),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.grey[200]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _membersFuture,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox.shrink();
                            final filtered = _filterAndSortMembers(snapshot.data!);
                            return Row(
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  color: Colors.blue[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${filtered.length} Anggota',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Area dengan Grid
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _membersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Colors.blue[700],
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Memuat data anggota...',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.all(32),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline_rounded, 
                                  size: 64, 
                                  color: Colors.red[400]
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal Memuat Data',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${snapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.all(32),
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people_outline_rounded, 
                                  size: 80, 
                                  color: Colors.grey[300]
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Belum Ada Anggota',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tambahkan anggota pertama Anda untuk memulai',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AddMemberPage()),
                                    ).then((result) {
                                      if (result == true && mounted) _reloadMembers();
                                    });
                                  },
                                  icon: const Icon(Icons.person_add_rounded),
                                  label: const Text('Tambah Anggota'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final filteredMembers = _filterAndSortMembers(snapshot.data!);

                      if (filteredMembers.isEmpty) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.all(32),
                            padding: const EdgeInsets.all(48),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded, 
                                  size: 64, 
                                  color: Colors.grey[400]
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak Ditemukan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tidak ada anggota dengan nama "$_searchQuery"',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Grid dengan 2 kolom untuk lebih lega
                      return GridView.builder(
                        padding: const EdgeInsets.all(28),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 3.5,
                        ),
                        itemCount: filteredMembers.length,
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          final int totalPaid = member['amount'] ?? 0;
                          final status = totalPaid > 0 ? 'Sudah Bayar' : 'Belum Bayar';

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MemberDetailPage(
                                    memberId: member['id'],
                                    memberName: member['name'],
                                  ),
                                ),
                              ).then((_) => _reloadMembers());
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: totalPaid > 0 
                                    ? Colors.green[200]! 
                                    : Colors.grey[200]!,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: totalPaid > 0
                                          ? [Colors.green[400]!, Colors.green[600]!]
                                          : [Colors.grey[300]!, Colors.grey[500]!],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (totalPaid > 0 
                                            ? Colors.green 
                                            : Colors.grey).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        (member['name'] != null && member['name'].isNotEmpty)
                                          ? member['name'][0].toUpperCase()
                                          : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          member['name'] ?? 'Tidak Diketahui',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[900],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 5,
                                              ),
                                              decoration: BoxDecoration(
                                                color: totalPaid > 0 
                                                  ? Colors.green[50] 
                                                  : Colors.red[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: totalPaid > 0 
                                                    ? Colors.green[700] 
                                                    : Colors.red[700],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Rp ${NumberFormat('#,###', 'id_ID').format(totalPaid)}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: totalPaid > 0 
                                                  ? Colors.green[600] 
                                                  : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.grey[400],
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Mobile Layout
  Widget _buildMobileLayout(bool isTablet) {
    return Column(
      children: [
        // Header statistik
        StatHeaderWidget(),

        // Search Bar
        Container(
          color: Colors.blue[600],
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari anggota...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: 14
              ),
            ),
          ),
        ),

        // List member dengan FutureBuilder
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _membersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.blue[700],
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat data...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Colors.red[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal Memuat Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people_outline_rounded,
                              size: 56,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Belum Ada Anggota',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan anggota pertama Anda',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Filter dan sort members
                final filteredMembers = _filterAndSortMembers(snapshot.data!);

                // Tampilkan pesan jika tidak ada hasil pencarian
                if (filteredMembers.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded, 
                            size: 64, 
                            color: Colors.grey[400]
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak Ditemukan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada anggota dengan nama\n"$_searchQuery"',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(isTablet ? 24 : 20),
                  itemCount: filteredMembers.length,
                  separatorBuilder: (_, __) => SizedBox(height: isTablet ? 16 : 12),
                  itemBuilder: (context, index) {
                    final member = filteredMembers[index];
                    final int totalPaid = member['amount'] ?? 0;
                    final status = totalPaid > 0 ? 'Sudah Bayar' : 'Belum Bayar';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberDetailPage(
                              memberId: member['id'],
                              memberName: member['name'],
                            ),
                          ),
                        ).then((_) => _reloadMembers());
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: totalPaid > 0 
                              ? Colors.green[100]! 
                              : Colors.grey[200]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: isTablet ? 56 : 50,
                              height: isTablet ? 56 : 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: totalPaid > 0
                                    ? [Colors.green[400]!, Colors.green[600]!]
                                    : [Colors.grey[300]!, Colors.grey[500]!],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: (totalPaid > 0 
                                      ? Colors.green 
                                      : Colors.grey).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  (member['name'] != null && member['name'].isNotEmpty)
                                    ? member['name'][0].toUpperCase()
                                    : '?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 22 : 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member['name'] ?? 'Tidak Diketahui',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[900],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: totalPaid > 0 
                                            ? Colors.green[50] 
                                            : Colors.red[50],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: totalPaid > 0 
                                              ? Colors.green[700] 
                                              : Colors.red[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Rp ${NumberFormat('#,###', 'id_ID').format(totalPaid)}',
                                        style: TextStyle(
                                          fontSize: isTablet ? 14 : 13,
                                          fontWeight: FontWeight.bold,
                                          color: totalPaid > 0 
                                            ? Colors.green[600] 
                                            : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.grey[400],
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}