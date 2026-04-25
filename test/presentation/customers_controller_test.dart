import 'package:call_crm_app/core/di/providers.dart';
import 'package:call_crm_app/domain/entities/customer.dart';
import 'package:call_crm_app/domain/entities/recording.dart';
import 'package:call_crm_app/presentation/providers/customers/customers_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

void main() {
  test('CustomersController sorts and searches customers', () async {
    final now = DateTime(2026, 4, 24, 10);
    final repo = FakeCustomerRepository(
      seed: [
        Customer(
          id: 'c1',
          name: 'Bob',
          phone: '222',
          email: 'b@example.com',
          company: 'Beta',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 1)),
        ),
        Customer(
          id: 'c2',
          name: 'Alice',
          phone: '111',
          email: 'a@example.com',
          company: 'Acme',
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        ),
      ],
    );
    final recRepo = FakeRecordingRepository(
      seed: [
        Recording(
          id: 'r1',
          customerId: 'c2',
          filePath: '/tmp/r1.m4a',
          durationMillis: 1000,
          sizeBytes: 10,
          recordedAt: now,
          synced: false,
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        customerRepositoryProvider.overrideWithValue(repo),
        recordingRepositoryProvider.overrideWithValue(recRepo),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(customersControllerProvider.future);
    expect(initial.customers.first.id, 'c2'); // latest updatedAt first

    await container.read(customersControllerProvider.notifier).setQuery('bob');
    final afterSearch = await container.read(customersControllerProvider.future);
    expect(afterSearch.customers.length, 1);
    expect(afterSearch.customers.single.id, 'c1');
  });
}

