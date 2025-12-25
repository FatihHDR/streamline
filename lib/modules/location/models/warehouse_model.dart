import 'package:hive/hive.dart';

part 'warehouse_model.g.dart';

@HiveType(typeId: 20)
class Warehouse {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String location;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final double sizeInSquareMeter;

  @HiveField(6)
  final int totalSlots;

  @HiveField(7)
  final int occupiedSlots;

  @HiveField(8)
  final String description;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  final String city;

  @HiveField(11)
  final String province;

  Warehouse({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.sizeInSquareMeter,
    required this.totalSlots,
    required this.occupiedSlots,
    required this.description,
    required this.city,
    required this.province,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getters untuk informasi bermanfaat
  double get occupancyPercentage => (occupiedSlots / totalSlots) * 100;
  int get availableSlots => totalSlots - occupiedSlots;
  double get availableArea => sizeInSquareMeter * (availableSlots / totalSlots);
  bool get isNearCapacity => occupancyPercentage >= 80;
  bool get isFull => occupiedSlots >= totalSlots;

  // Convert koordinat string ke double (dari format Google Maps)
  static double convertCoordinateStringToDouble(String coord) {
    // Format: 7°54'48.6"S 112°37'32.6"E
    // Kita bisa parse ini dengan regex
    final parts = coord.split(' ');
    if (parts.length < 1) return 0.0;

    final firstPart = parts[0];
    final secondPart = parts.length > 1 ? parts[1] : '';

    double latitude = _parseCoordinate(firstPart, ['S', 's']);
    _parseCoordinate(secondPart, ['E', 'e', 'W', 'w']);

    return latitude; // Return latitude atau keduanya sesuai kebutuhan
  }

  static double _parseCoordinate(String coord, List<String> directions) {
    try {
      // Hapus karakter derajat, menit, detik
      String cleaned = coord.replaceAll('°', ' ')
          .replaceAll('\'', ' ')
          .replaceAll('"', ' ')
          .replaceAll('N', '')
          .replaceAll('S', '')
          .replaceAll('E', '')
          .replaceAll('W', '')
          .replaceAll('n', '')
          .replaceAll('s', '')
          .replaceAll('e', '')
          .replaceAll('w', '')
          .trim();
      
      List<String> parts = cleaned.split(RegExp(r'\s+'));

      if (parts.length >= 3) {
        double degrees = double.parse(parts[0]);
        double minutes = double.parse(parts[1]);
        double seconds = double.parse(parts[2]);

        double result = degrees + (minutes / 60) + (seconds / 3600);

        // Check for negative direction
        bool isNegative = false;
        for (String direction in directions) {
          if (coord.contains(direction)) {
            if (direction.toLowerCase() == 's' || direction.toLowerCase() == 'w') {
              isNegative = true;
            }
            break;
          }
        }

        return isNegative ? -result : result;
      }
    } catch (e) {
      print('Error parsing coordinate: $e');
    }
    return 0.0;
  }

  // Factory untuk membuat warehouse dari JSON
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Warehouse',
      location: json['location'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      sizeInSquareMeter: json['sizeInSquareMeter'] ?? 0.0,
      totalSlots: json['totalSlots'] ?? 100,
      occupiedSlots: json['occupiedSlots'] ?? 0,
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'sizeInSquareMeter': sizeInSquareMeter,
      'totalSlots': totalSlots,
      'occupiedSlots': occupiedSlots,
      'description': description,
      'city': city,
      'province': province,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy with untuk membuat instance baru dengan beberapa field yang diubah
  Warehouse copyWith({
    String? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    double? sizeInSquareMeter,
    int? totalSlots,
    int? occupiedSlots,
    String? description,
    String? city,
    String? province,
    DateTime? createdAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sizeInSquareMeter: sizeInSquareMeter ?? this.sizeInSquareMeter,
      totalSlots: totalSlots ?? this.totalSlots,
      occupiedSlots: occupiedSlots ?? this.occupiedSlots,
      description: description ?? this.description,
      city: city ?? this.city,
      province: province ?? this.province,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
