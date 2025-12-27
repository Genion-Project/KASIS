import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class InputPelanggaranDialog extends StatefulWidget {
  final VoidCallback onSaved;
  const InputPelanggaranDialog({super.key, required this.onSaved});

  @override
  State<InputPelanggaranDialog> createState() => _InputPelanggaranDialogState();
}

class _InputPelanggaranDialogState extends State<InputPelanggaranDialog> {
  final _namaController = TextEditingController();
  final _keteranganController = TextEditingController();

  String? _selectedKelas;
  String? _selectedJenisPelanggaran;
  bool _loading = false;

  // daftar siswa [nama, kelas]
  List<Map<String, String>> _siswaList = [];

  // Theme Constants
  static const Color primaryDark = Color(0xFF1E3A8A); // Slate 900
  static const Color primaryLight = Color(0xFF2563EB); // Blue 600
  static const Color surfaceColor = Color(0xFFF8FAFC); // Slate 50

  @override
  void initState() {
    super.initState();
    _loadSiswaFromJson();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadSiswaFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data_siswa.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      List<Map<String, String>> temp = [];
      data.forEach((kelas, siswaList) {
        for (var nama in siswaList) {
          temp.add({"nama": nama.toString(), "kelas": kelas});
        }
      });

      setState(() => _siswaList = temp);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data siswa: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  int _getPoin(String jenis) {
    if (jenis == 'telat') return 10;
    return 5;
  }

  Future<void> _handleSave() async {
    if (_namaController.text.isEmpty || _selectedKelas == null || _selectedJenisPelanggaran == null) {
      if (mounted) {
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
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text("Harap lengkapi data wajib!", style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            backgroundColor: const Color(0xFFF59E0B), // Amber 500
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      int poin = _getPoin(_selectedJenisPelanggaran!);
      String tanggal = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

      await ApiService.addPelanggaran({
        "nama": _namaController.text,
        "kelas": _selectedKelas!,
        "jenis_pelanggaran": _selectedJenisPelanggaran!,
        "keterangan": _keteranganController.text,
        "poin": poin,
        "tanggal": tanggal,
      });

      if (mounted) {
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
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(child: Text("Data berhasil disimpan!", style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
            backgroundColor: const Color(0xFF10B981), // Emerald 500
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        );

        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text("Gagal menyimpan: $e")),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444), // Red 500
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
             margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: isMobile 
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 24)
          : const EdgeInsets.all(40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryDark, primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.note_add_rounded, 
                      color: Colors.white, 
                      size: 28
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Input Pelanggaran",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Catat pelanggaran siswa",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    _buildLabel("Data Siswa"),
                    const SizedBox(height: 8),
                    // Search Nama / Autocomplete
                    Autocomplete<Map<String, String>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, String>>.empty();
                        }
                        return _siswaList.where((siswa) =>
                            siswa['nama']!.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      displayStringForOption: (option) => option['nama']!,
                      onSelected: (option) {
                        _namaController.text = option['nama']!;
                        setState(() => _selectedKelas = option['kelas']);
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          decoration: _buildInputDecoration(
                            hint: "Ketik nama siswa...",
                            icon: Icons.search_rounded,
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            child: Container(
                              width: 300,
                              constraints: const BoxConstraints(maxHeight: 250),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListView.separated(
                                padding: const EdgeInsets.all(8),
                                shrinkWrap: true,
                                itemCount: options.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryLight.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.person_outline_rounded, size: 20, color: primaryLight),
                                    ),
                                    title: Text(
                                      option['nama']!,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    subtitle: Text(
                                      "Kelas ${option['kelas']!}",
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    if (_selectedKelas != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // Blue 50
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFDBEAFE)), // Blue 200
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.school_rounded, color: primaryLight, size: 20),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Kelas terpilih", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                Text(
                                  _selectedKelas!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildLabel("Detail Pelanggaran"),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: _selectedJenisPelanggaran,
                      isExpanded: true,
                      decoration: _buildInputDecoration(
                        hint: "Pilih jenis pelanggaran",
                        icon: Icons.warning_amber_rounded,
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'telat', child: Text('⏰ Datang Telat')),
                        DropdownMenuItem(value: 'dasi', child: Text('👔 Tidak Memakai Dasi')),
                        DropdownMenuItem(value: 'sepatu', child: Text('👞 Sepatu Tidak Sesuai')),
                        DropdownMenuItem(value: 'gesper', child: Text('📎 Gesper Tidak Sesuai')),
                        DropdownMenuItem(value: 'kaos kaki', child: Text('🧦 Kaus Kaki Tidak sesuai')),
                        DropdownMenuItem(value: 'rok', child: Text('👗 Memakai Rok Span')),
                        DropdownMenuItem(value: 'seragam', child: Text('👕 Seragam Tidak sesuai hari')),
                        DropdownMenuItem(value: 'ciput', child: Text('🧕 Tidak Pakai Ciput')),
                      ],
                      onChanged: (val) => setState(() => _selectedJenisPelanggaran = val),
                    ),

                    if (_selectedJenisPelanggaran != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2), // Red 50
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFECACA)), // Red 200
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.remove_circle_outline_rounded, size: 14, color: Color(0xFFEF4444)),
                                const SizedBox(width: 6),
                                Text(
                                  "Poin Pelanggaran: ${_getPoin(_selectedJenisPelanggaran!)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB91C1C), // Red 700
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildLabel("Keterangan Tambahan"),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _keteranganController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                      decoration: _buildInputDecoration(
                        hint: "Tambahkan catatan jika perlu (opsional)",
                        icon: Icons.notes_rounded,
                      ).copyWith(
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              foregroundColor: Colors.grey[600],
                            ),
                            child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryLight,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: primaryLight.withOpacity(0.4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save_rounded, size: 18),
                                      SizedBox(width: 8),
                                      Text("Simpan Data", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155), // Slate 700
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 22),
      filled: true,
      fillColor: const Color(0xFFF8FAFC), // Slate 50
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryLight, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}