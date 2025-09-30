import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FilterSection extends StatelessWidget {
  final DateTimeRange? selectedDateRange;
  final VoidCallback onRekapPressed;
  final VoidCallback onInputPressed;
  final VoidCallback onResetFilter;

  const FilterSection({
    super.key,
    required this.selectedDateRange,
    required this.onRekapPressed,
    required this.onInputPressed,
    required this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormBuilderDateRangePicker(
                  name: 'date_range',
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2026),
                  initialValue: selectedDateRange == null
                      ? null
                      : DateTimeRange(
                          start: selectedDateRange!.start,
                          end: selectedDateRange!.end,
                        ),
                  decoration: InputDecoration(
                    labelText: 'Filter Tanggal',
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (range) {
                    // bisa panggil callback setState di parent
                    // misalnya lewat ValueNotifier atau callback
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onRekapPressed,
                icon: const Icon(Icons.people_alt, size: 20),
                label: const Text(
                  'Rekap',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onInputPressed,
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Input',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          if (selectedDateRange != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onResetFilter,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Reset Filter'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
