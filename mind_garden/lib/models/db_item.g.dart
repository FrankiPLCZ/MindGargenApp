// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DbItemAdapter extends TypeAdapter<DbItem> {
  @override
  final int typeId = 1;

  @override
  DbItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DbItem(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAtMs: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DbItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DbItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
