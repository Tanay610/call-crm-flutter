import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class GetRecordingsForCustomer {
  GetRecordingsForCustomer(this._repo);

  final RecordingRepository _repo;

  Future<List<Recording>> call(String customerId) => _repo.getByCustomerId(customerId);
}

