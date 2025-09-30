import 'package:flutter/material.dart';

class FilterTabs extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const FilterTabs({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildFilterTab('Semua'),
          ),
          Expanded(
            child: _buildFilterTab('Rekap'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isActive = activeFilter == label;
    return InkWell(
      onTap: () => onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.blue[700]! : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.blue[700] : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}