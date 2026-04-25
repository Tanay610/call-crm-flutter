import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers {
  GetCustomers(this._repo);

  final CustomerRepository _repo;

  Future<List<Customer>> call() => _repo.getAll();
}

