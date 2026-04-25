import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/entities/recording.dart';
import '../../../domain/usecases/get_recordings_for_customer.dart';
import '../customers/customers_controller.dart';
import 'recordings_state.dart';

final recordingsControllerProvider =
    AsyncNotifierProvider.family<RecordingsController, RecordingsState, String>(
  (String customerId) => RecordingsController( customerId),
);

class RecordingsController extends AsyncNotifier<RecordingsState> {
  final _uuid = const Uuid();
   final String customerId;

  RecordingsController(this.customerId);
  

  @override
  Future<RecordingsState> build() async {
    final recordingsRepo = ref.read(recordingRepositoryProvider);
    final recordings = await GetRecordingsForCustomer(recordingsRepo)(customerId);
    return RecordingsState(recordings: recordings);
  }

  Future<void> refresh(String customerId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<({String recordingId, String filePath})> allocateRecordingPath({
    required String customerId,
  }) async {
    final files = ref.read(fileStorageProvider);
    final recordingId = _uuid.v4();
    final filePath = await files.buildRecordingPath(customerId: customerId, recordingId: recordingId);
    return (recordingId: recordingId, filePath: filePath);
  }

  Future<void> persistRecording({
    required Customer customer,
    required String recordingId,
    required String filePath,
    required int durationMillis,
  }) async {
    final file = File(filePath);
    final exists = await file.exists();
    if (!exists) {
      throw StateError('Recording file does not exist.');
    }

    final now = DateTime.now();
    final size = await file.length();
    final recording = Recording(
      id: recordingId,
      customerId: customer.id,
      filePath: filePath,
      durationMillis: durationMillis,
      sizeBytes: size,
      recordedAt: now,
      synced: false,
    );
    await ref.read(recordingRepositoryProvider).add(recording);
    await ref.read(customerRepositoryProvider).upsert(customer.copyWith(updatedAt: now));
    await refresh(customer.id);
    ref.invalidate(customersControllerProvider);
  }

  Future<void> deleteRecording({required String customerId, required String recordingId}) async {
    await ref.read(recordingRepositoryProvider).deleteById(recordingId);
    await refresh(customerId);
    ref.invalidate(customersControllerProvider);
  }
}
