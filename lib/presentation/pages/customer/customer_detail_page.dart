import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/formatters.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/recording.dart';
import '../../providers/audio/audio_session_controller.dart';
import '../../providers/customers/customer_by_id_provider.dart';
import '../../providers/customers/customers_controller.dart';
import '../../providers/recordings/recordings_controller.dart';
import '../call/call_screen.dart';
import 'customer_form_page.dart';
import '../sync/sync_progress_dialog.dart';

class CustomerDetailPage extends ConsumerWidget {
  const CustomerDetailPage({super.key, required this.customerId, this.embedded = false});

  final String customerId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(customerId));
    return customerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load customer: $e')),
      data: (customer) {
        if (customer == null) return const Center(child: Text('Customer not found.'));

        final body = _CustomerDetailBody(customer: customer, embedded: embedded);
        if (embedded) return body;
        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              IconButton(
                tooltip: 'Sync to Cloud',
                onPressed: () async {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const SyncProgressDialog(),
                  );
                },
                icon: const Icon(Icons.cloud_upload_outlined),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CustomerFormPage(customerId: customerId)),
                  );
                  ref.invalidate(customerByIdProvider(customerId));
                },
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  final ok = await _confirmDelete(context);
                  if (!ok) return;
                  await ref.read(customersControllerProvider.notifier).delete(customerId);
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  static Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete customer?'),
        content: const Text('This will delete the customer and all their recordings from disk.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _CustomerDetailBody extends ConsumerWidget {
  const _CustomerDetailBody({required this.customer, required this.embedded});

  final Customer customer;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingsAsync = ref.watch(recordingsControllerProvider(customer.id));

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CircleAvatar(radius: 28, child: Text(customer.name.isEmpty ? '?' : customer.name[0].toUpperCase())),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customer.name, style: Theme.of(context).textTheme.titleLarge),
                      Text('${customer.phone} • ${customer.company}'),
                      Text(
                        'Created ${Formatters.dateTime(customer.createdAt)}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => CallScreen(customerId: customer.id)),
                    );
                    ref.invalidate(recordingsControllerProvider(customer.id));
                    ref.invalidate(customerByIdProvider(customer.id));
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text('Record'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: recordingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Failed to load recordings: $e')),
              data: (state) {
                if (state.recordings.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No recordings yet.\nTap “Record” to create the first call recording.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, i) {
                    final r = state.recordings[i];
                    return  _RecordingTile(
                      key: ValueKey(r.id),
                        customerId: customer.id, recording: r);
                  
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemCount: state.recordings.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingTile extends ConsumerStatefulWidget {
  const _RecordingTile({super.key, required this.customerId, required this.recording});

  final String customerId;
  final Recording recording;

    @override
  ConsumerState<_RecordingTile> createState() => _RecordingTileState();
}

class _RecordingTileState extends ConsumerState<_RecordingTile> {
  // Each tile maintains its own ValueNotifiers for position and playing state
  late final ValueNotifier<Duration> _positionNotifier;
  late final ValueNotifier<bool> _isPlayingNotifier;
  Timer? _positionTimer;

  @override
  void initState() {
    super.initState();
    _positionNotifier = ValueNotifier(Duration.zero);
    _isPlayingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _positionNotifier.dispose();
    _isPlayingNotifier.dispose();
    super.dispose();
  }

  void _startPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final audio = ref.read(audioSessionControllerProvider);
      final isCurrent = audio.currentFilePath == widget.recording.filePath;
      
      if (isCurrent && audio.playing) {
        _positionNotifier.value = audio.position;
        _isPlayingNotifier.value = true;
      } else {
        timer.cancel();
        _positionTimer = null;
        if (!isCurrent) {
          _positionNotifier.value = Duration.zero;
        }
        _isPlayingNotifier.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.watch(audioSessionControllerProvider);
    final audioCtrl = ref.read(audioSessionControllerProvider.notifier);
    final isCurrent = ref.watch(
      audioSessionControllerProvider.select(
        (state) => state.currentFilePath == widget.recording.filePath
      )
    );
    final duration = Duration(milliseconds: widget.recording.durationMillis);
      final position = isCurrent ? ref.watch(
      audioSessionControllerProvider.select((state) => state.position)
    ) : Duration.zero;

     final isPlaying = isCurrent && ref.watch(
      audioSessionControllerProvider.select((state) => state.playing)
    );

    // Start timer when this tile becomes the current playing one
    if (audio.playing && isCurrent && _positionTimer == null) {
      _startPositionTimer();
    }

    // Reset when playback stops or changes
    if (!audio.playing && _isPlayingNotifier.value) {
      _isPlayingNotifier.value = false;
      if (!isCurrent) {
        _positionNotifier.value = Duration.zero;
      }
      _positionTimer?.cancel();
      _positionTimer = null;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.recording.synced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Formatters.dateTime(widget.recording.recordedAt),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Share',
                  onPressed: () async {
                    final file = File(widget.recording.filePath);
                    await SharePlus.instance.share(
                      ShareParams(files: [XFile(file.path)], text: 'Call recording'),
                    );
                  },
                  icon: const Icon(Icons.share_outlined),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete recording?'),
                        content: const Text('This will remove the recording and delete the file from disk.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (ok != true) return;
                    await ref
                        .read(recordingsControllerProvider( widget.customerId).notifier)
                        .deleteRecording(customerId: widget.customerId, recordingId: widget.recording.id);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${Formatters.durationMillis(widget.recording.durationMillis)} • ${Formatters.fileSize(widget.recording.sizeBytes)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
               
                   IconButton(
                      tooltip: isPlaying ? 'Pause' : 'Play',
                      onPressed: () async {
                        if (isPlaying) {
                          await audioCtrl.pausePlayback();
                           _isPlayingNotifier.value = false;
                          _positionTimer?.cancel();
                          _positionTimer = null;
                        } else {
                          
                          await audioCtrl.play( widget.recording.filePath);
                        }
                              _startPositionTimer();
                    
                      },
                      icon: Icon(isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline),
                    ),
                  
                Expanded(
                  child:  Slider(
                        value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                        max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                        onChanged: isCurrent
                            ? (v) async{
                                final newPos = Duration(milliseconds: v.round());
                                await audioCtrl.seek(newPos);
                                _positionNotifier.value = newPos;
                            }
                            : null,
                      ),
                  
                ),
                PopupMenuButton<double>(
                  tooltip: 'Speed',
                  initialValue: audio.speed,
                  onSelected: audioCtrl.setSpeed,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 0.5, child: Text('0.5x')),
                    PopupMenuItem(value: 1.0, child: Text('1.0x')),
                    PopupMenuItem(value: 1.5, child: Text('1.5x')),
                    PopupMenuItem(value: 2.0, child: Text('2.0x')),
                  ],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${audio.speed.toStringAsFixed(1)}x'),
                  ),
                ),
              ],
            ),
            if (isCurrent)
              ValueListenableBuilder(
                valueListenable: _positionNotifier,
                builder: (context, position, child) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${Formatters.durationMillis(position.inMilliseconds)} / ${Formatters.durationMillis(duration.inMilliseconds)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                }
              ),
          ],
        ),
      ),
    );
  }

}


