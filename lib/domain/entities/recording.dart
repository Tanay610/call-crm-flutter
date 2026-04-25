import 'package:flutter/foundation.dart';

@immutable
class Recording {
  const Recording({
    required this.id,
    required this.customerId,
    required this.filePath,
    required this.durationMillis,
    required this.sizeBytes,
    required this.recordedAt,
    required this.synced,
  });

  final String id;
  final String customerId;
  final String filePath;
  final int durationMillis;
  final int sizeBytes;
  final DateTime recordedAt;
  final bool synced;

  Recording copyWith({
    String? id,
    String? customerId,
    String? filePath,
    int? durationMillis,
    int? sizeBytes,
    DateTime? recordedAt,
    bool? synced,
  }) {
    return Recording(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      filePath: filePath ?? this.filePath,
      durationMillis: durationMillis ?? this.durationMillis,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      recordedAt: recordedAt ?? this.recordedAt,
      synced: synced ?? this.synced,
    );
  }
}

