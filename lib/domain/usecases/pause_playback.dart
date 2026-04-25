import '../repositories/audio_session_repository.dart';

class PausePlayback {
  PausePlayback(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call() => _audio.pausePlayback();
}

