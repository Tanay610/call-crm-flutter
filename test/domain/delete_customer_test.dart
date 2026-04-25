import 'package:call_crm_app/domain/entities/customer.dart';
import 'package:call_crm_app/domain/entities/recording.dart';
import 'package:call_crm_app/domain/usecases/delete_customer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

void main() {
  test('DeleteCustomer cascades recordings then deletes customer', () async {
    final now = DateTime(2026, 4, 24);
    final customers = FakeCustomerRepository(
      seed: [
        Customer(
          id: 'c1',
          name: 'Alice',
          phone: '123',
          email: 'a@example.com',
          company: 'Acme',
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    final recordings = FakeRecordingRepository(
      seed: [
        Recording(
          id: 'r1',
          customerId: 'c1',
          filePath: '/tmp/r1.m4a',
          durationMillis: 1000,
          sizeBytes: 10,
          recordedAt: now,
          synced: false,
        ),
      ],
    );

    final usecase = DeleteCustomer(customers, recordings);
    await usecase('c1');

    expect(recordings.deleteByCustomerCalled, true);
    expect(recordings.deletedCustomerId, 'c1');
    expect((await customers.getAll()).isEmpty, true);
    expect((await recordings.getByCustomerId('c1')).isEmpty, true);
  });
}

