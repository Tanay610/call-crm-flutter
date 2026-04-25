import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

import '../../data/audio/audio_session_repository_impl.dart';
import '../../data/local/datasources/customer_local_datasource.dart';
import '../../data/local/datasources/recording_local_datasource.dart';
import '../../data/local/file_storage.dart';
import '../../data/remote/mock_recording_api.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/recording_repository_impl.dart';
import '../../domain/repositories/audio_session_repository.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/recording_api.dart';
import '../../domain/repositories/recording_repository.dart';

final loggerProvider = Provider<Logger>((ref) => Logger());

final fileStorageProvider = Provider<FileStorage>((ref) => FileStorage());

final customerLocalDataSourceProvider =
    Provider<CustomerLocalDataSource>((ref) => CustomerLocalDataSource());

final recordingLocalDataSourceProvider =
    Provider<RecordingLocalDataSource>((ref) => RecordingLocalDataSource());

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.read(customerLocalDataSourceProvider));
});

final recordingRepositoryProvider = Provider<RecordingRepository>((ref) {
  return RecordingRepositoryImpl(
    ref.read(recordingLocalDataSourceProvider),
    ref.read(fileStorageProvider),
  );
});

final recordingApiProvider = Provider<RecordingApi>((ref) => MockRecordingApi());

final recorderControllerProvider = Provider<RecorderController>((ref) {
  final controller = RecorderController();
  ref.onDispose(controller.dispose);
  return controller;
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

final audioSessionRepositoryProvider = Provider<AudioSessionRepository>((ref) {
  return AudioSessionRepositoryImpl(
    ref.read(recorderControllerProvider),
    ref.read(audioPlayerProvider),
  );
});

