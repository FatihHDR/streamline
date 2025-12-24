import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';
import '../models/location_data.dart';

/// View untuk Live Location (Real-Time Tracking) dengan path visualization
class LiveLocationView extends GetView<LocationController> {
  const LiveLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isTracking ? Icons.stop : Icons.play_arrow,
                ),
                onPressed: () {
                  if (controller.isTracking) {
                    _stopTracking();
                  } else {
                    _showTrackingOptionsDialog(context);
                  }
                },
                tooltip: controller.isTracking ? 'Stop Tracking' : 'Start Tracking',
              )),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _clearHistory(),
            tooltip: 'Clear History',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section dengan path
          Expanded(
            flex: 4,
            child: _buildMap(),
          ),

          // Stats Panel
          _buildStatsPanel(context),

          // Live Data Feed
          Expanded(
            flex: 2,
            child: _buildLiveDataFeed(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final trackingHistory = controller.trackingHistory;
      final currentLoc = controller.currentLocation;

      // Default center (Indonesia)
      LatLng center = const LatLng(-6.200000, 106.816666);
      double zoom = 5.0;

      if (currentLoc != null) {
        center = LatLng(currentLoc.latitude, currentLoc.longitude);
        zoom = 18.0;
      } else if (trackingHistory.isNotEmpty) {
        center = LatLng(trackingHistory.last.latitude, trackingHistory.last.longitude);
        zoom = 18.0;
      }

      // Convert tracking history to LatLng list for polyline
      final pathPoints = trackingHistory
          .map((loc) => LatLng(loc.latitude, loc.longitude))
          .toList();

      return FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
        ),
        children: [
          // OpenStreetMap Tile Layer
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.streamline.app',
          ),

          // Path polyline
          if (pathPoints.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: pathPoints,
                  strokeWidth: 4.0,
                  color: Colors.purple.withOpacity(0.8),
                ),
              ],
            ),

          // Accuracy circle untuk current location
          if (currentLoc != null)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(currentLoc.latitude, currentLoc.longitude),
                  radius: currentLoc.accuracy,
                  useRadiusInMeter: true,
                  color: Colors.purple.withOpacity(0.2),
                  borderColor: Colors.purple,
                  borderStrokeWidth: 2,
                ),
              ],
            ),

          // Markers
          MarkerLayer(
            markers: [
              // Start point marker
              if (trackingHistory.isNotEmpty)
                Marker(
                  point: LatLng(
                    trackingHistory.first.latitude,
                    trackingHistory.first.longitude,
                  ),
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

              // Current location marker
              if (currentLoc != null)
                Marker(
                  point: LatLng(currentLoc.latitude, currentLoc.longitude),
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated pulse effect
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ],
                  ),
                ),

              // Waypoints (setiap 5 titik)
              ...trackingHistory.asMap().entries
                  .where((entry) => entry.key % 5 == 0 && entry.key > 0)
                  .map((entry) => Marker(
                        point: LatLng(
                          entry.value.latitude,
                          entry.value.longitude,
                        ),
                        width: 16,
                        height: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.purple.shade300,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatsPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        final isTracking = controller.isTracking;
        final provider = controller.currentProvider;
        final stats = controller.getTrackingStats();
        final currentLoc = controller.currentLocation;

        return Column(
          children: [
            // Tracking status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isTracking ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTracking ? 'Tracking Active' : 'Tracking Stopped',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTracking ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProviderColor(provider).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.name.toUpperCase(),
                    style: TextStyle(
                      color: _getProviderColor(provider),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatTile(
                  icon: Icons.location_on,
                  value: '${stats['totalPoints']}',
                  label: 'Points',
                  color: Colors.purple,
                ),
                _buildStatTile(
                  icon: Icons.straighten,
                  value: _formatDistance(stats['totalDistance'] as double),
                  label: 'Distance',
                  color: Colors.blue,
                ),
                _buildStatTile(
                  icon: Icons.gps_fixed,
                  value: currentLoc != null
                      ? '${currentLoc.accuracy.toStringAsFixed(0)}m'
                      : '--',
                  label: 'Accuracy',
                  color: Colors.orange,
                ),
                _buildStatTile(
                  icon: Icons.speed,
                  value: currentLoc?.speed != null
                      ? '${(currentLoc!.speed! * 3.6).toStringAsFixed(1)} km/h'
                      : '--',
                  label: 'Speed',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLiveDataFeed() {
    return Obx(() {
      final history = controller.trackingHistory;

      if (history.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Start tracking to see live data feed',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      // Show last 10 readings
      final recentReadings = history.reversed.take(10).toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: recentReadings.length,
        itemBuilder: (context, index) {
          final loc = recentReadings[index];
          final isLatest = index == 0;

          return Card(
            color: isLatest ? Colors.purple.shade50 : null,
            child: ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: isLatest ? Colors.purple : Colors.grey.shade300,
                child: Text(
                  '${history.length - index}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLatest ? Colors.white : Colors.black,
                  ),
                ),
              ),
              title: Text(
                '${loc.latitude.toStringAsFixed(6)}, ${loc.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              subtitle: Text(
                'Accuracy: ${loc.accuracy.toStringAsFixed(1)}m • ${_formatTime(loc.timestamp)}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: isLatest
                  ? const Icon(Icons.fiber_manual_record, color: Colors.green, size: 12)
                  : null,
            ),
          );
        },
      );
    });
  }

  Color _getProviderColor(LocationProvider provider) {
    switch (provider) {
      case LocationProvider.gps:
        return Colors.green;
      case LocationProvider.network:
        return Colors.orange;
      case LocationProvider.fused:
        return Colors.purple;
    }
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    }
    return '${(meters / 1000).toStringAsFixed(2)}km';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  void _showTrackingOptionsDialog(BuildContext context) {
    String selectedProvider = 'fused';

    Get.dialog(
      AlertDialog(
        title: const Text('Start Live Tracking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select location provider:'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Fused (Best)'),
                    subtitle: const Text('Combines GPS + Network'),
                    value: 'fused',
                    groupValue: selectedProvider,
                    onChanged: (value) => setState(() => selectedProvider = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('GPS Only'),
                    subtitle: const Text('High accuracy, outdoor'),
                    value: 'gps',
                    groupValue: selectedProvider,
                    onChanged: (value) => setState(() => selectedProvider = value!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Network Only'),
                    subtitle: const Text('Lower accuracy, works indoor'),
                    value: 'network',
                    groupValue: selectedProvider,
                    onChanged: (value) => setState(() => selectedProvider = value!),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _startTracking(selectedProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  Future<void> _startTracking(String provider) async {
    final hasPermission = await controller.requestPermissions();
    if (!hasPermission) {
      Get.snackbar(
        'Permission Required',
        'Please grant location permission to use tracking',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await controller.startLiveTracking(
      useGpsOnly: provider == 'gps',
      useNetworkOnly: provider == 'network',
      distanceFilter: 3, // update setiap 3 meter
    );

    Get.snackbar(
      'Tracking Started',
      'Using ${provider.toUpperCase()} provider',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.purple,
      colorText: Colors.white,
    );
  }

  Future<void> _stopTracking() async {
    await controller.stopLiveTracking();

    final stats = controller.getTrackingStats();
    Get.snackbar(
      'Tracking Stopped',
      'Recorded ${stats['totalPoints']} points, ${_formatDistance(stats['totalDistance'] as double)}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _clearHistory() {
    if (controller.trackingHistory.isEmpty) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Clear History?'),
        content: Text(
          'This will delete ${controller.trackingHistory.length} tracking points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearTrackingHistory();
              Get.back();
              Get.snackbar(
                'Cleared',
                'Tracking history cleared',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Live Location Tracking'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Real-Time Tracking',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Continuously tracks your movement\n'
                '• Shows path on map (polyline)\n'
                '• Updates every 3 meters or 1 second\n'
                '• Displays speed, distance, accuracy',
              ),
              SizedBox(height: 16),
              Text(
                'Provider Modes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Fused: Best of GPS + Network\n'
                '• GPS Only: High accuracy outdoor\n'
                '• Network Only: Indoor capable',
              ),
              SizedBox(height: 16),
              Text(
                'Experiment Tips:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Walk around a known area\n'
                '2. Compare GPS vs Network paths\n'
                '3. Observe marker movements\n'
                '4. Note accuracy changes\n'
                '5. Check path smoothness',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
