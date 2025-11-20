import 'package:hive/hive.dart';

part 'stock_transaction.g.dart';

@HiveType(typeId: 1)
enum TransactionType {
  @HiveField(0)
  incoming,
  
  @HiveField(1)
  outgoing
}

@HiveType(typeId: 2)
class StockTransaction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String itemId;
  
  @HiveField(2)
  final String itemName;
  
  @HiveField(3)
  final TransactionType type;
  
  @HiveField(4)
  final int quantity;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final String? note;
  
  @HiveField(7)
  final String? performedBy;

  StockTransaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.date,
    this.note,
    this.performedBy,
  });

  String get typeLabel => type == TransactionType.incoming ? 'Masuk' : 'Keluar';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'item_name_snapshot': itemName,
      'transaction_type': type == TransactionType.incoming ? 'incoming' : 'outgoing',
      'quantity': quantity,
      'occurred_at': date.toIso8601String(),
      'note': note,
      'performed_by': performedBy,
    };
  }

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      itemName: json['item_name_snapshot'] as String,
      type: json['transaction_type'] == 'incoming'
          ? TransactionType.incoming
          : TransactionType.outgoing,
      quantity: json['quantity'] as int,
      date: DateTime.parse(json['occurred_at'] as String),
      note: json['note'] as String?,
      performedBy: json['performed_by'] as String?,
    );
  }
}
