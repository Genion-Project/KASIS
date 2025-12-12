// PENTING: Simpan file ini sebagai: lib/pages/detail_kelas_page.dart
// (di folder yang sama dengan riwayat_page.dart)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DetailKelasPage extends StatelessWidget {
  final String namaKelas;
  final List<Map<String, dynamic>> dataSiswa;

  const DetailKelasPage({
    super.key,
    required this.namaKelas,
    required this.dataSiswa,
  });

  // Function to generate PDF
  Future<void> _generatePDF(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Grouping data by student name
      final Map<String, List<Map<String, dynamic>>> groupedByStudent = {};
      
      for (var item in dataSiswa) {
        final nama = item['nama'] ?? 'Tidak diketahui';
        if (!groupedByStudent.containsKey(nama)) {               
          groupedByStudent[nama] = [];
        }
        groupedByStudent[nama]!.add(item);
      }

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
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REKAP PELANGGARAN SISWA',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Kelas: $namaKelas',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                      ),
                    ),
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
              pw.SizedBox(height: 16),

              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStatCard(
                    'Total Siswa',
                    groupedByStudent.length.toString(),
                  ),
                  _buildPdfStatCard(
                    'Total Pelanggaran',
                    dataSiswa.length.toString(),
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Student List
              pw.Text(
                'Daftar Siswa dan Pelanggaran',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _buildTableCell('No', isHeader: true),
                      _buildTableCell('Nama Siswa', isHeader: true),
                      _buildTableCell('Jml\nPelanggaran', isHeader: true),
                      _buildTableCell('Total\nPoin', isHeader: true),
                      _buildTableCell('Status', isHeader: true),
                    ],
                  ),
                  // Data
                  ...groupedByStudent.entries.map((entry) {
                    final index = groupedByStudent.keys.toList().indexOf(entry.key);
                    final nama = entry.key;
                    final pelanggaranSiswa = entry.value;
                    final totalPoin = pelanggaranSiswa.fold<int>(
                      0,
                      (sum, item) {
                        final poin = item['poin'];
                        final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
                        return (sum + poinInt).toInt();
                      },
                    );

                    String severity;
                    if (totalPoin >= 50) {
                      severity = 'Kritis';
                    } else if (totalPoin >= 30) {
                      severity = 'Tinggi';
                    } else if (totalPoin >= 15) {
                      severity = 'Sedang';
                    } else {
                      severity = 'Rendah';
                    }

                    return pw.TableRow(
                      children: [
                        _buildTableCell((index + 1).toString()),
                        _buildTableCell(nama),
                        _buildTableCell(pelanggaranSiswa.length.toString()),
                        _buildTableCell(totalPoin.toString()),
                        _buildTableCell(severity),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 24),

              // Detail per siswa
              pw.Text(
                'Detail Pelanggaran per Siswa',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),

              ...groupedByStudent.entries.map((entry) {
                final nama = entry.key;
                final pelanggaranSiswa = entry.value;
                final totalPoin = pelanggaranSiswa.fold<int>(
                  0,
                  (sum, item) {
                    final poin = item['poin'];
                    final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
                    return (sum + poinInt).toInt();
                  },
                );

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue50,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            nama,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Total Poin: $totalPoin',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    ...pelanggaranSiswa.map((pelanggaran) {
                      String tanggal = pelanggaran['tanggal'] ?? '-';
                      String waktu = pelanggaran['waktu'] ?? '-';
                      
                      try {
                        if (waktu == '-' || waktu.isEmpty) {
                          final parsed = DateTime.tryParse(tanggal);
                          if (parsed != null) {
                            tanggal = DateFormat('dd MMM yyyy').format(parsed);
                            waktu = DateFormat('HH:mm').format(parsed);
                          }
                        }
                      } catch (_) {}

                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    pelanggaran['jenis_pelanggaran'] ?? '-',
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Text(
                                  '${pelanggaran['poin']?.toInt() ?? 0} poin',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.red700,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Tanggal: $tanggal | Waktu: $waktu',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                            if (pelanggaran['keterangan'] != null && 
                                pelanggaran['keterangan'] != '-') ...[
                              pw.SizedBox(height: 4),
                              pw.Text(
                                'Keterangan: ${pelanggaran['keterangan']}',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.grey600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                    pw.SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ];
          },
        ),
      );

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

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

  pw.Widget _buildPdfStatCard(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.blue200, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    if (isDesktop) {
      return _buildDesktopLayoutWithSidebar(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayoutWithSidebar(BuildContext context) {
    // Grouping data by student name
    final Map<String, List<Map<String, dynamic>>> groupedByStudent = {};
    final Map<String, int> severityCount = {'Rendah': 0, 'Sedang': 0, 'Tinggi': 0, 'Kritis': 0};
    int totalPoinKelas = 0;
    
    for (var item in dataSiswa) {
      final nama = item['nama'] ?? 'Tidak diketahui';
      if (!groupedByStudent.containsKey(nama)) {               
        groupedByStudent[nama] = [];
      }
      groupedByStudent[nama]!.add(item);
      
      // Calculate total points for class
      final poin = item['poin'];
      final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
      totalPoinKelas += poinInt;
    }

    // Calculate severity distribution
    for (var entry in groupedByStudent.entries) {
      final totalPoinSiswa = entry.value.fold<int>(0, (sum, item) {
        final poin = item['poin'];
        final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
        return sum + poinInt;
      });

      if (totalPoinSiswa >= 50) {
        severityCount['Kritis'] = severityCount['Kritis']! + 1;
      } else if (totalPoinSiswa >= 30) {
        severityCount['Tinggi'] = severityCount['Tinggi']! + 1;
      } else if (totalPoinSiswa >= 15) {
        severityCount['Sedang'] = severityCount['Sedang']! + 1;
      } else {
        severityCount['Rendah'] = severityCount['Rendah']! + 1;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Sidebar
          _buildDesktopSidebar(
            context,
            groupedByStudent: groupedByStudent,
            totalPoinKelas: totalPoinKelas,
            severityCount: severityCount,
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Detail Kelas $namaKelas',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 16),
                          // Export Button
                          ElevatedButton.icon(
                            onPressed: () => _generatePDF(context),
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                            label: const Text('Export PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Stats
                        _buildQuickStats(groupedByStudent),
                        const SizedBox(height: 24),
                        
                        // Student Grid
                        Expanded(
                          child: _buildStudentGrid(context, groupedByStudent),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(
    BuildContext context, {
    required Map<String, List<Map<String, dynamic>>> groupedByStudent,
    required int totalPoinKelas,
    required Map<String, int> severityCount,
  }) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    namaKelas,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${groupedByStudent.length} Siswa',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Class Summary
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan Kelas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Total Points
                  _buildSidebarStatItem(
                    icon: Icons.assessment_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    label: 'Total Poin Kelas',
                    value: '$totalPoinKelas',
                  ),
                  const SizedBox(height: 12),
                  
                  // Average Points
                  _buildSidebarStatItem(
                    icon: Icons.timeline_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'Rata-rata Poin/Siswa',
                    value: groupedByStudent.isEmpty ? '0' : '${(totalPoinKelas / groupedByStudent.length).toStringAsFixed(1)}',
                  ),
                  const SizedBox(height: 20),

                  // Severity Distribution
                  const Text(
                    'Distribusi Tingkat Pelanggaran',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSeverityBar(
                    label: 'Kritis',
                    count: severityCount['Kritis']!,
                    total: groupedByStudent.length,
                    color: const Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildSeverityBar(
                    label: 'Tinggi',
                    count: severityCount['Tinggi']!,
                    total: groupedByStudent.length,
                    color: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildSeverityBar(
                    label: 'Sedang',
                    count: severityCount['Sedang']!,
                    total: groupedByStudent.length,
                    color: const Color(0xFFEAB308),
                  ),
                  const SizedBox(height: 8),
                  
                  _buildSeverityBar(
                    label: 'Rendah',
                    count: severityCount['Rendah']!,
                    total: groupedByStudent.length,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _generatePDF(context),
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: const Text('Export Laporan PDF'),
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Kembali ke Rekap'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final percentage = total == 0 ? 0.0 : (count / total * 100);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$count siswa (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Expanded(
                flex: count,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Expanded(
                flex: total - count,
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, List<Map<String, dynamic>>> groupedByStudent) {
    return Row(
      children: [
        _buildQuickStatCard(
          icon: Icons.people_alt_rounded,
          iconColor: const Color(0xFF3B82F6),
          value: groupedByStudent.length.toString(),
          label: 'Total Siswa',
        ),
        const SizedBox(width: 16),
        _buildQuickStatCard(
          icon: Icons.warning_amber_rounded,
          iconColor: const Color(0xFFF59E0B),
          value: dataSiswa.length.toString(),
          label: 'Total Pelanggaran',
        ),
        const SizedBox(width: 16),
        _buildQuickStatCard(
          icon: Icons.assessment_rounded,
          iconColor: const Color(0xFF10B981),
          value: _calculateAveragePoints(groupedByStudent),
          label: 'Rata-rata Poin',
        ),
      ],
    );
  }

  String _calculateAveragePoints(Map<String, List<Map<String, dynamic>>> groupedByStudent) {
    if (groupedByStudent.isEmpty) return '0.0';
    
    int totalPoints = 0;
    for (var entry in groupedByStudent.entries) {
      totalPoints += entry.value.fold<int>(0, (sum, item) {
        final poin = item['poin'];
        final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
        return sum + poinInt;
      });
    }
    
    return (totalPoints / groupedByStudent.length).toStringAsFixed(1);
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGrid(BuildContext context, Map<String, List<Map<String, dynamic>>> groupedByStudent) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: groupedByStudent.length,
      itemBuilder: (context, index) {
        final nama = groupedByStudent.keys.elementAt(index);
        final pelanggaranSiswa = groupedByStudent[nama]!;
        final totalPoin = pelanggaranSiswa.fold<int>(
          0,
          (sum, item) {
            final poin = item['poin'];
            final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
            return (sum + poinInt).toInt();
          },
        );

        return _buildDesktopStudentCard(
          context,
          nama: nama,
          totalPelanggaran: pelanggaranSiswa.length,
          totalPoin: totalPoin,
          pelanggaranList: pelanggaranSiswa,
        );
      },
    );
  }

  Widget _buildDesktopStudentCard(
    BuildContext context, {
    required String nama,
    required int totalPelanggaran,
    required int totalPoin,
    required List<Map<String, dynamic>> pelanggaranList,
  }) {
    Color poinColor;
    Color poinBgColor;
    String severity;

    if (totalPoin >= 50) {
      poinColor = const Color(0xFFDC2626);
      poinBgColor = const Color(0xFFFEE2E2);
      severity = 'Kritis';
    } else if (totalPoin >= 30) {
      poinColor = const Color(0xFFF59E0B);
      poinBgColor = const Color(0xFFFEF3C7);
      severity = 'Tinggi';
    } else if (totalPoin >= 15) {
      poinColor = const Color(0xFFEAB308);
      poinBgColor = const Color(0xFFFEF9C3);
      severity = 'Sedang';
    } else {
      poinColor = const Color(0xFF10B981);
      poinBgColor = const Color(0xFFD1FAE5);
      severity = 'Rendah';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _showDesktopStudentDetail(
            context,
            nama: nama,
            totalPoin: totalPoin,
            pelanggaranList: pelanggaranList,
            poinColor: poinColor,
            severity: severity,
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                      gradient: LinearGradient(
                        colors: [poinColor.withOpacity(0.8), poinColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(Icons.list_alt_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '$totalPelanggaran pelanggaran',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: poinBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$totalPoin poin',
                      style: TextStyle(
                        color: poinColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: poinColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      severity,
                      style: TextStyle(
                        color: poinColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Klik untuk lihat detail →',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDesktopStudentDetail(
    BuildContext context, {
    required String nama,
    required int totalPoin,
    required List<Map<String, dynamic>> pelanggaranList,
    required Color poinColor,
    required String severity,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(40),
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: poinColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$totalPoin poin - $severity',
                      style: TextStyle(
                        color: poinColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pelanggaranList.length} pelanggaran',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: pelanggaranList.length,
                    itemBuilder: (context, index) {
                      final pelanggaran = pelanggaranList[index];
                      return _buildDesktopPelanggaranItem(pelanggaran);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopPelanggaranItem(Map<String, dynamic> pelanggaran) {
    String displayTanggal = pelanggaran['tanggal'] ?? '-';
    String displayWaktu = pelanggaran['waktu'] ?? '-';

    try {
      if (displayWaktu == '-' || displayWaktu.isEmpty) {
        final parsed = DateTime.tryParse(displayTanggal);
        if (parsed != null) {
          displayTanggal = DateFormat('dd MMM yyyy').format(parsed);
          displayWaktu = DateFormat('HH:mm').format(parsed);
        }
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${pelanggaran['poin']?.toInt() ?? 0} poin',
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pelanggaran['jenis_pelanggaran'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      displayTanggal,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      displayWaktu,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
                if (pelanggaran['keterangan'] != null && pelanggaran['keterangan'] != '-') ...[
                  const SizedBox(height: 8),
                  Text(
                    'Keterangan: ${pelanggaran['keterangan']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    // Grouping data by student name
    final Map<String, List<Map<String, dynamic>>> groupedByStudent = {};
    
    for (var item in dataSiswa) {
      final nama = item['nama'] ?? 'Tidak diketahui';
      if (!groupedByStudent.containsKey(nama)) {               
        groupedByStudent[nama] = [];
      }
      groupedByStudent[nama]!.add(item);
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0, // Standard AppBar height
            pinned: true,
            title: Text(
              'Detail Kelas $namaKelas',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_rounded),
                tooltip: 'Export ke PDF',
                onPressed: () => _generatePDF(context),
              ),
              const SizedBox(width: 8),
            ],
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

          // Header Summary (Scrollable)
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: _buildMobileStatCard(
                          'Total Siswa',
                          groupedByStudent.length.toString(),
                          Icons.people_alt_rounded,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: _buildMobileStatCard(
                          'Total Pelanggaran',
                          dataSiswa.length.toString(),
                          Icons.warning_amber_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _generatePDF(context),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                    label: const Text(
                      'Export ke PDF',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: isTablet
                ? SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 400,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final nama = groupedByStudent.keys.elementAt(index);
                        final pelanggaranSiswa = groupedByStudent[nama]!;
                        final totalPoin = pelanggaranSiswa.fold<int>(
                          0,
                          (sum, item) {
                            final poin = item['poin'];
                            final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
                            return (sum + poinInt).toInt();
                          },
                        );

                        return _buildDesktopStudentCard(
                          context,
                          nama: nama,
                          totalPelanggaran: pelanggaranSiswa.length,
                          totalPoin: totalPoin,
                          pelanggaranList: pelanggaranSiswa,
                        );
                      },
                      childCount: groupedByStudent.length,
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final nama = groupedByStudent.keys.elementAt(index);
                        final pelanggaranSiswa = groupedByStudent[nama]!;
                        final totalPoin = pelanggaranSiswa.fold<int>(
                          0,
                          (sum, item) {
                            final poin = item['poin'];
                            final poinInt = (poin is int) ? poin : (poin is double ? poin.toInt() : 0);
                            return (sum + poinInt).toInt();
                          },
                        );

                        return _buildMobileStudentCard(
                          context,
                          nama: nama,
                          totalPelanggaran: pelanggaranSiswa.length,
                          totalPoin: totalPoin,
                          pelanggaranList: pelanggaranSiswa,
                        );
                      },
                      childCount: groupedByStudent.length,
                    ),
                  ),
          ),
          
          // Bottom Padding
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
    );
  }

  Widget _buildMobileStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileStudentCard(
    BuildContext context, {
    required String nama,
    required int totalPelanggaran,
    required int totalPoin,
    required List<Map<String, dynamic>> pelanggaranList,
  }) {
    Color poinColor;
    Color poinBgColor;
    String severity;

    if (totalPoin >= 50) {
      poinColor = const Color(0xFFDC2626);
      poinBgColor = const Color(0xFFFEE2E2);
      severity = 'Kritis';
    } else if (totalPoin >= 30) {
      poinColor = const Color(0xFFF59E0B);
      poinBgColor = const Color(0xFFFEF3C7);
      severity = 'Tinggi';
    } else if (totalPoin >= 15) {
      poinColor = const Color(0xFFEAB308);
      poinBgColor = const Color(0xFFFEF9C3);
      severity = 'Sedang';
    } else {
      poinColor = const Color(0xFF10B981);
      poinBgColor = const Color(0xFFD1FAE5);
      severity = 'Rendah';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [poinColor.withOpacity(0.8), poinColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: poinColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            nama,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(Icons.list_alt_rounded, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$totalPelanggaran pelanggaran',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          trailing: SizedBox(
            width: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: poinBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$totalPoin poin',
                    style: TextStyle(
                      color: poinColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: poinColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      color: poinColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: pelanggaranList.map((pelanggaran) {
                  return _buildMobilePelanggaranItem(
                    jenis: pelanggaran['jenis_pelanggaran'] ?? '-',
                    poin: pelanggaran['poin']?.toInt() ?? 0,
                    tanggal: pelanggaran['tanggal'] ?? '-',
                    waktu: pelanggaran['waktu'] ?? '-',
                    keterangan: pelanggaran['keterangan'] ?? '-',
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePelanggaranItem({
    required String jenis,
    required int poin,
    required String tanggal,
    required String waktu,
    required String keterangan,
  }) {
    String displayTanggal = tanggal;
    String displayWaktu = waktu;

    try {
      if (waktu == '-' || waktu.isEmpty) {
        final parsed = DateTime.tryParse(tanggal);
        if (parsed != null) {
          displayTanggal = DateFormat('dd MMM yyyy').format(parsed);
          displayWaktu = DateFormat('HH:mm').format(parsed);
        }
      }
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  jenis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$poin poin',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                displayTanggal,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                displayWaktu,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          if (keterangan != '-') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      keterangan,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}