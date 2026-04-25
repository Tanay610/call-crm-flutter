import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync/sync_controller.dart';

class SyncProgressDialog extends ConsumerStatefulWidget {
  const SyncProgressDialog({super.key});

  @override
  ConsumerState<SyncProgressDialog> createState() => _SyncProgressDialogState();
}

class _SyncProgressDialogState extends ConsumerState<SyncProgressDialog> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    log('SyncProgressDialog initState');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!_started) {
      _started = true;
      _run();
    }
  });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('SyncProgressDialog didChangeDependencies');
  }

  Future<void> _run() async {
    final notifier = ref.read(syncControllerProvider.notifier);
    try {
      await notifier.syncAll();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync complete.')));
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      log('Sync failed', error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncAsync = ref.watch(syncControllerProvider);
    final sync = syncAsync.value;
    final total = sync?.total ?? 0;
    final completed = sync?.completed ?? 0;
    final failed = sync?.failed ?? 0;

    return AlertDialog(
      title: const Text('Syncing recordings'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(value: total == 0 ? null : completed / total),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(value: total == 0 ? 0 : completed / total),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Uploaded $completed / $total'),
            if (failed > 0) Text('Failed: $failed'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hide'),
        ),
      ],
    );
  }
}
