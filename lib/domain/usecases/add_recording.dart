import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class AddRecording {
  AddRecording(this._repo);

  final RecordingRepository _repo;

  Future<void> call(Recording recording) => _repo.add(recording);
}

