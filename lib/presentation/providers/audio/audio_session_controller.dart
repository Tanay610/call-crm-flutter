import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/repositories/audio_session_repository.dart';
import 'audio_session_state.dart';

final audioSessionControllerProvider =
    NotifierProvider<AudioSessionController, AudioSessionState>(AudioSessionController.new);

class AudioSessionController extends Notifier<AudioSessionState> {
  late final AudioSessionRepository _audio;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  StreamSubscription<bool>? _playingSub;
  Timer? _recordingTimer;
  Stopwatch? _recordingStopwatch;

  @override
  AudioSessionState build() {
    _audio = ref.read(audioSessionRepositoryProvider);

    _posSub = _audio.positionStream().listen((pos) {
      state = state.copyWith(position: pos);
    });
    _durSub = _audio.durationStream().listen((dur) {
      state = state.copyWith(duration: dur);
    });
    _playingSub = _audio.playingStream().listen((playing) {
      state = state.copyWith(playing: playing);
    });

    ref.onDispose(() async {
      _recordingTimer?.cancel();
      await _posSub?.cancel();
      await _durSub?.cancel();
      await _playingSub?.cancel();
      await _audio.dispose();
    });

    return AudioSessionState.initial;
  }

  Future<void> startRecording(String outputPath) async {
    await _audio.startRecording(outputPath: outputPath);
    _recordingStopwatch = Stopwatch()..start();
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      final elapsed = _recordingStopwatch?.elapsed ?? Duration.zero;
      state = state.copyWith(recordingElapsed: elapsed);
    });
    state = state.copyWith(recordingStatus: RecordingStatus.recording);
  }

  Future<void> pauseRecording() async {
    await _audio.pauseRecording();
    _recordingStopwatch?.stop();
    state = state.copyWith(recordingStatus: RecordingStatus.paused);
  }

  Future<void> resumeRecording() async {
    await _audio.resumeRecording();
    _recordingStopwatch?.start();
    state = state.copyWith(recordingStatus: RecordingStatus.recording);
  }

  Future<int> stopRecording() async {
    final durationMillis = await _audio.stopRecording();
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _recordingStopwatch?.stop();
    _recordingStopwatch = null;
    state = state.copyWith(recordingStatus: RecordingStatus.idle, recordingElapsed: Duration.zero);
    return durationMillis;
  }

  Future<void> play(String filePath) async {
    if (state.currentFilePath == filePath && !state.playing) {
    // If at the end, restart from beginning
    if (state.duration != null && state.position >= state.duration! && state.duration! > Duration.zero) {
      await seek(Duration.zero);
    }
    await _audio.resumePlayback();
    state = state.copyWith(playing: true);
    return;
  }

     if (state.playing) {
      await _audio.stopPlayback(); 
    }
  
  state = state.copyWith(
    playing: false,
    position: Duration.zero,
    currentFilePath: filePath,  // Set this BEFORE playing
  );
  
  await _audio.play(filePath: filePath, speed: state.speed);
  
  state = state.copyWith(playing: true);
}

  Future<void> pausePlayback()async{
    await _audio.pausePlayback();
    state = state.copyWith(playing: false);
  }

  Future<void> seek(Duration position) => _audio.seek(position);

  Future<void> setSpeed(double speed) async {
    await _audio.setSpeed(speed);
    state = state.copyWith(speed: speed);
  }
}
