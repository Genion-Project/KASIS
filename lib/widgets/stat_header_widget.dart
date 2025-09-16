import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StatHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getMembers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final members = snapshot.data!;

            // Hitung total anggota dan status bayar
            final totalAnggota = members.length;
            final sudahBayar = members.where((m) => (m['amount'] ?? 0) > 0).length;
            final belumBayar = totalAnggota - sudahBayar;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total Anggota', '$totalAnggota', Icons.people),
                _buildStatCard('Sudah Bayar', '$sudahBayar', Icons.check_circle),
                _buildStatCard('Belum Bayar', '$belumBayar', Icons.pending),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}