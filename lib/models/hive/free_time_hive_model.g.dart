// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'free_time_hive_model.dart';

class FreeTimeHiveModelAdapter extends TypeAdapter<FreeTimeHiveModel> {
  @override
  final int typeId = 5;

  @override
  FreeTimeHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FreeTimeHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      iconName: fields[3] as String,
      level: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FreeTimeHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconName)
      ..writeByte(4)
      ..write(obj.level);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreeTimeHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
