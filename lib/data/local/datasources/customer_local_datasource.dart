import '../hive_boxes.dart';
import '../models/customer_model.dart';

class CustomerLocalDataSource {
  Future<List<CustomerModel>> getAll() async {
    final box = HiveBoxes.customers();
    return box.values.toList(growable: false);
  }

  Future<CustomerModel?> getById(String id) async {
    return HiveBoxes.customers().get(id);
  }

  Future<void> upsert(CustomerModel model) async {
    await HiveBoxes.customers().put(model.id, model);
  }

  Future<void> deleteById(String id) async {
    await HiveBoxes.customers().delete(id);
  }
}

