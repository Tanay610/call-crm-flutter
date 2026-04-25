import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../local/datasources/recording_local_datasource.dart';
import '../local/file_storage.dart';
import '../local/models/recording_model.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  RecordingRepositoryImpl(this._local, this._fileStorage);

  final RecordingLocalDataSource _local;
  final FileStorage _fileStorage;

  @override
  Future<void> add(Recording recording) => _local.add(RecordingModel.fromEntity(recording));

  @override
  Future<List<Recording>> getByCustomerId(String customerId) async {
    final models = await _local.getByCustomerId(customerId);
    final entities = models.map((e) => e.toEntity()).toList();
    entities.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return entities;
  }

  @override
  Future<List<Recording>> getUnsynced() async {
    final models = await _local.getUnsynced();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> update(Recording recording) => _local.update(RecordingModel.fromEntity(recording));

  @override
  Future<void> deleteById(String id) async {
    final model = await _local.getById(id);
    if (model != null) {
      await _fileStorage.deleteFileIfExists(model.filePath);
    }
    await _local.deleteById(id);
  }

  @override
  Future<void> deleteByCustomerId(String customerId) async {
    final recordings = await _local.getByCustomerId(customerId);
    for (final r in recordings) {
      await _fileStorage.deleteFileIfExists(r.filePath);
    }
    await _local.deleteByCustomerId(customerId);
    await _fileStorage.deleteCustomerDirectoryIfExists(customerId);
  }
}
