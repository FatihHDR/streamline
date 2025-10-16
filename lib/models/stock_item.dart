class StockItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final String unit;
  final DateTime lastUpdated;
  final String location;
  final int minStock;
  final String? description;

  StockItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.lastUpdated,
    required this.location,
    this.minStock = 10,
    this.description,
  });

  bool get isLowStock => quantity <= minStock;
  bool get isOutOfStock => quantity <= 0;

  StockItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    String? unit,
    DateTime? lastUpdated,
    String? location,
    int? minStock,
    String? description,
  }) {
    return StockItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      location: location ?? this.location,
      minStock: minStock ?? this.minStock,
      description: description ?? this.description,
    );
  }
}
