import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/prayer_provider.dart';

class _SupportersDialog extends StatefulWidget {
  final int prayerId;

  const _SupportersDialog({Key? key, required this.prayerId}) : super(key: key);

  @override
  State<_SupportersDialog> createState() => _SupportersDialogState();
}

class _SupportersDialogState extends State<_SupportersDialog> {
  @override
  void initState() {
    super.initState();
    context.read<PrayerProvider>().loadSupporters(widget.prayerId);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('People Praying'),
      content: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isSupportersLoading) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                provider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final supporters = provider.supporters;

          if (supporters.isEmpty) {
            return const Center(
              child: Text('No one has prayed for this request yet.'),
            );
          }

          return SizedBox(
            width: double.maxFinite,
            height: 300, // Maximum height for the dialog
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: supporters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/default_profile.png'),
                  ),
                  title: Text(supporters[index]),
                );
              },
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}