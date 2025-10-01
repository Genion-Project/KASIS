import 'package:flutter/material.dart';

class AnggotaItem extends StatelessWidget {
  final String nama;
  final String kelas;
  final int jumlahPelanggaran;
  final int totalPoin;

  const AnggotaItem({
    super.key,
    required this.nama,
    required this.kelas,
    required this.jumlahPelanggaran,
    required this.totalPoin,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    
    if (totalPoin == 0) {
      statusColor = Colors.green[600]!;
      statusText = 'Baik';
    } else if (totalPoin <= 40) {
      statusColor = Colors.yellow[600]!;
      statusText = 'Tindak Lanjut';
    } else if (totalPoin <= 80) {
      statusColor = Colors.orange[600]!;
      statusText = 'Sanksi';
    } else {
      statusColor = Colors.red[600]!;
      statusText = 'Buruk';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Placeholder untuk interaksi (opsional)
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar dengan Initial
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[400]!, Colors.blue[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    nama.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Badge Kelas
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            kelas,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge Status
                        if (statusText.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Stats Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      '$jumlahPelanggaran',
                      style: TextStyle(
                        color: jumlahPelanggaran > 0 ? Colors.red[600] : Colors.grey[600],
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pelanggaran',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 1,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalPoin',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Poin',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}