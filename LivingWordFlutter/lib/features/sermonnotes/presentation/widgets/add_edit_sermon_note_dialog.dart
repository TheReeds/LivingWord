import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/sermon_note_model.dart';
import '../../providers/sermon_notes_provider.dart';

class AddEditSermonNoteDialog extends StatefulWidget {
  final SermonNoteModel? sermonNote;

  const AddEditSermonNoteDialog({
    Key? key,
    this.sermonNote,
  }) : super(key: key);

  @override
  State<AddEditSermonNoteDialog> createState() => _AddEditSermonNoteDialogState();
}

class _AddEditSermonNoteDialogState extends State<AddEditSermonNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  bool _isLoading = false;
  bool _isUrlValid = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.sermonNote?.title ?? '');
    _urlController = TextEditingController(text: widget.sermonNote?.sermonUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _validateUrl(String value) async {
    if (value.isEmpty) {
      setState(() => _isUrlValid = false);
      return;
    }

    String url = value;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || !uri.hasAuthority) {
        setState(() => _isUrlValid = false);
        return;
      }
      setState(() => _isUrlValid = true);
    } catch (e) {
      setState(() => _isUrlValid = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_isUrlValid) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<SermonNotesProvider>();

      if (widget.sermonNote != null) {
        await provider.updateSermonNote(
          widget.sermonNote!.id,
          _titleController.text,
          _urlController.text,
        );
      } else {
        await provider.createSermonNote(
          _titleController.text,
          _urlController.text,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.sermonNote == null ? 'Add Sermon Note' : 'Edit Sermon Note',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter sermon note title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.title),
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
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'URL',
                    hintText: 'Enter sermon URL',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.link),
                    errorText: !_isUrlValid ? 'Please enter a valid URL' : null,
                  ),
                  onChanged: _validateUrl,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(widget.sermonNote == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}