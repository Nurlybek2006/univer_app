// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'schedule_hive_model.dart';

class ScheduleHiveModelAdapter extends TypeAdapter<ScheduleHiveModel> {
  @override
  final int typeId = 1;

  @override
  ScheduleHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduleHiveModel(
      id: fields[0] as String,
      subject: fields[1] as String,
      teacher: fields[2] as String,
      room: fields[3] as String,
      startTime: fields[4] as String,
      endTime: fields[5] as String,
      dayOfWeek: fields[6] as int,
      groups: (fields[7] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ScheduleHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.teacher)
      ..writeByte(3)
      ..write(obj.room)
      ..writeByte(4)
      ..write(obj.startTime)
      ..writeByte(5)
      ..write(obj.endTime)
      ..writeByte(6)
      ..write(obj.dayOfWeek)
      ..writeByte(7)
      ..write(obj.groups);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
