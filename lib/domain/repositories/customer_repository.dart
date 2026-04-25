import '../entities/customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> getAll();
  Future<Customer?> getById(String id);
  Future<void> upsert(Customer customer);
  Future<void> deleteById(String id);
}

