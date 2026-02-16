import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/member_model.dart';

class StatHeaderWidget extends StatelessWidget {
  const StatHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 600;

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 0 : 20),
      child: FutureBuilder<List<Member>>(
        future: ApiService.getMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: isDesktop ? 2 : 3,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final members = snapshot.data!;

            // Hitung total anggota dan status bayar
            final totalAnggota = members.length;
            final sudahBayar = members.where((m) => m.totalPaid > 0).length;
            final belumBayar = totalAnggota - sudahBayar;

            // Desktop: tampilan vertikal untuk sidebar (compact)
            if (isDesktop) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDesktopStatCard('Total Anggota', '$totalAnggota', Icons.people_rounded),
                  const SizedBox(height: 8),
                  _buildDesktopStatCard('Sudah Bayar', '$sudahBayar', Icons.check_circle_rounded),
                  const SizedBox(height: 8),
                  _buildDesktopStatCard('Belum Bayar', '$belumBayar', Icons.pending_rounded),
                ],
              );
            }

            // Mobile/Tablet: tampilan horizontal
            return Row(
              children: [
                Expanded(
                  child: _buildMobileStatCard(
                    'Total\nAnggota',
                    '$totalAnggota',
                    Icons.people_rounded,
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: _buildMobileStatCard(
                    'Sudah\nBayar',
                    '$sudahBayar',
                    Icons.check_circle_rounded,
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: _buildMobileStatCard(
                    'Belum\nBayar',
                    '$belumBayar',
                    Icons.pending_rounded,
                    isMobile: isMobile,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // Desktop stat card - compact horizontal layout untuk sidebar
  Widget _buildDesktopStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mobile stat card - vertical layout
  Widget _buildMobileStatCard(
    String title,
    String value,
    IconData icon, {
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isMobile ? 12 : 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 22 : 26,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          SizedBox(height: isMobile ? 4 : 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}