import 'package:flutter/material.dart';

class InputPelanggaranDialog extends StatefulWidget {
  final VoidCallback onSaved;
  
  const InputPelanggaranDialog({
    super.key,
    required this.onSaved,
  });

  @override
  State<InputPelanggaranDialog> createState() => _InputPelanggaranDialogState();
}

class _InputPelanggaranDialogState extends State<InputPelanggaranDialog> {
  final _namaController = TextEditingController();
  final _keteranganController = TextEditingController();
  String? _selectedKelas;
  String? _selectedJenisPelanggaran;

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  void _handleSave() {
    Navigator.pop(context);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: Colors.blue[700],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Input Pelanggaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Nama Siswa
              const Text(
                'Nama Siswa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _namaController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama siswa',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kelas
              const Text(
                'Kelas',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKelas,
                decoration: InputDecoration(
                  hintText: 'Pilih kelas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'X IPA 1', child: Text('X IPA 1')),
                  DropdownMenuItem(value: 'X IPA 2', child: Text('X IPA 2')),
                  DropdownMenuItem(value: 'X IPA 3', child: Text('X IPA 3')),
                  DropdownMenuItem(value: 'X IPS 1', child: Text('X IPS 1')),
                  DropdownMenuItem(value: 'X IPS 2', child: Text('X IPS 2')),
                  DropdownMenuItem(value: 'XI IPA 1', child: Text('XI IPA 1')),
                  DropdownMenuItem(value: 'XI IPA 2', child: Text('XI IPA 2')),
                  DropdownMenuItem(value: 'XI IPA 3', child: Text('XI IPA 3')),
                  DropdownMenuItem(value: 'XI IPS 1', child: Text('XI IPS 1')),
                  DropdownMenuItem(value: 'XI IPS 2', child: Text('XI IPS 2')),
                  DropdownMenuItem(value: 'XII IPA 1', child: Text('XII IPA 1')),
                  DropdownMenuItem(value: 'XII IPA 2', child: Text('XII IPA 2')),
                  DropdownMenuItem(value: 'XII IPA 3', child: Text('XII IPA 3')),
                  DropdownMenuItem(value: 'XII IPS 1', child: Text('XII IPS 1')),
                  DropdownMenuItem(value: 'XII IPS 2', child: Text('XII IPS 2')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedKelas = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Dropdown Jenis Pelanggaran
              const Text(
                'Jenis Pelanggaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedJenisPelanggaran,
                decoration: InputDecoration(
                  hintText: 'Pilih jenis pelanggaran',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'dasi',
                    child: Text('Tidak Memakai Dasi'),
                  ),
                  DropdownMenuItem(
                    value: 'sepatu',
                    child: Text('Sepatu Tidak Sesuai'),
                  ),
                  DropdownMenuItem(
                    value: 'rambut',
                    child: Text('Rambut Tidak Rapi'),
                  ),
                  DropdownMenuItem(
                    value: 'ikat_pinggang',
                    child: Text('Tidak Memakai Ikat Pinggang'),
                  ),
                  DropdownMenuItem(
                    value: 'baju',
                    child: Text('Baju Tidak Dimasukkan'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedJenisPelanggaran = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Keterangan
              const Text(
                'Keterangan (Opsional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _keteranganController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tambahkan keterangan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Batal',
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
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }
}