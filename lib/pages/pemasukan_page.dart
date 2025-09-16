import 'package:flutter/material.dart';

class PemasukanPage extends StatelessWidget {
  const PemasukanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemasukan'),
        backgroundColor: Colors.green[600],
      ),
      body: const Center(
        child: Text(
          'Halaman Pemasukan',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
