import '../entities/recording.dart';

abstract interface class RecordingRepository {
  Future<List<Recording>> getByCustomerId(String customerId);
  Future<List<Recording>> getUnsynced();
  Future<void> add(Recording recording);
  Future<void> update(Recording recording);
  Future<void> deleteById(String id);
  Future<void> deleteByCustomerId(String customerId);
}

