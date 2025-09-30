import 'package:flutter/material.dart';
import 'stat_item.dart';

class HeaderSummary extends StatelessWidget {
  final int totalPelanggaran;
  final int pelanggaranBulanIni;
  final int pelanggaranMingguIni;

  const HeaderSummary({
    super.key,
    required this.totalPelanggaran,
    required this.pelanggaranBulanIni,
    required this.pelanggaranMingguIni,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          const Text(
            'Total Pelanggaran',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPelanggaran',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              StatItem(
                label: 'Bulan Ini',
                value: '$pelanggaranBulanIni',
                color: Colors.amber[400]!,
              ),
              StatItem(
                label: 'Minggu Ini',
                value: '$pelanggaranMingguIni',
                color: Colors.red[400]!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}