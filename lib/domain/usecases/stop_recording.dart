import '../repositories/audio_session_repository.dart';

class StopRecording {
  StopRecording(this._audio);

  final AudioSessionRepository _audio;

  Future<int> call() => _audio.stopRecording();
}

