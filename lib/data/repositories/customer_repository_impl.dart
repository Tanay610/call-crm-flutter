import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../local/datasources/customer_local_datasource.dart';
import '../local/models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._local);

  final CustomerLocalDataSource _local;

  @override
  Future<List<Customer>> getAll() async {
    final models = await _local.getAll();
    final entities = models.map((e) => e.toEntity()).toList();
    entities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return entities;
  }

  @override
  Future<Customer?> getById(String id) async {
    return (await _local.getById(id))?.toEntity();
  }

  @override
  Future<void> upsert(Customer customer) async {
    await _local.upsert(CustomerModel.fromEntity(customer));
  }

  @override
  Future<void> deleteById(String id) => _local.deleteById(id);
}

