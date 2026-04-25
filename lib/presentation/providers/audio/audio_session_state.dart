enum RecordingStatus { idle, recording, paused }

class AudioSessionState {
  const AudioSessionState({
    required this.recordingStatus,
    required this.recordingElapsed,
    required this.playing,
    required this.position,
    required this.duration,
    required this.speed,
    this.currentFilePath,
  });

  final RecordingStatus recordingStatus;
  final Duration recordingElapsed;
  final bool playing;
  final Duration position;
  final Duration? duration;
  final double speed;
  final String? currentFilePath;

  AudioSessionState copyWith({
    RecordingStatus? recordingStatus,
    Duration? recordingElapsed,
    bool? playing,
    Duration? position,
    Duration? duration,
    double? speed,
    String? currentFilePath,
  }) {
    return AudioSessionState(
      recordingStatus: recordingStatus ?? this.recordingStatus,
      recordingElapsed: recordingElapsed ?? this.recordingElapsed,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      currentFilePath: currentFilePath ?? this.currentFilePath,
    );
  }

  static const initial = AudioSessionState(
    recordingStatus: RecordingStatus.idle,
    recordingElapsed: Duration.zero,
    playing: false,
    position: Duration.zero,
    duration: null,
    speed: 1.0,
    currentFilePath: null,
  );
}
