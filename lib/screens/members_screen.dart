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
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
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
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
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
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.Text(
                    'Halaman 1',
                    style: const pw.TextStyle(
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
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Catatan: Data ini menampilkan total pembayaran kas yang telah terkumpul dari masing-masing anggota.',
                        style: const pw.TextStyle(
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
      Navigator.pop(context);

      // Show preview and print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
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
    return Scaffold(
      backgroundColor: Colors.blue[600],
      appBar: AppBar(
        title: const Text(
          'Daftar Anggota',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Tombol Export PDF
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: 'Export Rekap Kas',
            onPressed: _generateRekapKasPDF,
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddMemberPage()),
              ).then((result) {
                if (result == true && mounted) _reloadMembers();
              });
            },
          ),
        ],
      ),
      body: Column(
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
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
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
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          // List member dengan FutureBuilder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _membersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      'Gagal mengambil data: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada anggota'));
                  }

                  // Filter dan sort members
                  final filteredMembers = _filterAndSortMembers(snapshot.data!);

                  // Tampilkan pesan jika tidak ada hasil pencarian
                  if (filteredMembers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada anggota dengan nama "$_searchQuery"',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredMembers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                        child: MemberItemWidget(
                          name: member['name'] ?? 'Tidak Diketahui',
                          status: status,
                          amount: 'Rp $totalPaid',
                          avatar: (member['name'] != null &&
                                  member['name'].isNotEmpty)
                              ? member['name'][0].toUpperCase()
                              : '?',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}