import 'package:hive/hive.dart';

part 'location_data.g.dart';

/// Enum untuk membedakan provider lokasi
enum LocationProvider {
  gps,
  network,
  fused, // kombinasi GPS + Network
}

/// Model untuk menyimpan data lokasi hasil pengukuran
@HiveType(typeId: 10)
class LocationData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final double accuracy; // dalam meter

  @HiveField(4)
  final double? altitude;

  @HiveField(5)
  final double? speed; // dalam m/s

  @HiveField(6)
  final double? heading; // arah dalam derajat

  @HiveField(7)
  final DateTime timestamp;

  @HiveField(8)
  final String providerType; // 'gps', 'network', atau 'fused'

  @HiveField(9)
  final String? experimentId; // untuk mengelompokkan data per eksperimen

  @HiveField(10)
  final String? notes;

  LocationData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    required this.providerType,
    this.experimentId,
    this.notes,
  });

  /// Factory dari Geolocator Position
  factory LocationData.fromPosition({
    required double latitude,
    required double longitude,
    required double accuracy,
    double? altitude,
    double? speed,
    double? heading,
    required DateTime timestamp,
    required LocationProvider provider,
    String? experimentId,
    String? notes,
  }) {
    return LocationData(
      id: '${DateTime.now().millisecondsSinceEpoch}_${provider.name}',
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      timestamp: timestamp,
      providerType: provider.name,
      experimentId: experimentId,
      notes: notes,
    );
  }

  /// Hitung jarak ke lokasi lain (dalam meter)
  double distanceTo(LocationData other) {
    // Menggunakan formula Haversine
    const double earthRadius = 6371000; // dalam meter
    final double lat1Rad = latitude * (3.141592653589793 / 180);
    final double lat2Rad = other.latitude * (3.141592653589793 / 180);
    final double deltaLat = (other.latitude - latitude) * (3.141592653589793 / 180);
    final double deltaLon = (other.longitude - longitude) * (3.141592653589793 / 180);

    final double a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1Rad) * cos(lat2Rad) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert ke Map untuk JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'altitude': altitude,
        'speed': speed,
        'heading': heading,
        'timestamp': timestamp.toIso8601String(),
        'providerType': providerType,
        'experimentId': experimentId,
        'notes': notes,
      };

  /// Factory dari JSON
  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        id: json['id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        accuracy: (json['accuracy'] as num).toDouble(),
        altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
        speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
        heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
        timestamp: DateTime.parse(json['timestamp'] as String),
        providerType: json['providerType'] as String,
        experimentId: json['experimentId'] as String?,
        notes: json['notes'] as String?,
      );

  @override
  String toString() =>
      'LocationData($providerType: $latitude, $longitude, acc: ${accuracy.toStringAsFixed(1)}m)';

  // Helper math functions
  static double sin(double x) => _sin(x);
  static double cos(double x) => _cos(x);
  static double sqrt(double x) => _sqrt(x);
  static double atan2(double y, double x) => _atan2(y, x);

  static double _sin(double x) {
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }

  static double _cos(double x) {
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }

  static double _sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 20; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  static double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }

  static double _atan(double x) {
    return x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
  }
}

/// Model untuk menyimpan data eksperimen
@HiveType(typeId: 11)
class LocationExperiment extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String experimentType; // 'static_outdoor', 'static_indoor', 'dynamic'

  @HiveField(4)
  final String condition; // 'outdoor', 'indoor'

  @HiveField(5)
  final DateTime startTime;

  @HiveField(6)
  DateTime? endTime;

  @HiveField(7)
  final List<String> locationIds; // referensi ke LocationData

  @HiveField(8)
  String? notes;

  LocationExperiment({
    required this.id,
    required this.name,
    required this.description,
    required this.experimentType,
    required this.condition,
    required this.startTime,
    this.endTime,
    List<String>? locationIds,
    this.notes,
  }) : locationIds = locationIds ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'experimentType': experimentType,
        'condition': condition,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'locationIds': locationIds,
        'notes': notes,
      };

  factory LocationExperiment.fromJson(Map<String, dynamic> json) =>
      LocationExperiment(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        experimentType: json['experimentType'] as String,
        condition: json['condition'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        locationIds: (json['locationIds'] as List<dynamic>).cast<String>(),
        notes: json['notes'] as String?,
      );
}
