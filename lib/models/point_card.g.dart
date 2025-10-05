// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PointCardAdapter extends TypeAdapter<PointCard> {
  @override
  final int typeId = 0;

  @override
  PointCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PointCard(
      id: fields[0] as String,
      name: fields[1] as String,
      barcode: fields[2] as String?,
      notes: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
      order: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PointCard obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
