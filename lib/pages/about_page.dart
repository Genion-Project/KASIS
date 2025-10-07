import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1E3A8A),
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 24, 24),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tentang Aplikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // App Logo & Name
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Container(
                      padding: EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // App Icon
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 60,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 20),

                          // App Name
                          Text(
                            'KASIS App',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),

                          // Version
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Versi 1.0.0',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Deskripsi Aplikasi
                    _buildSectionTitle('Tentang'),
                    SizedBox(height: 16),
                    _buildDescriptionCard(
                      'KASIS App merupakan aplikasi manajemen sekolah serbaguna yang memudahkan pengelolaan data keuangan dan non-keuangan. Aplikasi ini dapat digunakan untuk mencatat pemasukan dan pengeluaran kas, mengelola data pelanggaran siswa, serta menyusun laporan dengan akurat dan efisien. Dengan antarmuka yang sederhana dan fitur yang fleksibel, Bendahara App membantu guru, bendahara, dan pihak sekolah dalam menjaga transparansi serta efektivitas administrasi sekolah.',
                    ),

                    SizedBox(height: 28),

                    // Fitur Utama
                    _buildSectionTitle('Fitur Utama'),
                    SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.add_circle_outline,
                      title: 'Pencatatan Pemasukan',
                      description: 'Catat semua transaksi pemasukan dengan mudah',
                      color: Colors.green[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.remove_circle_outline,
                      title: 'Pencatatan Pengeluaran',
                      description: 'Kelola pengeluaran dengan sistematis',
                      color: Colors.red[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.assessment_outlined,
                      title: 'Laporan Keuangan',
                      description: 'Lihat rekap dan laporan lengkap',
                      color: Colors.blue[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildFeatureItem(
                      icon: Icons.history_rounded,
                      title: 'Riwayat Rekap Pelanggaran Siswa',
                      description: 'Akses riwayat pelanggaran Siswa Kapan saja.',
                      color: Colors.orange[600]!,
                    ),

                    SizedBox(height: 28),

                    // Developer Info
                    _buildSectionTitle('Developer'),
                    SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.code_rounded,
                      title: 'Dikembangkan oleh',
                      subtitle: 'Genion Team',
                      color: Colors.purple[600]!,
                    ),
                    SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Tahun Rilis',
                      subtitle: '2025',
                      color: Colors.teal[600]!,
                    ),

                    SizedBox(height: 28),

                    // Contact Section
                    _buildSectionTitle('Hubungi Kami'),
                    SizedBox(height: 16),
                    _buildContactButton(
                      icon: Icons.email_outlined,
                      label: 'Email Support',
                      subtitle: 'nuristefarpl@gmail.com',
                      color: Colors.blue[600]!,
                      onTap: () {
                        _launchURL('mailto:support@bendaharaapp.com');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Email: nuristefarpl@gmail.com'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    _buildContactButton(
                      icon: Icons.language_rounded,
                      label: 'Website',
                      subtitle: 'tefa.genion.site',
                      color: Colors.indigo[600]!,
                      onTap: () {
                        _launchURL('https://tefa.genion.site');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Website: tefa.genion.site'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 32),

                    // Credits
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Develop by',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite, color: Colors.red[400], size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Genion Team',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            '© 2025 KASIS . All rights reserved.',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[900],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.6,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}