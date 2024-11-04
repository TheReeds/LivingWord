import 'package:flutter/material.dart';

import '../../data/models/video_model.dart';
import '../widgets/video_form_content.dart';

class CreateVideoScreen extends StatelessWidget {
  const CreateVideoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Video'),
        elevation: 0,
      ),
      body: const VideoFormContent(isEditing: false),
    );
  }
}

// screens/edit_video_screen.dart
class EditVideoScreen extends StatelessWidget {
  final VideoModel video;

  const EditVideoScreen({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Video'),
        elevation: 0,
      ),
      body: VideoFormContent(
        isEditing: true,
        video: video,
      ),
    );
  }
}