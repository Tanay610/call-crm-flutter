import '../hive_boxes.dart';
import '../models/recording_model.dart';

class RecordingLocalDataSource {
  Future<RecordingModel?> getById(String id) async {
    return HiveBoxes.recordings().get(id);
  }

  Future<List<RecordingModel>> getByCustomerId(String customerId) async {
    return HiveBoxes
        .recordings()
        .values
        .where((r) => r.customerId == customerId)
        .toList(growable: false);
  }

  Future<List<RecordingModel>> getUnsynced() async {
    return HiveBoxes.recordings().values.where((r) => !r.synced).toList(growable: false);
  }

  Future<void> add(RecordingModel model) async {
    await HiveBoxes.recordings().put(model.id, model);
  }

  Future<void> update(RecordingModel model) async {
    await HiveBoxes.recordings().put(model.id, model);
  }

  Future<void> deleteById(String id) async {
    await HiveBoxes.recordings().delete(id);
  }

  Future<void> deleteByCustomerId(String customerId) async {
    final box = HiveBoxes.recordings();
    final toDelete = box.values.where((r) => r.customerId == customerId).map((e) => e.id).toList();
    await box.deleteAll(toDelete);
  }
}
