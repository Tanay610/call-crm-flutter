import 'package:hive/hive.dart';

import '../../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    this.avatarPath,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String email;

  @HiveField(4)
  String company;

  @HiveField(5)
  String? avatarPath;

  @HiveField(6)
  int createdAtMillis;

  @HiveField(7)
  int updatedAtMillis;

  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      email: email,
      company: company,
      avatarPath: avatarPath,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMillis),
    );
  }

  static CustomerModel fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      company: entity.company,
      avatarPath: entity.avatarPath,
      createdAtMillis: entity.createdAt.millisecondsSinceEpoch,
      updatedAtMillis: entity.updatedAt.millisecondsSinceEpoch,
    );
  }
}

