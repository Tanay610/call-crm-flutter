import '../repositories/audio_session_repository.dart';

class ResumeRecording {
  ResumeRecording(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call() => _audio.resumeRecording();
}

