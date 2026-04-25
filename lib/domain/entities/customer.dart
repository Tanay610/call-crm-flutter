import 'package:flutter/foundation.dart';

@immutable
class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.createdAt,
    required this.updatedAt,
    this.avatarPath,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String? avatarPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? company,
    String? avatarPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      avatarPath: avatarPath ?? this.avatarPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

