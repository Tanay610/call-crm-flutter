abstract interface class AudioSessionRepository {
  Future<void> startRecording({required String outputPath});
  Future<void> pauseRecording();
  Future<void> resumeRecording();
  Future<void> resumePlayback();
  Future<int> stopRecording();
  Future<void> stopPlayback();

  Future<void> play({required String filePath, double speed = 1.0});
  Future<void> pausePlayback();
  Future<void> seek(Duration position);
  Stream<Duration> positionStream();
  Stream<Duration?> durationStream();
  Stream<bool> playingStream();
  Future<void> setSpeed(double speed);
  Future<void> dispose();
}

