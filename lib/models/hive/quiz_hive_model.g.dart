// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

part of 'quiz_hive_model.dart';

class QuizQuestionHiveModelAdapter extends TypeAdapter<QuizQuestionHiveModel> {
  @override
  final int typeId = 3;

  @override
  QuizQuestionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizQuestionHiveModel(
      question: fields[0] as String,
      options: (fields[1] as List).cast<String>(),
      correctIndex: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuizQuestionHiveModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.options)
      ..writeByte(2)
      ..write(obj.correctIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuizCategoryHiveModelAdapter
    extends TypeAdapter<QuizCategoryHiveModel> {
  @override
  final int typeId = 4;

  @override
  QuizCategoryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizCategoryHiveModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      questions: (fields[3] as List).cast<QuizQuestionHiveModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, QuizCategoryHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.questions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizCategoryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
