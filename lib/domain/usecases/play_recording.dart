import '../repositories/audio_session_repository.dart';

class PlayRecording {
  PlayRecording(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call({required String filePath, double speed = 1.0}) =>
      _audio.play(filePath: filePath, speed: speed);
}

