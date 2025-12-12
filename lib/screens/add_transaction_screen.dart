import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String selectedType = 'Pemasukan';
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final List<String> days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    String dayName = days[date.weekday % 7];
    String monthName = months[date.month - 1];
    
    return '$dayName, ${date.day} $monthName ${date.year}';
  }

  String _formatDateForApi(DateTime date) {
    String year = date.year.toString();
    String month = date.month.toString().padLeft(2, '0');
    String day = date.day.toString().padLeft(2, '0');
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    String second = date.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  Future<void> _saveTransaction() async {
    if (amountController.text.isEmpty) {
      _showErrorSnackBar('Jumlah tidak boleh kosong');
      return;
    }

    if (descriptionController.text.isEmpty) {
      _showErrorSnackBar('Keterangan tidak boleh kosong');
      return;
    }

    final jumlah = int.tryParse(amountController.text);
    if (jumlah == null || jumlah <= 0) {
      _showErrorSnackBar('Jumlah harus berupa angka yang valid');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Combine selectedDate with current time
      final now = DateTime.now();
      final DateTime transactionDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );

      bool success = false;
      
      if (selectedType == 'Pemasukan') {
        success = await ApiService.addPemasukan(
          tanggal: _formatDateForApi(transactionDateTime),
          jumlah: jumlah,
          keterangan: descriptionController.text,
        );
      } else {
        success = await ApiService.addPengeluaran(
          tanggal: _formatDateForApi(transactionDateTime),
          jumlah: jumlah,
          keterangan: descriptionController.text,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (success) {
        _showSuccessSnackBar('Transaksi berhasil ditambahkan!');
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context, true);
      } else {
        _showErrorSnackBar('Gagal menambahkan transaksi');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Terjadi kesalahan: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Color(0xFF6C63FF),
                leading: Container(
                  margin: EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF7C73FF),
                          Color(0xFF6C63FF),
                          Color(0xFF5A52D5),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -40,
                          top: -40,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -30,
                          bottom: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.08),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  title: Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Selection Card
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey[50]!],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF6C63FF).withOpacity(0.2), Color(0xFF6C63FF).withOpacity(0.1)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.category_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Jenis Transaksi',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedType = 'Pemasukan';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      decoration: BoxDecoration(
                                        gradient: selectedType == 'Pemasukan'
                                            ? LinearGradient(
                                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                              )
                                            : LinearGradient(
                                                colors: [Colors.grey[100]!, Colors.grey[100]!],
                                              ),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: selectedType == 'Pemasukan'
                                              ? Colors.transparent
                                              : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                        boxShadow: selectedType == 'Pemasukan'
                                            ? [
                                                BoxShadow(
                                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 6),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.trending_up_rounded,
                                            color: selectedType == 'Pemasukan'
                                                ? Colors.white
                                                : Colors.grey[500],
                                            size: 32,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Pemasukan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: selectedType == 'Pemasukan'
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedType = 'Pengeluaran';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      decoration: BoxDecoration(
                                        gradient: selectedType == 'Pengeluaran'
                                            ? LinearGradient(
                                                colors: [Color(0xFFEF5350), Color(0xFFE57373)],
                                              )
                                            : LinearGradient(
                                                colors: [Colors.grey[100]!, Colors.grey[100]!],
                                              ),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: selectedType == 'Pengeluaran'
                                              ? Colors.transparent
                                              : Colors.grey[300]!,
                                          width: 2,
                                        ),
                                        boxShadow: selectedType == 'Pengeluaran'
                                            ? [
                                                BoxShadow(
                                                  color: Color(0xFFEF5350).withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: Offset(0, 6),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.trending_down_rounded,
                                            color: selectedType == 'Pengeluaran'
                                                ? Colors.white
                                                : Colors.grey[500],
                                            size: 32,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'Pengeluaran',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: selectedType == 'Pengeluaran'
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Amount Input Card
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF6C63FF).withOpacity(0.2), Color(0xFF6C63FF).withOpacity(0.1)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.payments_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Jumlah',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            TextField(
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[800],
                                letterSpacing: -0.5,
                              ),
                              decoration: InputDecoration(
                                prefixText: 'Rp ',
                                prefixStyle: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6C63FF),
                                  letterSpacing: -0.5,
                                ),
                                hintText: '0',
                                hintStyle: TextStyle(
                                  color: Colors.grey[300],
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF6C63FF),
                                    width: 2.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Date Input Card
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF6C63FF).withOpacity(0.2), Color(0xFF6C63FF).withOpacity(0.1)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Tanggal',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            InkWell(
                              onTap: () => _selectDate(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 20,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey[200]!,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatDate(selectedDate),
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF6C63FF).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: Color(0xFF6C63FF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Description Input Card
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 15,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF6C63FF).withOpacity(0.2), Color(0xFF6C63FF).withOpacity(0.1)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.description_rounded,
                                    color: Color(0xFF6C63FF),
                                    size: 22,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Keterangan',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[800],
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18),
                            TextField(
                              controller: descriptionController,
                              maxLines: 4,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Masukkan keterangan transaksi...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Color(0xFF6C63FF),
                                    width: 2.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(20),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),

                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF7C73FF), Color(0xFF5A52D5)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF6C63FF).withOpacity(0.4),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveTransaction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Simpan Transaksi',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Menyimpan transaksi...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
