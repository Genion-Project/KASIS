import 'package:flutter/material.dart';
import '../../widgets/rekap/anggota_item.dart';
import '../../services/api_service.dart';

class RekapAnggotaDialog extends StatefulWidget {
  const RekapAnggotaDialog({super.key});

  @override
  State<RekapAnggotaDialog> createState() => _RekapAnggotaDialogState();
}

class _RekapAnggotaDialogState extends State<RekapAnggotaDialog> {
  String searchQuery = '';
  List<Map<String, dynamic>> _rekap = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final data = await ApiService.getRekapPelanggaran();
      setState(() {
        _rekap = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch rekap: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _rekap.where((item) {
      final nama = item["nama"].toString().toLowerCase();
      final kelas = item["kelas"].toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return nama.contains(q) || kelas.contains(q);
    }).toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 700,
          maxWidth: 600,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan Gradient
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rekap Anggota',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_rekap.length} Total Siswa',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      tooltip: 'Tutup',
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kelas...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 24),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: Colors.grey[600], size: 20),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Info Bar (jumlah hasil pencarian)
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Ditemukan ${filtered.length} hasil',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 12),

            // List Anggota
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  searchQuery.isEmpty ? Icons.people_outline : Icons.search_off_rounded,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                searchQuery.isEmpty ? "Tidak ada data" : "Tidak ditemukan",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                searchQuery.isEmpty
                                    ? "Belum ada siswa terdaftar"
                                    : "Coba kata kunci lain",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return AnggotaItem(
                              nama: item["nama"],
                              kelas: item["kelas"],
                              jumlahPelanggaran: item["jumlah"],
                              totalPoin: item["poin"],
                            );
                          },
                        ),
            ),

            // Footer dengan info tambahan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Data diperbarui secara real-time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
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
}