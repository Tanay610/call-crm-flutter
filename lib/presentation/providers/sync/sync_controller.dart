import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/repositories/recording_api.dart';
import '../../../domain/repositories/recording_repository.dart';
import '../customers/customers_controller.dart';
import 'sync_state.dart';

final syncControllerProvider = AsyncNotifierProvider<SyncController, SyncState>(SyncController.new);

class SyncController extends AsyncNotifier<SyncState> {
  late final RecordingRepository _recordings;
  late final RecordingApi _api;

  @override
  Future<SyncState> build() async {
    _recordings = ref.read(recordingRepositoryProvider);
    _api = ref.read(recordingApiProvider);
    final unsynced = await _recordings.getUnsynced();
    return SyncState(isSyncing: false, total: unsynced.length, completed: 0, failed: 0);
  }

  Future<void> syncAll({int maxRetries = 2}) async {
    final current = state.value ?? SyncState.idle;
    state = AsyncValue.data(current.copyWith(isSyncing: true, completed: 0, failed: 0));

    final unsynced = await _recordings.getUnsynced();
    var completed = 0;
    var failed = 0;

    for (final recording in unsynced) {
      var attempt = 0;
      var ok = false;
      while (!ok) {
        attempt++;
        try {
          await _api.uploadRecording(File(recording.filePath));
          await _recordings.update(recording.copyWith(synced: true));
          ok = true;
        } catch (_) {
          if (attempt >= maxRetries) {
            failed++;
            ok = true;
          }
        }
      }
      completed++;
      state = AsyncValue.data(SyncState(
        isSyncing: true,
        total: unsynced.length,
        completed: completed,
        failed: failed,
      ));
    }

    ref.invalidate(customersControllerProvider);
    state = AsyncValue.data(SyncState(
      isSyncing: false,
      total: unsynced.length,
      completed: completed,
      failed: failed,
    ));
  }
}

