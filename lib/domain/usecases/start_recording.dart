import '../repositories/audio_session_repository.dart';

class StartRecording {
  StartRecording(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call({required String outputPath}) => _audio.startRecording(outputPath: outputPath);
}

