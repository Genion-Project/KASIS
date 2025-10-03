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
      Navigator.pop(context);

      // Show preview and print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);
      
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
    // Grouping data by student name
    final Map<String, List<Map<String, dynamic>>> groupedByStudent = {};
    
    for (var item in dataSiswa) {
      final nama = item['nama'] ?? 'Tidak diketahui';
      if (!groupedByStudent.containsKey(nama)) {               
        groupedByStudent[nama] = [];
      }
      groupedByStudent[nama]!.add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
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
          // Tombol Export PDF
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
      body: Column(
        children: [
          // Header Summary
          Container(
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total Siswa',
                      groupedByStudent.length.toString(),
                      Icons.people_alt_rounded,
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildStatCard(
                      'Total Pelanggaran',
                      dataSiswa.length.toString(),
                      Icons.warning_amber_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tombol Export PDF (alternatif di body)
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

          // List of Students
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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

                return _buildStudentCard(
                  context,
                  nama: nama,
                  totalPelanggaran: pelanggaranSiswa.length,
                  totalPoin: totalPoin,
                  pelanggaranList: pelanggaranSiswa,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
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

  Widget _buildStudentCard(
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
          splashColor: Colors.blue.withOpacity(0.05),
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
                  return _buildPelanggaranItem(
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

  Widget _buildPelanggaranItem({
    required String jenis,
    required int poin,
    required String tanggal,
    required String waktu,
    required String keterangan,
  }) {
    // Default value
    String displayTanggal = tanggal;
    String displayWaktu = waktu;

    try {
      // Kalau waktu kosong, cek apakah tanggal berisi timestamp
      if (waktu == '-' || waktu.isEmpty) {
        final parsed = DateTime.tryParse(tanggal);
        if (parsed != null) {
          displayTanggal = DateFormat('dd MMM yyyy').format(parsed);
          displayWaktu = DateFormat('HH:mm').format(parsed);
        }
      }
    } catch (_) {
      // biarkan default kalau parsing gagal
    }

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