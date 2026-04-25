import 'dart:io';

import '../entities/upload_recording_result.dart';

abstract interface class RecordingApi {
  Future<UploadRecordingResult> uploadRecording(File file);
  Future<List<UploadRecordingResult>> syncRecordings();
}
