// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'user_hive_model.dart';

class UserHiveModelAdapter extends TypeAdapter<UserHiveModel> {
  @override
  final int typeId = 0;

  @override
  UserHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHiveModel(
      uid: fields[0] as String,
      email: fields[1] as String,
      fullName: fields[2] as String,
      group: fields[3] as String,
      faculty: fields[4] as String,
      course: fields[5] as int,
      studentId: fields[6] as String,
      phone: fields[7] as String,
      role: fields[8] as String,
      photoUrl: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.group)
      ..writeByte(4)
      ..write(obj.faculty)
      ..writeByte(5)
      ..write(obj.course)
      ..writeByte(6)
      ..write(obj.studentId)
      ..writeByte(7)
      ..write(obj.phone)
      ..writeByte(8)
      ..write(obj.role)
      ..writeByte(9)
      ..write(obj.photoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
