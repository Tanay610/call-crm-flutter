import 'dart:io';

import '../repositories/recording_api.dart';
import '../repositories/recording_repository.dart';

class SyncUnsyncedRecordings {
  SyncUnsyncedRecordings(this._recordings, this._api);

  final RecordingRepository _recordings;
  final RecordingApi _api;

  Future<int> call({int maxRetries = 2}) async {
    final unsynced = await _recordings.getUnsynced();
    var successCount = 0;
    for (final recording in unsynced) {
      var attempt = 0;
      while (true) {
        attempt++;
        try {
          await _api.uploadRecording(File(recording.filePath));
          await _recordings.update(recording.copyWith(synced: true));
          successCount++;
          break;
        } catch (_) {
          if (attempt >= maxRetries) rethrow;
          await Future<void>.delayed(const Duration(milliseconds: 350));
        }
      }
    }
    return successCount;
  }
}
