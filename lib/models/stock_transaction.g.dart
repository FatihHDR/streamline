// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StockTransactionAdapter extends TypeAdapter<StockTransaction> {
  @override
  final int typeId = 2;

  @override
  StockTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StockTransaction(
      id: fields[0] as String,
      itemId: fields[1] as String,
      itemName: fields[2] as String,
      type: fields[3] as TransactionType,
      quantity: fields[4] as int,
      date: fields[5] as DateTime,
      note: fields[6] as String?,
      performedBy: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StockTransaction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemId)
      ..writeByte(2)
      ..write(obj.itemName)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.performedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 1;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.incoming;
      case 1:
        return TransactionType.outgoing;
      default:
        return TransactionType.incoming;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.incoming:
        writer.writeByte(0);
        break;
      case TransactionType.outgoing:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
