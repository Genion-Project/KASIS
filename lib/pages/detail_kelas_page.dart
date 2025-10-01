// PENTING: Simpan file ini sebagai: lib/pages/detail_kelas_page.dart
// (di folder yang sama dengan riwayat_page.dart)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DetailKelasPage extends StatelessWidget {
  final String namaKelas;
  final List<Map<String, dynamic>> dataSiswa;

  const DetailKelasPage({
    super.key,
    required this.namaKelas,
    required this.dataSiswa,
  });

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
            displayTanggal = DateFormat('dd MMM yyyy').format(parsed); // contoh: 01 Okt 2025
            displayWaktu = DateFormat('HH:mm').format(parsed);         // contoh: 09:35
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