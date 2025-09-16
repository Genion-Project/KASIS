import 'package:flutter/material.dart';

class QuickActionWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap; // <-- tambahkan onTap

  const QuickActionWidget({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap, // <-- tambahkan onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // <-- GestureDetector untuk menangkap klik
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
