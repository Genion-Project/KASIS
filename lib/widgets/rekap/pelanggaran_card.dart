import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PelanggaranCard extends StatelessWidget {
  final int? id; // Tambahan untuk ID pelanggaran
  final String nama;
  final String kelas;
  final dynamic tanggal;
  final dynamic waktu;
  final String jenisPelanggaran;
  final int poin;
  final String keterangan;
  final IconData icon;
  final Color color;
  final VoidCallback? onDelete; // Tambahan untuk callback hapus

  const PelanggaranCard({
    super.key,
    this.id, // Optional
    required this.nama,
    required this.kelas,
    required this.tanggal,
    required this.waktu,
    required this.jenisPelanggaran,
    required this.poin,
    required this.keterangan,
    required this.icon,
    required this.color,
    this.onDelete, // Optional
  });

  @override
  Widget build(BuildContext context) {
    // Parsing Tanggal & Waktu logic
    String displayTanggal = '-';
    String displayWaktu = '-';

    try {
      DateTime? dt;
      
      // 1. Handle Tanggal (Primary source)
      if (tanggal is DateTime) {
        dt = tanggal;
      } else if (tanggal is String && tanggal.isNotEmpty && tanggal != '-') {
        dt = DateTime.tryParse(tanggal);
        // Jika gagal parse standard, coba manual split jika ada spasi/T (YYYY-MM-DD HH:mm:ss)
        if (dt == null && (tanggal.contains(' ') || tanggal.contains('T'))) {
          // Fallback parsing manual jika diperlukan bisa di sini
        }
      }

      if (dt != null) {
        displayTanggal = DateFormat('yyyy-MM-dd').format(dt);
        displayWaktu = DateFormat('HH:mm').format(dt);
      } else if (tanggal is String) {
        displayTanggal = tanggal;
      }

      // 2. Handle Waktu (Secondary source / Override)
      // JIKA displayWaktu masih '-' atau '00:00' (default midnight), 
      // dan ada input 'waktu' yang lebih spesifik, gunakan itu.
      if (waktu != null && waktu != '-' && waktu != '00:00' && waktu != '00:00:00') {
        if (waktu is DateTime) {
          displayWaktu = DateFormat('HH:mm').format(waktu);
        } else if (waktu is String) {
          if (waktu.contains(':')) {
            final parts = waktu.split(':');
            if (parts.length >= 2) {
              String h = parts[0].padLeft(2, '0');
              String m = parts[1].padLeft(2, '0');
              // Hanya gunakan jika bukan 00:00 atau jika kita belum punya waktu dari dt
              if (h != '00' || m != '00' || displayWaktu == '-') {
                displayWaktu = "$h:$m";
              }
            }
          }
        }
      }
    } catch (_) {
      displayTanggal = tanggal?.toString() ?? '-';
      displayWaktu = waktu?.toString() ?? '-';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon dengan gradient
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF), // Blue 50
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE), // Blue 200
                                  ),
                                ),
                                child: Text(
                                  kelas,
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB), // Blue 600
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626), // Red 600
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDC2626).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '-$poin Poin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ),
                            // ✅ TOMBOL HAPUS (hanya muncul jika onDelete tidak null)
                            if (onDelete != null) ...[
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () => _showDeleteDialog(context),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red[700],
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Jenis Pelanggaran dengan background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2), // Red 50
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFEE2E2), // Red 100
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Color(0xFFDC2626), // Red 600
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              jenisPelanggaran,
                              style: const TextStyle(
                                color: Color(0xFFB91C1C), // Red 700
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Date & Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8), // Slate 400
                        ),
                        const SizedBox(width: 6),
                        Text(
                          displayTanggal, // Gunakan variabel yang sudah diparsing
                          style: const TextStyle(
                            color: Color(0xFF64748B), // Slate 500
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Color(0xFFCBD5E1), // Slate 300
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          displayWaktu, // Gunakan variabel yang sudah diparsing
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (keterangan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), // Slate 100
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                keterangan,
                                style: const TextStyle(
                                  color: Color(0xFF475569), // Slate 600
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Slate 100
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ DIALOG KONFIRMASI HAPUS
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hapus Pelanggaran?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Data pelanggaran "$jenisPelanggaran" untuk $nama akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}