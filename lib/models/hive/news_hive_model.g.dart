// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'news_hive_model.dart';

class NewsHiveModelAdapter extends TypeAdapter<NewsHiveModel> {
  @override
  final int typeId = 2;

  @override
  NewsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NewsHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String?,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NewsHiveModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
