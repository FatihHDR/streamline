import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/location_data.dart';

/// Service untuk mengelola akses lokasi GPS dan Network
class LocationService extends GetxService {
  // Stream subscription untuk live tracking
  StreamSubscription<Position>? _positionSubscription;

  // Status observables
  final isGpsEnabled = false.obs;
  final isNetworkEnabled = false.obs;
  final hasPermission = false.obs;
  final isTracking = false.obs;
  final currentProvider = LocationProvider.fused.obs;

  // Current location
  final Rxn<LocationData> currentLocation = Rxn<LocationData>();

  // Location history untuk tracking
  final RxList<LocationData> locationHistory = <LocationData>[].obs;

  /// Initialize service dan check permissions
  Future<LocationService> init() async {
    await _checkPermissions();
    await _checkLocationServices();
    return this;
  }

  /// Check dan request location permissions
  Future<bool> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      hasPermission.value = false;
      Get.log('Location permissions are permanently denied', isError: true);
      return false;
    }

    if (permission == LocationPermission.denied) {
      hasPermission.value = false;
      Get.log('Location permissions are denied', isError: true);
      return false;
    }

    hasPermission.value = true;
    Get.log('Location permissions granted');
    return true;
  }

  /// Check apakah GPS dan Network location enabled
  Future<void> _checkLocationServices() async {
    isGpsEnabled.value = await Geolocator.isLocationServiceEnabled();
    // Network location biasanya available jika location service enabled
    isNetworkEnabled.value = isGpsEnabled.value;

    Get.log('GPS enabled: ${isGpsEnabled.value}');
    Get.log('Network enabled: ${isNetworkEnabled.value}');
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings untuk permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get current location sekali (one-shot)
  /// [forceGps] - true untuk memaksa GPS only (high accuracy)
  /// [forceNetwork] - true untuk memaksa Network only (low power)
  Future<LocationData?> getCurrentLocation({
    bool forceGps = false,
    bool forceNetwork = false,
    String? experimentId,
  }) async {
    if (!hasPermission.value) {
      final granted = await _checkPermissions();
      if (!granted) return null;
    }

    try {
      LocationAccuracy accuracy;
      LocationProvider provider;

      if (forceGps) {
        // GPS only - highest accuracy, uses GPS chip
        accuracy = LocationAccuracy.best;
        provider = LocationProvider.gps;
      } else if (forceNetwork) {
        // Network only - lower accuracy, uses WiFi/Cell towers
        accuracy = LocationAccuracy.low;
        provider = LocationProvider.network;
      } else {
        // Fused - kombinasi terbaik dari keduanya
        accuracy = LocationAccuracy.high;
        provider = LocationProvider.fused;
      }

      currentProvider.value = provider;

      Get.log('Getting location with provider: ${provider.name}, accuracy: $accuracy');

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: 0, // update setiap perubahan
        ),
      );

      final locationData = LocationData.fromPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
        provider: provider,
        experimentId: experimentId,
      );

      currentLocation.value = locationData;
      Get.log('Location received: $locationData');

      return locationData;
    } catch (e) {
      Get.log('Error getting location: $e', isError: true);
      return null;
    }
  }

  /// Start live location tracking
  /// [useGpsOnly] - true untuk GPS only mode
  /// [useNetworkOnly] - true untuk Network only mode
  /// [intervalMs] - interval update dalam milliseconds
  Future<void> startTracking({
    bool useGpsOnly = false,
    bool useNetworkOnly = false,
    int intervalMs = 1000,
    int distanceFilter = 5,
    String? experimentId,
  }) async {
    if (!hasPermission.value) {
      final granted = await _checkPermissions();
      if (!granted) return;
    }

    // Stop existing tracking jika ada
    await stopTracking();

    LocationAccuracy accuracy;
    LocationProvider provider;

    if (useGpsOnly) {
      accuracy = LocationAccuracy.best;
      provider = LocationProvider.gps;
    } else if (useNetworkOnly) {
      accuracy = LocationAccuracy.low;
      provider = LocationProvider.network;
    } else {
      accuracy = LocationAccuracy.high;
      provider = LocationProvider.fused;
    }

    currentProvider.value = provider;
    isTracking.value = true;
    locationHistory.clear();

    Get.log('Starting tracking with provider: ${provider.name}');

    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: Duration(milliseconds: intervalMs),
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        final locationData = LocationData.fromPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          speed: position.speed,
          heading: position.heading,
          timestamp: position.timestamp,
          provider: provider,
          experimentId: experimentId,
        );

        currentLocation.value = locationData;
        locationHistory.add(locationData);

        Get.log('Tracking update: $locationData');
      },
      onError: (error) {
        Get.log('Tracking error: $error', isError: true);
      },
    );
  }

  /// Stop live tracking
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    isTracking.value = false;
    Get.log('Tracking stopped. Total points: ${locationHistory.length}');
  }

  /// Clear location history
  void clearHistory() {
    locationHistory.clear();
    Get.log('Location history cleared');
  }

  /// Calculate total distance traveled (untuk live tracking)
  double getTotalDistance() {
    if (locationHistory.length < 2) return 0;

    double total = 0;
    for (int i = 1; i < locationHistory.length; i++) {
      total += locationHistory[i - 1].distanceTo(locationHistory[i]);
    }
    return total;
  }

  /// Get average accuracy dari history
  double getAverageAccuracy() {
    if (locationHistory.isEmpty) return 0;
    final sum = locationHistory.fold<double>(0, (sum, loc) => sum + loc.accuracy);
    return sum / locationHistory.length;
  }

  /// Get min/max accuracy
  Map<String, double> getAccuracyRange() {
    if (locationHistory.isEmpty) {
      return {'min': 0, 'max': 0};
    }
    final accuracies = locationHistory.map((l) => l.accuracy).toList();
    accuracies.sort();
    return {
      'min': accuracies.first,
      'max': accuracies.last,
    };
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
