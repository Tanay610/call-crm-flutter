// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recording_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecordingModelAdapter extends TypeAdapter<RecordingModel> {
  @override
  final int typeId = 1;

  @override
  RecordingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecordingModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      filePath: fields[2] as String,
      durationMillis: fields[3] as int,
      sizeBytes: fields[4] as int,
      recordedAtMillis: fields[5] as int,
      synced: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RecordingModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.durationMillis)
      ..writeByte(4)
      ..write(obj.sizeBytes)
      ..writeByte(5)
      ..write(obj.recordedAtMillis)
      ..writeByte(6)
      ..write(obj.synced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
