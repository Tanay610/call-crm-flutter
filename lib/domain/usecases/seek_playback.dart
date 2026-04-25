import '../repositories/audio_session_repository.dart';

class SeekPlayback {
  SeekPlayback(this._audio);

  final AudioSessionRepository _audio;

  Future<void> call(Duration position) => _audio.seek(position);
}

