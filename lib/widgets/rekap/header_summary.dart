import 'package:flutter/material.dart';

class HeaderSummary extends StatelessWidget {
  final int totalPelanggaran;
  final int pelanggaranBulanIni;
  final int pelanggaranMingguIni;
  final bool isScrolled; // Parameter untuk mendeteksi scroll

  const HeaderSummary({
    super.key,
    required this.totalPelanggaran,
    required this.pelanggaranBulanIni,
    required this.pelanggaranMingguIni,
    this.isScrolled = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFF7931E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFF6B35).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        isScrolled ? 12 : 20,
        20,
        isScrolled ? 12 : 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header dengan icon - mengecil saat scroll
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isScrolled ? 6 : 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: isScrolled ? 16 : 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Total Pelanggaran',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isScrolled ? 13 : 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isScrolled ? 8 : 14),

          // Angka besar - mengecil saat scroll
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: Colors.white,
              fontSize: isScrolled ? 32 : 52,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text('$totalPelanggaran'),
          ),

          SizedBox(height: isScrolled ? 10 : 18),

          // Statistik Cards - tetap proporsional
          if (!isScrolled) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_month_rounded,
                    iconBg: Color(0xFFFFD93D),
                    value: '$pelanggaranBulanIni',
                    label: 'Bulan Ini',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.calendar_today_rounded,
                    iconBg: Color(0xFFFF6B6B),
                    value: '$pelanggaranMingguIni',
                    label: 'Minggu Ini',
                  ),
                ),
              ],
            ),
          ] else ...[
            // Compact view saat scroll
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompactStat(
                  icon: Icons.calendar_month_rounded,
                  value: '$pelanggaranBulanIni',
                  label: 'Bulan',
                ),
                const SizedBox(width: 20),
                Container(
                  width: 1,
                  height: 30,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(width: 20),
                _buildCompactStat(
                  icon: Icons.calendar_today_rounded,
                  value: '$pelanggaranMingguIni',
                  label: 'Minggu',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconBg.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 16,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}