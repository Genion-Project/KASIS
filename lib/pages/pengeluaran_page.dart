import 'package:flutter/material.dart';
import '../screens/add_transaction_screen.dart';

class PengeluaranPage extends StatefulWidget {
  const PengeluaranPage({super.key});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  final List<Map<String, dynamic>> _riwayatPengeluaran = [
    {
      'judul': 'Sewa Sound System',
      'jumlah': 1500000,
      'kategori': 'Event',
      'tanggal': DateTime(2025, 9, 28),
      'keterangan': 'Sound system untuk acara HUT OSIS',
      'icon': Icons.speaker,
      'color': Colors.deepOrange,
    },
    {
      'judul': 'Konsumsi Rapat OSIS',
      'jumlah': 450000,
      'kategori': 'Konsumsi',
      'tanggal': DateTime(2025, 9, 27),
      'keterangan': 'Snack & minuman untuk 45 orang',
      'icon': Icons.fastfood,
      'color': Colors.amber,
    },
    {
      'judul': 'Dekorasi Panggung',
      'jumlah': 850000,
      'kategori': 'Dekorasi',
      'tanggal': DateTime(2025, 9, 25),
      'keterangan': 'Backdrop, balon, dan lighting',
      'icon': Icons.celebration,
      'color': Colors.pink,
    },
    {
      'judul': 'ATK & Perlengkapan',
      'jumlah': 320000,
      'kategori': 'Operasional',
      'tanggal': DateTime(2025, 9, 23),
      'keterangan': 'Kertas, spidol, isolasi, dll',
      'icon': Icons.edit_note,
      'color': Colors.blue,
    },
    {
      'judul': 'Hadiah Lomba 17an',
      'jumlah': 1200000,
      'kategori': 'Event',
      'tanggal': DateTime(2025, 9, 20),
      'keterangan': 'Hadiah juara 1,2,3 berbagai lomba',
      'icon': Icons.emoji_events,
      'color': Colors.deepOrange,
    },
    {
      'judul': 'Cetak Spanduk & Banner',
      'jumlah': 650000,
      'kategori': 'Promosi',
      'tanggal': DateTime(2025, 9, 18),
      'keterangan': '3 spanduk dan 5 banner',
      'icon': Icons.print,
      'color': Colors.purple,
    },
    {
      'judul': 'Transport Panitia',
      'jumlah': 400000,
      'kategori': 'Transport',
      'tanggal': DateTime(2025, 9, 15),
      'keterangan': 'Transport koordinasi acara',
      'icon': Icons.directions_car,
      'color': Colors.teal,
    },
  ];

  String _filterKategori = 'Semua';

  double get _totalPengeluaran {
    if (_filterKategori == 'Semua') {
      return _riwayatPengeluaran.fold(0, (sum, item) => sum + item['jumlah']);
    }
    return _riwayatPengeluaran
        .where((item) => item['kategori'] == _filterKategori)
        .fold(0, (sum, item) => sum + item['jumlah']);
  }

  List<Map<String, dynamic>> get _filteredData {
    if (_filterKategori == 'Semua') return _riwayatPengeluaran;
    return _riwayatPengeluaran
        .where((item) => item['kategori'] == _filterKategori)
        .toList();
  }

  void _tambahPengeluaran() {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddTransactionScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

  Widget _buildInputField(String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red[600]),
            hintText: isNumber ? 'Masukkan jumlah' : 'Masukkan $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red[600]!, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category, color: Colors.red[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          hint: const Text('Pilih kategori'),
          items: [
            'Event',
            'Konsumsi',
            'Dekorasi',
            'Operasional',
            'Promosi',
            'Transport',
            'Lainnya'
          ]
              .map((kategori) => DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  ))
              .toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.red[600]!,
                    ),
                  ),
                  child: child!,
                );
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.red[600], size: 20),
                const SizedBox(width: 12),
                Text(
                  'Pilih Tanggal',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTanggal(DateTime tanggal) {
    final bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Pengeluaran Kas OSIS',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Kategori',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...[
                        'Semua',
                        'Event',
                        'Konsumsi',
                        'Dekorasi',
                        'Operasional',
                        'Promosi',
                        'Transport',
                        'Lainnya'
                      ]
                          .map((kategori) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Radio<String>(
                                  value: kategori,
                                  groupValue: _filterKategori,
                                  activeColor: Colors.red[600],
                                  onChanged: (value) {
                                    setState(() {
                                      _filterKategori = value!;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                title: Text(kategori),
                                onTap: () {
                                  setState(() {
                                    _filterKategori = kategori;
                                  });
                                  Navigator.pop(context);
                                },
                              ))
                          .toList(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[600]!, Colors.red[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.money_off,
                      color: Colors.white.withOpacity(0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _filterKategori == 'Semua'
                          ? 'Total Pengeluaran'
                          : 'Pengeluaran $_filterKategori',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp ${_totalPengeluaran.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredData.length} Transaksi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Pengeluaran',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_filterKategori != 'Semua')
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _filterKategori = 'Semua';
                      });
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[600],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _filteredData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pengeluaran',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _filteredData.length,
                    itemBuilder: (context, index) {
                      final item = _filteredData[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: item['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item['icon'],
                              color: item['color'],
                              size: 26,
                            ),
                          ),
                          title: Text(
                            item['judul'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                item['keterangan'],
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item['color'].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item['kategori'],
                                      style: TextStyle(
                                        color: item['color'],
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 11,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTanggal(item['tanggal']),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '- Rp ${item['jumlah'].toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tambahPengeluaran,
        backgroundColor: Colors.red[600],
        elevation: 4,
        icon: const Icon(Icons.remove, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}