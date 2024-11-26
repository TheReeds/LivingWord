import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/event/sermon_model.dart';

class SermonFormDialog extends StatefulWidget {
  final SermonModel? sermon;
  final Function(String title, String description, DateTime startTime,
      DateTime endTime, String videoLink, String summary) onSubmit;

  const SermonFormDialog({
    Key? key,
    this.sermon,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<SermonFormDialog> createState() => _SermonFormDialogState();
}

class _SermonFormDialogState extends State<SermonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _videoLinkController;
  late TextEditingController _summaryController;
  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.sermon?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.sermon?.description ?? '');
    _videoLinkController =
        TextEditingController(text: widget.sermon?.videoLink ?? '');
    _summaryController = TextEditingController(text: widget.sermon?.summary ?? '');
    _startTime = widget.sermon?.startTime ?? DateTime.now();
    _endTime = widget.sermon?.endTime ?? DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoLinkController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : _endTime,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStartTime) {
            _startTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
            // Ensure end time is after start time
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            _endTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, yyyy hh:mm a');

    return AlertDialog(
      title: Text(widget.sermon == null ? 'Create Sermon' : 'Edit Sermon'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(dateFormat.format(_startTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, true),
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(dateFormat.format(_endTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _videoLinkController,
                decoration: const InputDecoration(
                  labelText: 'Video Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit(
                _titleController.text,
                _descriptionController.text,
                _startTime,
                _endTime,
                _videoLinkController.text,
                _summaryController.text,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.sermon == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}