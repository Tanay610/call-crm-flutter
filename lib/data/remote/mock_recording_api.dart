import 'dart:io';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../domain/entities/upload_recording_result.dart';
import '../../domain/repositories/recording_api.dart';

class MockRecordingApi implements RecordingApi {
  MockRecordingApi({Random? random, Uuid? uuid})
      : _random = random ?? Random(),
        _uuid = uuid ?? const Uuid();

  final Random _random;
  final Uuid _uuid;

  @override
  Future<UploadRecordingResult> uploadRecording(File file) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    final fail = _random.nextDouble() < 0.10;
    if (fail) {
      throw const MockNetworkException('Random mock network failure (10%).');
    }
    return UploadRecordingResult(success: true, recordingId: _uuid.v4());
  }

  @override
  Future<List<UploadRecordingResult>> syncRecordings() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return const <UploadRecordingResult>[];
  }
}

class MockNetworkException implements Exception {
  const MockNetworkException(this.message);
  final String message;

  @override
  String toString() => 'MockNetworkException: $message';
}

