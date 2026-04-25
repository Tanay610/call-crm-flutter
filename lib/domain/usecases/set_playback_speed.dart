import '../repositories/audio_session_repository.dart';

class SetPlaybackSpeed {
  SetPlaybackSpeed(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call(double speed) => _audio.setSpeed(speed);
}

