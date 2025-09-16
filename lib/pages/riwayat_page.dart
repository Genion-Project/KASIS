import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        backgroundColor: Colors.purple[600],
      ),
      body: const Center(
        child: Text(
          'Halaman Riwayat',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
