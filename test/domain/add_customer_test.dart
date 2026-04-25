import 'package:call_crm_app/domain/entities/customer.dart';
import 'package:call_crm_app/domain/usecases/add_customer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_repositories.dart';

void main() {
  test('AddCustomer upserts into repository', () async {
    final repo = FakeCustomerRepository();
    final usecase = AddCustomer(repo);

    final now = DateTime(2026, 4, 24);
    final customer = Customer(
      id: 'c1',
      name: 'Alice',
      phone: '123',
      email: 'a@example.com',
      company: 'Acme',
      createdAt: now,
      updatedAt: now,
    );

    await usecase(customer);
    final all = await repo.getAll();
    expect(all.length, 1);
    expect(all.first.id, 'c1');
  });
}

