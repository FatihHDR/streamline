import 'dart:async';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/location_data.dart';
import '../services/location_service.dart';

/// Controller untuk mengelola eksperimen lokasi GPS vs Network
class LocationController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  // Hive boxes
  late Box<LocationData> _locationBox;
  late Box<LocationExperiment> _experimentBox;

  // Current experiment state
  final Rxn<LocationExperiment> currentExperiment = Rxn<LocationExperiment>();
  final isExperimentRunning = false.obs;

  // Data collections
  final RxList<LocationData> gpsReadings = <LocationData>[].obs;
  final RxList<LocationData> networkReadings = <LocationData>[].obs;
  final RxList<LocationExperiment> allExperiments = <LocationExperiment>[].obs;

  // Timer untuk auto-capture
  Timer? _captureTimer;
  final captureInterval = 10.obs; // default 10 detik

  // Stats
  final totalGpsReadings = 0.obs;
  final totalNetworkReadings = 0.obs;

  // Getters dari LocationService
  bool get hasPermission => _locationService.hasPermission.value;
  bool get isGpsEnabled => _locationService.isGpsEnabled.value;
  bool get isTracking => _locationService.isTracking.value;
  LocationData? get currentLocation => _locationService.currentLocation.value;
  List<LocationData> get trackingHistory => _locationService.locationHistory;
  LocationProvider get currentProvider => _locationService.currentProvider.value;

  @override
  void onInit() async {
    super.onInit();
    await _initHive();
    await _loadExperiments();
  }

  Future<void> _initHive() async {
    _locationBox = await Hive.openBox<LocationData>('location_readings');
    _experimentBox = await Hive.openBox<LocationExperiment>('location_experiments');
    Get.log('Location Hive boxes initialized');
  }

  Future<void> _loadExperiments() async {
    allExperiments.assignAll(_experimentBox.values.toList());
    totalGpsReadings.value = _locationBox.values
        .where((l) => l.providerType == 'gps')
        .length;
    totalNetworkReadings.value = _locationBox.values
        .where((l) => l.providerType == 'network')
        .length;
  }

  /// Request location permissions
  Future<bool> requestPermissions() async {
    await _locationService.init();
    return _locationService.hasPermission.value;
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  // ============================================
  // SINGLE LOCATION CAPTURE
  // ============================================

  /// Capture single GPS location
  Future<LocationData?> captureGpsLocation({String? experimentId}) async {
    final location = await _locationService.getCurrentLocation(
      forceGps: true,
      experimentId: experimentId,
    );

    if (location != null) {
      gpsReadings.add(location);
      await _locationBox.put(location.id, location);
      totalGpsReadings.value++;

      if (currentExperiment.value != null) {
        currentExperiment.value!.locationIds.add(location.id);
        await currentExperiment.value!.save();
      }
    }

    return location;
  }

  /// Capture single Network location
  Future<LocationData?> captureNetworkLocation({String? experimentId}) async {
    final location = await _locationService.getCurrentLocation(
      forceNetwork: true,
      experimentId: experimentId,
    );

    if (location != null) {
      networkReadings.add(location);
      await _locationBox.put(location.id, location);
      totalNetworkReadings.value++;

      if (currentExperiment.value != null) {
        currentExperiment.value!.locationIds.add(location.id);
        await currentExperiment.value!.save();
      }
    }

    return location;
  }

  // ============================================
  // EXPERIMENT MANAGEMENT
  // ============================================

  /// Start new experiment
  Future<void> startExperiment({
    required String name,
    required String description,
    required String experimentType,
    required String condition,
  }) async {
    final experiment = LocationExperiment(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
      experimentType: experimentType,
      condition: condition,
      startTime: DateTime.now(),
    );

    await _experimentBox.put(experiment.id, experiment);
    currentExperiment.value = experiment;
    isExperimentRunning.value = true;
    gpsReadings.clear();
    networkReadings.clear();

    Get.log('Experiment started: ${experiment.name}');
  }

  /// End current experiment
  Future<void> endExperiment({String? notes}) async {
    if (currentExperiment.value == null) return;

    currentExperiment.value!.endTime = DateTime.now();
    currentExperiment.value!.notes = notes;
    await currentExperiment.value!.save();

    allExperiments.add(currentExperiment.value!);
    isExperimentRunning.value = false;

    Get.log('Experiment ended: ${currentExperiment.value!.name}');
    Get.log('Total GPS readings: ${gpsReadings.length}');
    Get.log('Total Network readings: ${networkReadings.length}');
  }

  /// Start auto-capture timer
  void startAutoCapture({
    required bool captureGps,
    required bool captureNetwork,
    int intervalSeconds = 10,
  }) {
    stopAutoCapture();
    captureInterval.value = intervalSeconds;

    _captureTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) async {
        if (captureGps) {
          await captureGpsLocation(experimentId: currentExperiment.value?.id);
        }
        if (captureNetwork) {
          await captureNetworkLocation(experimentId: currentExperiment.value?.id);
        }
      },
    );

    Get.log('Auto-capture started: ${intervalSeconds}s interval');
  }

  /// Stop auto-capture timer
  void stopAutoCapture() {
    _captureTimer?.cancel();
    _captureTimer = null;
    Get.log('Auto-capture stopped');
  }

  // ============================================
  // LIVE TRACKING
  // ============================================

  /// Start live tracking
  Future<void> startLiveTracking({
    bool useGpsOnly = false,
    bool useNetworkOnly = false,
    int distanceFilter = 5,
    String? experimentId,
  }) async {
    await _locationService.startTracking(
      useGpsOnly: useGpsOnly,
      useNetworkOnly: useNetworkOnly,
      distanceFilter: distanceFilter,
      experimentId: experimentId ?? currentExperiment.value?.id,
    );
  }

  /// Stop live tracking
  Future<void> stopLiveTracking() async {
    await _locationService.stopTracking();

    // Save all tracking points to Hive
    for (final location in _locationService.locationHistory) {
      await _locationBox.put(location.id, location);
      if (currentExperiment.value != null) {
        currentExperiment.value!.locationIds.add(location.id);
      }
    }
    if (currentExperiment.value != null) {
      await currentExperiment.value!.save();
    }
  }

  /// Clear tracking history
  void clearTrackingHistory() {
    _locationService.clearHistory();
  }

  /// Get tracking stats
  Map<String, dynamic> getTrackingStats() {
    return {
      'totalPoints': trackingHistory.length,
      'totalDistance': _locationService.getTotalDistance(),
      'averageAccuracy': _locationService.getAverageAccuracy(),
      'accuracyRange': _locationService.getAccuracyRange(),
    };
  }

  // ============================================
  // DATA ANALYSIS
  // ============================================

  /// Get all readings for an experiment
  List<LocationData> getExperimentReadings(String experimentId) {
    return _locationBox.values
        .where((l) => l.experimentId == experimentId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  /// Compare GPS vs Network for an experiment
  Map<String, dynamic> compareProviders(String experimentId) {
    final readings = getExperimentReadings(experimentId);
    final gpsData = readings.where((l) => l.providerType == 'gps').toList();
    final networkData = readings.where((l) => l.providerType == 'network').toList();

    double gpsAvgAccuracy = 0;
    double networkAvgAccuracy = 0;

    if (gpsData.isNotEmpty) {
      gpsAvgAccuracy = gpsData.fold<double>(0, (sum, l) => sum + l.accuracy) / gpsData.length;
    }
    if (networkData.isNotEmpty) {
      networkAvgAccuracy =
          networkData.fold<double>(0, (sum, l) => sum + l.accuracy) / networkData.length;
    }

    return {
      'gpsCount': gpsData.length,
      'networkCount': networkData.length,
      'gpsAvgAccuracy': gpsAvgAccuracy,
      'networkAvgAccuracy': networkAvgAccuracy,
      'gpsMinAccuracy': gpsData.isNotEmpty
          ? gpsData.map((l) => l.accuracy).reduce((a, b) => a < b ? a : b)
          : 0,
      'gpsMaxAccuracy': gpsData.isNotEmpty
          ? gpsData.map((l) => l.accuracy).reduce((a, b) => a > b ? a : b)
          : 0,
      'networkMinAccuracy': networkData.isNotEmpty
          ? networkData.map((l) => l.accuracy).reduce((a, b) => a < b ? a : b)
          : 0,
      'networkMaxAccuracy': networkData.isNotEmpty
          ? networkData.map((l) => l.accuracy).reduce((a, b) => a > b ? a : b)
          : 0,
    };
  }

  /// Export experiment data as formatted string (for documentation)
  String exportExperimentData(String experimentId) {
    final experiment = _experimentBox.get(experimentId);
    if (experiment == null) return 'Experiment not found';

    final readings = getExperimentReadings(experimentId);
    final comparison = compareProviders(experimentId);

    final buffer = StringBuffer();
    buffer.writeln('# Experiment: ${experiment.name}');
    buffer.writeln('');
    buffer.writeln('## Details');
    buffer.writeln('- Type: ${experiment.experimentType}');
    buffer.writeln('- Condition: ${experiment.condition}');
    buffer.writeln('- Start: ${experiment.startTime}');
    buffer.writeln('- End: ${experiment.endTime ?? "N/A"}');
    buffer.writeln('- Notes: ${experiment.notes ?? "N/A"}');
    buffer.writeln('');
    buffer.writeln('## Summary');
    buffer.writeln('| Metric | GPS | Network |');
    buffer.writeln('|--------|-----|---------|');
    buffer.writeln('| Readings | ${comparison['gpsCount']} | ${comparison['networkCount']} |');
    buffer.writeln(
        '| Avg Accuracy | ${comparison['gpsAvgAccuracy'].toStringAsFixed(2)}m | ${comparison['networkAvgAccuracy'].toStringAsFixed(2)}m |');
    buffer.writeln(
        '| Min Accuracy | ${comparison['gpsMinAccuracy'].toStringAsFixed(2)}m | ${comparison['networkMinAccuracy'].toStringAsFixed(2)}m |');
    buffer.writeln(
        '| Max Accuracy | ${comparison['gpsMaxAccuracy'].toStringAsFixed(2)}m | ${comparison['networkMaxAccuracy'].toStringAsFixed(2)}m |');
    buffer.writeln('');
    buffer.writeln('## Raw Data');
    buffer.writeln('| # | Provider | Lat | Lng | Accuracy | Timestamp |');
    buffer.writeln('|---|----------|-----|-----|----------|-----------|');

    for (int i = 0; i < readings.length; i++) {
      final r = readings[i];
      buffer.writeln(
          '| ${i + 1} | ${r.providerType} | ${r.latitude.toStringAsFixed(6)} | ${r.longitude.toStringAsFixed(6)} | ${r.accuracy.toStringAsFixed(1)}m | ${r.timestamp.toIso8601String()} |');
    }

    return buffer.toString();
  }

  /// Delete experiment and its data
  Future<void> deleteExperiment(String experimentId) async {
    final readings = getExperimentReadings(experimentId);
    for (final reading in readings) {
      await _locationBox.delete(reading.id);
    }
    await _experimentBox.delete(experimentId);
    allExperiments.removeWhere((e) => e.id == experimentId);
    await _loadExperiments();
  }

  /// Clear all data
  Future<void> clearAllData() async {
    await _locationBox.clear();
    await _experimentBox.clear();
    gpsReadings.clear();
    networkReadings.clear();
    allExperiments.clear();
    totalGpsReadings.value = 0;
    totalNetworkReadings.value = 0;
  }

  @override
  void onClose() {
    stopAutoCapture();
    super.onClose();
  }
}
