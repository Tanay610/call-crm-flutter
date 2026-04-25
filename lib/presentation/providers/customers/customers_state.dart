import '../../../domain/entities/customer.dart';

enum CustomerSort { lastCalled, mostRecorded, newest }

class CustomerStats {
  const CustomerStats({required this.recordingCount, this.lastRecordedAt});
  final int recordingCount;
  final DateTime? lastRecordedAt;
}

class CustomersState {
  const CustomersState({
    required this.customers,
    required this.query,
    required this.sort,
    required this.statsByCustomerId,
  });

  final List<Customer> customers;
  final String query;
  final CustomerSort sort;
  final Map<String, CustomerStats> statsByCustomerId;

  CustomersState copyWith({
    List<Customer>? customers,
    String? query,
    CustomerSort? sort,
    Map<String, CustomerStats>? statsByCustomerId,
  }) {
    return CustomersState(
      customers: customers ?? this.customers,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      statsByCustomerId: statsByCustomerId ?? this.statsByCustomerId,
    );
  }
}

