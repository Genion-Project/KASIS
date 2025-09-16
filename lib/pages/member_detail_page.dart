import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MemberDetailPage extends StatefulWidget {
  final int memberId;
  final String? memberName;

  const MemberDetailPage({super.key, required this.memberId, this.memberName});

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  late Future<List<Map<String, dynamic>>> _paymentsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _paymentsFuture = ApiService.getMemberPayments(widget.memberId);
      await _paymentsFuture;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 2.5,
              ),
            )
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: _paymentsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final payments = snapshot.data!;
                final paidCount = payments.where((p) => p['status'] == 'Sudah Bayar').length;
                final totalAmount = payments.fold<double>(
                  0,
                  (sum, item) => sum + ((item['status'] == 'Sudah Bayar') ? 2000 : 0),
                );

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Colors.blue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        _buildSummaryCard(payments.length, paidCount, totalAmount),
                        _buildPaymentsList(payments),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.memberName ?? 'Detail Member'),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.blue.withOpacity(0.3),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshData,
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[700]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
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
              Icons.person,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.memberName ?? 'Member',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Riwayat Pembayaran',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalWeeks, int paidCount, double totalAmount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Minggu',
                  '$totalWeeks',
                  Icons.calendar_today,
                  Colors.purple[400]!,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Sudah Bayar',
                  '$paidCount',
                  Icons.check_circle,
                  Colors.green[500]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Belum Bayar',
                  '${totalWeeks - paidCount}',
                  Icons.pending,
                  Colors.orange[500]!,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Total Terkumpul',
                  'Rp ${totalAmount.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.blue[600]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Map<String, dynamic>> payments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Icon(Icons.receipt, color: Colors.grey[700], size: 18),
              const SizedBox(width: 8),
              Text(
                'Detail Pembayaran (${payments.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            itemBuilder: (context, index) {
                final payment = payments[index];
                final isPaid = payment['status'] == 'Sudah Bayar';

                return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                    color: isPaid ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                    ),
                    boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                    ),
                    ],
                ),
                child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: isPaid ? Colors.green[500] : Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Text(
                        '${payment['week']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                        ),
                        ),
                    ),
                    ),
                    title: Text(
                    'Minggu ${payment['week']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                    ),
                    ),
                    subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        const SizedBox(height: 4),
                        if (payment['date'] != null && payment['date'] != '-')
                        Text(
                            payment['date'],
                            style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            ),
                        ),
                        if (payment['description'] != null && payment['description'] != '-')
                        Text(
                            payment['description'],
                            style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                        ),
                        if (!isPaid)
                        Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: ElevatedButton(
                            onPressed: () async {
                                try {
                                // Panggil API bayar
                                await ApiService.bayarKas(
                                    siswaId: widget.memberId,
                                    mingguKe: payment['week'],
                                );

                                // Update state lokal
                                setState(() {
                                    payment['status'] = 'Sudah Bayar';
                                    payment['amount'] = 2000;
                                    payment['description'] = 'Kas Mingguan';
                                });
                                } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal bayar: $e')),
                                );
                                }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                minimumSize: const Size(70, 28),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            ),
                            child: const Text(
                                'Bayar',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white, // atur warna di sini
                                ),
                            ),
                            ),
                        ),
                    ],
                    ),
                    trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                        Text(
                        'Rp ${payment['amount']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isPaid ? Colors.green[600] : Colors.grey[600],
                        ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: isPaid ? Colors.green[50] : Colors.red[50],
                            borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                            isPaid ? 'Lunas' : 'Belum',
                            style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isPaid ? Colors.green[700] : Colors.red[700],
                            ),
                        ),
                        ),
                    ],
                    ),
                ),
                );
            },
            ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Riwayat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Belum ada riwayat pembayaran untuk member ini',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Member: ${widget.memberName ?? "Tidak Diketahui"}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}