enum TransactionType { incoming, outgoing }

class StockTransaction {
  final String id;
  final String itemId;
  final String itemName;
  final TransactionType type;
  final int quantity;
  final DateTime date;
  final String? note;
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
