import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/usecases/add_customer.dart';
import '../../../domain/usecases/delete_customer.dart';
import '../../../domain/usecases/get_customers.dart';
import '../../../domain/usecases/get_recordings_for_customer.dart';
import '../../../domain/usecases/update_customer.dart';
import 'customers_state.dart';

final customersControllerProvider =
    AsyncNotifierProvider<CustomersController, CustomersState>(CustomersController.new);

class CustomersController extends AsyncNotifier<CustomersState> {
  final _uuid = const Uuid();

  String _query = '';
  CustomerSort _sort = CustomerSort.lastCalled;

  @override
  Future<CustomersState> build() async {
    final customersRepo = ref.read(customerRepositoryProvider);
    final customers = await GetCustomers(customersRepo)();
    final stats = await _loadStats(customers);
    final sorted = _applySort(customers, stats);
    return CustomersState(
      customers: _applyQuery(sorted),
      query: _query,
      sort: _sort,
      statsByCustomerId: stats,
    );
  }

  Future<Map<String, CustomerStats>> _loadStats(List<Customer> customers) async {
    final recordingsRepo = ref.read(recordingRepositoryProvider);
    final getRecordings = GetRecordingsForCustomer(recordingsRepo);
    final result = <String, CustomerStats>{};
    for (final c in customers) {
      final recordings = await getRecordings(c.id);
      final last = recordings.isEmpty ? null : recordings.first.recordedAt;
      result[c.id] = CustomerStats(recordingCount: recordings.length, lastRecordedAt: last);
    }
    return result;
  }

  List<Customer> _applyQuery(List<Customer> customers) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return customers;
    return customers
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              c.company.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  List<Customer> _applySort(List<Customer> customers, Map<String, CustomerStats> stats) {
    final copy = customers.toList();
    switch (_sort) {
      case CustomerSort.lastCalled:
        copy.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case CustomerSort.newest:
        copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case CustomerSort.mostRecorded:
        copy.sort((a, b) {
          final ac = stats[a.id]?.recordingCount ?? 0;
          final bc = stats[b.id]?.recordingCount ?? 0;
          return bc.compareTo(ac);
        });
    }
    return copy;
  }

  Future<void> setQuery(String query) async {
    _query = query;
    await refresh();
  }

  Future<void> setSort(CustomerSort sort) async {
    _sort = sort;
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(build);
  }

  Future<void> add({
    required String name,
    required String phone,
    required String email,
    required String company,
    String? avatarPath,
  }) async {
    final now = DateTime.now();
    final customer = Customer(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      company: company,
      avatarPath: avatarPath,
      createdAt: now,
      updatedAt: now,
    );
    await AddCustomer(ref.read(customerRepositoryProvider))(customer);
    await refresh();
  }

  Future<void> updateCustomer(Customer updated) async {
    await UpdateCustomer(ref.read(customerRepositoryProvider))(updated);
    await refresh();
  }

  Future<void> delete(String customerId) async {
    await DeleteCustomer(
      ref.read(customerRepositoryProvider),
      ref.read(recordingRepositoryProvider),
    )(customerId);
    await refresh();
  }
}
