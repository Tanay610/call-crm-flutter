import '../repositories/recording_repository.dart';

class DeleteRecording {
  DeleteRecording(this._repo);

  final RecordingRepository _repo;

  Future<void> call(String recordingId) => _repo.deleteById(recordingId);
}

