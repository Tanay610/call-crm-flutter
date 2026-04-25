import 'package:hive/hive.dart';

import '../../../domain/entities/recording.dart';

part 'recording_model.g.dart';

@HiveType(typeId: 1)
class RecordingModel extends HiveObject {
  RecordingModel({
    required this.id,
    required this.customerId,
    required this.filePath,
    required this.durationMillis,
    required this.sizeBytes,
    required this.recordedAtMillis,
    required this.synced,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String customerId;

  @HiveField(2)
  String filePath;

  @HiveField(3)
  int durationMillis;

  @HiveField(4)
  int sizeBytes;

  @HiveField(5)
  int recordedAtMillis;

  @HiveField(6)
  bool synced;

  Recording toEntity() {
    return Recording(
      id: id,
      customerId: customerId,
      filePath: filePath,
      durationMillis: durationMillis,
      sizeBytes: sizeBytes,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(recordedAtMillis),
      synced: synced,
    );
  }

  static RecordingModel fromEntity(Recording entity) {
    return RecordingModel(
      id: entity.id,
      customerId: entity.customerId,
      filePath: entity.filePath,
      durationMillis: entity.durationMillis,
      sizeBytes: entity.sizeBytes,
      recordedAtMillis: entity.recordedAt.millisecondsSinceEpoch,
      synced: entity.synced,
    );
  }
}

