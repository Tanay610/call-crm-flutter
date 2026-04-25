import '../repositories/customer_repository.dart';
import '../repositories/recording_repository.dart';

class DeleteCustomer {
  DeleteCustomer(this._customers, this._recordings);

  final CustomerRepository _customers;
  final RecordingRepository _recordings;

  Future<void> call(String customerId) async {
    await _recordings.deleteByCustomerId(customerId);
    await _customers.deleteById(customerId);
  }
}

