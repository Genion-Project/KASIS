import 'package:flutter/material.dart';
import '../../widgets/rekap/anggota_item.dart';

class RekapAnggotaDialog extends StatefulWidget {
  const RekapAnggotaDialog({super.key});

  @override
  State<RekapAnggotaDialog> createState() => _RekapAnggotaDialogState();
}

class _RekapAnggotaDialogState extends State<RekapAnggotaDialog> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.people_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Rekap Anggota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kelas...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            
            // List Anggota
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  AnggotaItem(
                    nama: 'Ahmad Rizki Pratama',
                    kelas: 'XII IPA 1',
                    jumlahPelanggaran: 3,
                    totalPoin: 15,
                  ),
                  AnggotaItem(
                    nama: 'Siti Nurhaliza',
                    kelas: 'XI IPS 2',
                    jumlahPelanggaran: 2,
                    totalPoin: 15,
                  ),
                  AnggotaItem(
                    nama: 'Budi Santoso',
                    kelas: 'XII IPA 2',
                    jumlahPelanggaran: 1,
                    totalPoin: 5,
                  ),
                  AnggotaItem(
                    nama: 'Dewi Lestari',
                    kelas: 'X IPA 3',
                    jumlahPelanggaran: 4,
                    totalPoin: 20,
                  ),
                  AnggotaItem(
                    nama: 'Eko Prasetyo',
                    kelas: 'XI IPS 1',
                    jumlahPelanggaran: 2,
                    totalPoin: 10,
                  ),
                  AnggotaItem(
                    nama: 'Farah Diba',
                    kelas: 'XII IPA 1',
                    jumlahPelanggaran: 1,
                    totalPoin: 5,
                  ),
                  AnggotaItem(
                    nama: 'Gilang Ramadhan',
                    kelas: 'X IPS 1',
                    jumlahPelanggaran: 5,
                    totalPoin: 25,
                  ),
                  AnggotaItem(
                    nama: 'Hani Wijaya',
                    kelas: 'XI IPA 3',
                    jumlahPelanggaran: 0,
                    totalPoin: 0,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}