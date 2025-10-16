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
}
