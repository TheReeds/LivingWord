import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/video_model.dart';
import '../../providers/videos_provider.dart';

class VideoFormContent extends StatefulWidget {
  final bool isEditing;
  final VideoModel? video;

  const VideoFormContent({
    Key? key,
    required this.isEditing,
    this.video,
  }) : super(key: key);

  @override
  State<VideoFormContent> createState() => _VideoFormContentState();
}

class _VideoFormContentState extends State<VideoFormContent> {
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.video?.title ?? '');
    _urlController = TextEditingController(text: widget.video?.youtubeUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final videosProvider = context.read<VideosProvider>();

      if (widget.isEditing) {
        await videosProvider.updateVideo(
          widget.video!.id!,
          _titleController.text,
          _urlController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Video actualizado correctamente! 🎉')),
        );
      } else {
        await videosProvider.addVideo(
          _titleController.text,
          _urlController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Video agregado correctamente! 🎬')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateYoutubeUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese una URL';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !(uri.host.contains('youtube.com') || uri.host.contains('youtu.be'))) {
      return 'Por favor ingrese una URL válida de YouTube';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Campo de título
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título del video',
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        prefixIcon: const Icon(Icons.title, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Por favor ingrese un título';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    // Campo de URL
                    TextFormField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'URL de YouTube',
                        labelStyle: TextStyle(color: Colors.grey[700]),
                        prefixIcon: const Icon(Icons.link, color: Colors.blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        helperText: 'Ejemplo: https://youtube.com/watch?v=xxxxx',
                        helperStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      validator: _validateYoutubeUrl,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
            // Botón de envío
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _handleSubmit(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  widget.isEditing ? 'Guardar Cambios' : 'Agregar Video',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
