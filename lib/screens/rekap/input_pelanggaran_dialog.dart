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
      // Handle error loading JSON
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

  Future<void> _handleSave() async {
    if (_namaController.text.isEmpty || _selectedKelas == null || _selectedJenisPelanggaran == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text("Harap lengkapi semua data wajib!")),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      int poin = _selectedJenisPelanggaran == "telat" ? 10 : 5;
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
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(child: Text("Data berhasil disimpan!")),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
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
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text("Gagal menyimpan: $e")),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 20 : 24)),
      elevation: 8,
      insetPadding: isMobile 
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
          : const EdgeInsets.all(40),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: screenHeight * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan gradient
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMobile ? 20 : 24),
                  topRight: Radius.circular(isMobile ? 20 : 24),
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
                    child: Icon(
                      Icons.edit_note, 
                      color: Colors.white, 
                      size: isMobile ? 24 : 28
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Input Pelanggaran",
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          "Lengkapi data pelanggaran siswa",
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form Content dengan scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search Nama dengan Autocomplete
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
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: "Nama Siswa",
                            hintText: "Cari nama siswa...",
                            prefixIcon: const Icon(Icons.person_search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : 16,
                              vertical: isMobile ? 14 : 16,
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    leading: Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                    title: Text(
                                      option['nama']!,
                                      style: TextStyle(
                                        fontSize: isMobile ? 14 : 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "Kelas ${option['kelas']!}",
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    onTap: () => onSelected(option),
                                    dense: isMobile,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isMobile ? 12 : 16),

                    // Kelas (auto-filled, read-only display)
                    if (_selectedKelas != null)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.class_, 
                              color: Colors.blue.shade700,
                              size: isMobile ? 18 : 20,
                            ),
                            SizedBox(width: isMobile ? 8 : 12),
                            Text(
                              "Kelas: $_selectedKelas",
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_selectedKelas != null) SizedBox(height: isMobile ? 12 : 16),

                    // Jenis Pelanggaran
                    DropdownButtonFormField<String>(
                      value: _selectedJenisPelanggaran,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Jenis Pelanggaran",
                        prefixIcon: const Icon(Icons.rule),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 14 : 16,
                        ),
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
                    SizedBox(height: isMobile ? 12 : 16),

                    // Keterangan
                    TextField(
                      controller: _keteranganController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Keterangan (opsional)",
                        alignLabelWithHint: true,
                        prefixIcon: const Icon(Icons.notes),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
                      ),
                    ),
                    SizedBox(height: isMobile ? 20 : 24),

                    // Buttons - Stacked vertically on mobile
                    isMobile 
                        ? Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Simpan Pelanggaran",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                  ),
                                  child: const Text(
                                    "Batal",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: _loading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Simpan",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
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
}