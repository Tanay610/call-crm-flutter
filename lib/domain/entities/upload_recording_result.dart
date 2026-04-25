import 'package:flutter/foundation.dart';

@immutable
class UploadRecordingResult {
  const UploadRecordingResult({required this.success, required this.recordingId});

  final bool success;
  final String recordingId;
}

