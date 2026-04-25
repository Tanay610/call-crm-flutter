import 'package:call_crm_app/domain/entities/customer.dart';
import 'package:call_crm_app/domain/entities/recording.dart';
import 'package:call_crm_app/domain/repositories/customer_repository.dart';
import 'package:call_crm_app/domain/repositories/recording_repository.dart';

class FakeCustomerRepository implements CustomerRepository {
  FakeCustomerRepository({List<Customer>? seed}) : _customers = seed ?? [];

  final List<Customer> _customers;

  @override
  Future<List<Customer>> getAll() async => List<Customer>.unmodifiable(_customers);

  @override
  Future<Customer?> getById(String id) async {
    for (final c in _customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  Future<void> upsert(Customer customer) async {
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx == -1) {
      _customers.add(customer);
    } else {
      _customers[idx] = customer;
    }
  }

  @override
  Future<void> deleteById(String id) async {
    _customers.removeWhere((c) => c.id == id);
  }
}

class FakeRecordingRepository implements RecordingRepository {
  FakeRecordingRepository({List<Recording>? seed}) : _recordings = seed ?? [];

  final List<Recording> _recordings;

  bool deleteByCustomerCalled = false;
  String? deletedCustomerId;

  @override
  Future<void> add(Recording recording) async {
    _recordings.add(recording);
  }

  @override
  Future<void> deleteByCustomerId(String customerId) async {
    deleteByCustomerCalled = true;
    deletedCustomerId = customerId;
    _recordings.removeWhere((r) => r.customerId == customerId);
  }

  @override
  Future<void> deleteById(String id) async {
    _recordings.removeWhere((r) => r.id == id);
  }

  @override
  Future<List<Recording>> getByCustomerId(String customerId) async {
    final list = _recordings.where((r) => r.customerId == customerId).toList();
    list.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return list;
  }

  @override
  Future<List<Recording>> getUnsynced() async => _recordings.where((r) => !r.synced).toList();

  @override
  Future<void> update(Recording recording) async {
    final idx = _recordings.indexWhere((r) => r.id == recording.id);
    if (idx == -1) return;
    _recordings[idx] = recording;
  }
}
