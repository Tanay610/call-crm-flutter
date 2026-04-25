import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomer {
  UpdateCustomer(this._repo);

  final CustomerRepository _repo;

  Future<void> call(Customer customer) => _repo.upsert(customer);
}

