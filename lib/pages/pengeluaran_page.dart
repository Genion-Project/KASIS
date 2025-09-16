import 'package:flutter/material.dart';

class PengeluaranPage extends StatelessWidget {
  const PengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        backgroundColor: Colors.red[600],
      ),
      body: const Center(
        child: Text(
          'Halaman Pengeluaran',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
