import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/repositories/audio_session_repository.dart';

class AudioSessionRepositoryImpl implements AudioSessionRepository {
  AudioSessionRepositoryImpl(this._recorderController, this._player);

  final RecorderController _recorderController;
  final AudioPlayer _player;

  Stopwatch? _stopwatch;
  StreamSubscription<Duration>? _positionSub;
  String? _lastPath;

  RecorderController get recorderController => _recorderController;

  @override
  Future<void> startRecording({required String outputPath}) async {
    _lastPath = outputPath;
    _stopwatch = Stopwatch()..start();
    await _recorderController.record(
      path: outputPath,
    
    );
  }

  @override
  Future<void> pauseRecording() async {
    _stopwatch?.stop();
    await _recorderController.pause();
  }

  @override
  Future<void> resumeRecording() async {
    _stopwatch?.start();
    final path = _lastPath;
    if (path == null) throw StateError('No recording path available to resume.');
    await _recorderController.record(path: path);
  }

  @override
  Future<int> stopRecording() async {
    await _recorderController.stop();
    _stopwatch?.stop();
    final elapsed = _recorderController.recordedDuration.inMilliseconds;
    _stopwatch = null;
    _lastPath = null;
    return elapsed;
  }

  @override
  Future<void> play({required String filePath, double speed = 1.0}) async {
    await _player.setFilePath(filePath);
    await _player.setSpeed(speed);
    await _player.play();
  }

  @override
  Future<void> pausePlayback() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Stream<Duration> positionStream() => _player.positionStream;

  @override
  Stream<Duration?> durationStream() => _player.durationStream;

  @override
  Stream<bool> playingStream() => _player.playingStream;

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> dispose() async {
    await _positionSub?.cancel();
    _positionSub = null;
  }
  
 @override
Future<void> stopPlayback() async {
    await _player.stop();
}

@override
Future<void> resumePlayback() async {
    await _player.play();
}
}
