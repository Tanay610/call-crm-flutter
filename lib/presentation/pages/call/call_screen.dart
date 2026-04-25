import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:call_crm_app/presentation/providers/recordings/recordings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/audio/audio_session_controller.dart';
import '../../providers/audio/audio_session_state.dart';
import '../../providers/customers/customer_by_id_provider.dart';
import '../../../domain/entities/customer.dart';
class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({super.key, required this.customerId});

  final String customerId;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  // Use ValueNotifier for local UI state (no setState needed)
  final ValueNotifier<bool> _permissionsOk = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _saving = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _recordingId = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _filePath = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _showPermissionDialog = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermissions());
  }

  @override
  void dispose() {
    _permissionsOk.dispose();
    _saving.dispose();
    _recordingId.dispose();
    _filePath.dispose();
    _showPermissionDialog.dispose();
    super.dispose();
  }

  Future<void> _ensurePermissions() async {
    final mic = Permission.microphone;
    Permission? storageOrAudio;

    if (Platform.isAndroid) {
      final androidVersion = await _getAndroidVersion();
      if (androidVersion >= 33) {
        // Android 13+: use audio permission for recording
        storageOrAudio = Permission.audio;
      } else {
        storageOrAudio = Permission.storage;
      }
    }

    final permissions = [mic];
    if (storageOrAudio != null) {
      permissions.add(storageOrAudio);
    }

    final statuses = await permissions.request();
    
    final micGranted = statuses[mic]?.isGranted ?? false;
    final storageGranted = storageOrAudio == null || (statuses[storageOrAudio]?.isGranted ?? false);

    if (!mounted) return;

    if (micGranted && storageGranted) {
      _permissionsOk.value = true;
      _showPermissionDialog.value = false;
      return;
    }

    // Check if any permission is permanently denied
    final permanentlyDenied = statuses.values.any((s) => s.isPermanentlyDenied);
    
    if (permanentlyDenied) {
      _showPermissionDialog.value = true;
      await _showSettingsDialog();
    } else {
      // Permission denied but not permanently - show dialog to retry
      _showPermissionDialog.value = true;
      await _showRetryDialog();
    }
  }

  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // Get Android SDK version
      return int.tryParse(await _getAndroidSdkVersion() ?? '0') ?? 0;
    }
    return 0;
  }

  Future<String?> _getAndroidSdkVersion() async {
    // Simple version - in production use device_info_plus
    return '34'; // Default to Android 14 for testing
  }

  Future<void> _showSettingsDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Microphone permission is permanently denied. Please enable it from App Settings to use recording features.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showPermissionDialog.value = false;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await openAppSettings();
              if (context.mounted) {
                Navigator.of(context).pop();
                // Check permissions again after returning from settings
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) await _ensurePermissions();
              }
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRetryDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Microphone permission is required to record calls. Please grant permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              _showPermissionDialog.value = false;
              Navigator.of(context).pop();
              // Close the call screen if user cancels
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPermissionDialog.value = false;
              _ensurePermissions();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording({
    required Customer customer,
    required RecordingsController recordingsCtrl,
    required AudioSessionController audioCtrl,
  }) async {
    try {
      // Allocate recording path
      final allocation = await recordingsCtrl.allocateRecordingPath(
        customerId: customer.id,
      );
      _recordingId.value = allocation.recordingId;
      _filePath.value = allocation.filePath;
      
      // Start recording
      await audioCtrl.startRecording(allocation.filePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopRecording({
    required Customer customer,
    required RecordingsController recordingsCtrl,
    required AudioSessionController audioCtrl,
  }) async {
    _saving.value = true;
    
    try {
      final durationMillis = await audioCtrl.stopRecording();
      final recordingId = _recordingId.value;
      final filePath = _filePath.value;
      
      if (recordingId == null || filePath == null) {
        throw Exception('Recording path not initialized');
      }
      
      await recordingsCtrl.persistRecording(
        customer: customer,
        recordingId: recordingId,
        filePath: filePath,
        durationMillis: durationMillis,
      );
      
      _recordingId.value = null;
      _filePath.value = null;
      
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save recording: $e')),
      );
    } finally {
      _saving.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerAsync = ref.watch(customerByIdProvider(widget.customerId));
    final audio = ref.watch(audioSessionControllerProvider);
    final audioCtrl = ref.read(audioSessionControllerProvider.notifier);
    final recorderController = ref.watch(recorderControllerProvider);
    final recordingsCtrl = ref.read(recordingsControllerProvider(widget.customerId).notifier);
    // In build method:
final duration = ref.watch(
  audioSessionControllerProvider.select((state) => state.recordingElapsed)
);

    final status = audio.recordingStatus;
    final isRecording = status == RecordingStatus.recording;
    final isPaused = status == RecordingStatus.paused;

    return Scaffold(
      appBar: AppBar(title: const Text('Active Call')),
      body: ValueListenableBuilder(
        valueListenable: _showPermissionDialog,
        builder: (context, showDialog, _) {
          // Dialog is shown via separate Future, body renders normally
          return customerAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load customer: $e')),
            data: (customer) {
              if (customer == null) {
                return const Center(child: Text('Customer not found.'));
              }

              return ValueListenableBuilder(
                valueListenable: _permissionsOk,
                builder: (context, permissionsOk, _) {
                  return ValueListenableBuilder(
                    valueListenable: _saving,
                    builder: (context, isSaving, _) {
                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const SizedBox(height: 8),
                              CircleAvatar(
                                radius: 42,
                                child: Text(
                                  customer.name.isEmpty 
                                      ? '?' 
                                      : customer.name[0].toUpperCase(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                customer.name, 
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(customer.phone),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, 
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Status'),
                                    Text(
                                      permissionsOk
                                          ? (isRecording 
                                              ? 'Recording' 
                                              : isPaused 
                                                  ? 'Paused' 
                                                  : 'Ready')
                                          : 'Permissions required',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                    ),
                                    child: Center(
                                      child: permissionsOk
                                          ? AudioWaveforms(
                                              size: const Size(double.infinity, 120),
                                              recorderController: recorderController,
                                              waveStyle: const WaveStyle(
                                                waveColor: Colors.greenAccent,
                                                showMiddleLine: false,
                                                extendWaveform: true,
                                              ),
                                            )
                                          : const Text('Grant permissions to see waveform'),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (isSaving) const LinearProgressIndicator(),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Pause/Resume Button
                                  FilledButton.tonalIcon(
                                    onPressed: (!permissionsOk || isSaving || (!isRecording && !isPaused))
                                        ? null
                                        : () async {
                                            if (isPaused) {
                                              await audioCtrl.resumeRecording();
                                            } else {
                                              await audioCtrl.pauseRecording();
                                            }
                                          },
                                    icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
                                    label: Text(isPaused ? 'Resume' : 'Pause'),
                                  ),
                                  
                                  // Record/Stop Button
                                  FilledButton.icon(
                                    onPressed: (!permissionsOk || isSaving)
                                        ? null
                                        : () async {
                                            if (!isRecording && !isPaused) {
                                              await _startRecording(
                                                customer: customer,
                                                recordingsCtrl: recordingsCtrl,
                                                audioCtrl: audioCtrl,
                                              );
                                            } else {
                                              await _stopRecording(
                                                customer: customer,
                                                recordingsCtrl: recordingsCtrl,
                                                audioCtrl: audioCtrl,
                                              );
                                            }
                                          },
                                    icon: Icon(
                                      !isRecording && !isPaused 
                                          ? Icons.fiber_manual_record 
                                          : Icons.stop,
                                    ),
                                    label: Text(
                                      !isRecording && !isPaused ? 'Record' : 'Stop',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                isRecording || isPaused
                                    ? 'Recording… (saved to Documents/recordings/${customer.id}/${_recordingId.value ?? ''}.m4a)'
                                    : 'Tap Record to start',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              if (isRecording || isPaused )
                                   Text(
                                      'Duration: ${Formatters.durationMillis(duration?.inMilliseconds ?? 0)}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                 
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}