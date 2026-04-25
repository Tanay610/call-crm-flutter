import '../repositories/audio_session_repository.dart';

class PauseRecording {
  PauseRecording(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call() => _audio.pauseRecording();
}

