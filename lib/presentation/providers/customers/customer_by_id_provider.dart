import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/customer.dart';

final customerByIdProvider = FutureProvider.family<Customer?, String>((ref, id) async {
  final repo = ref.read(customerRepositoryProvider);
  return repo.getById(id);
});

