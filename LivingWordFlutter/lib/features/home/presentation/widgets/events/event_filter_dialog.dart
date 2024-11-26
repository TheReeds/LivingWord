import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/events_provider.dart';

class EventFilterDialog extends StatefulWidget {
  const EventFilterDialog({Key? key}) : super(key: key);

  @override
  State<EventFilterDialog> createState() => _EventFilterDialogState();
}

class _EventFilterDialogState extends State<EventFilterDialog> {
  String? _selectedMinistry;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Events'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedMinistry,
            decoration: const InputDecoration(
              labelText: 'Ministry',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Ministries')),
              DropdownMenuItem(value: 'Youth', child: Text('Youth')),
              DropdownMenuItem(value: 'Music', child: Text('Music')),
              DropdownMenuItem(value: 'Children', child: Text('Children')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMinistry = value;
              });
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _dateRange = picked;
                });
              }
            },
            icon: const Icon(Icons.date_range),
            label: Text(
              _dateRange == null
                  ? 'Select Date Range'
                  : '${DateFormat('MMM dd').format(_dateRange!.start)} - ${DateFormat('MMM dd').format(_dateRange!.end)}',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply filters
            context.read<EventsProvider>().applyFilters(
              ministry: _selectedMinistry,
              dateRange: _dateRange,
            );
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}