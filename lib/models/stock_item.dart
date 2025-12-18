import 'package:hive/hive.dart';

part 'stock_item.g.dart';

@HiveType(typeId: 0)
class StockItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final int quantity;
  
  @HiveField(4)
  final String unit;
  
  @HiveField(5)
  final DateTime lastUpdated;
  
  @HiveField(6)
  final String location;
  
  @HiveField(7)
  final int minStock;
  
  @HiveField(8)
  final String? description;
  
  @HiveField(9)
  final String? ownerId;

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
    this.ownerId,
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
    String? ownerId,
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
      ownerId: ownerId ?? this.ownerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'last_updated': lastUpdated.toIso8601String(),
      'location': location,
      'min_stock': minStock,
      'description': description,
      if (ownerId != null) 'owner_id': ownerId,
    };
  }

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      unit: json['unit'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      location: json['location'] as String,
      minStock: json['min_stock'] as int,
      description: json['description'] as String?,
      ownerId: json['owner_id'] as String?,
    );
  }
}
