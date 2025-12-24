import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';
import '../../../utils/app_theme.dart';

/// View untuk GPS Location dengan mode high accuracy
class GpsLocationView extends GetView<LocationController> {
  const GpsLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Location'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => IconButton(
                icon: Icon(
                  controller.isExperimentRunning.value
                      ? Icons.stop_circle
                      : Icons.play_circle,
                ),
                onPressed: () {
                  if (controller.isExperimentRunning.value) {
                    _showEndExperimentDialog(context);
                  } else {
                    _showStartExperimentDialog(context);
                  }
                },
                tooltip: controller.isExperimentRunning.value
                    ? 'End Experiment'
                    : 'Start Experiment',
              )),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 3,
            child: _buildMap(),
          ),

          // Control Panel
          _buildControlPanel(context),

          // Data Table
          Expanded(
            flex: 2,
            child: _buildDataTable(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _captureLocation(context),
        icon: const Icon(Icons.gps_fixed),
        label: const Text('Capture GPS'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final currentLoc = controller.currentLocation;
      final readings = controller.gpsReadings;

      // Default center (Indonesia)
      LatLng center = const LatLng(-6.200000, 106.816666);
      double zoom = 5.0;

      if (currentLoc != null) {
        center = LatLng(currentLoc.latitude, currentLoc.longitude);
        zoom = 17.0;
      } else if (readings.isNotEmpty) {
        center = LatLng(readings.last.latitude, readings.last.longitude);
        zoom = 17.0;
      }

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

          // Accuracy circle (jika ada current location)
          if (currentLoc != null)
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(currentLoc.latitude, currentLoc.longitude),
                  radius: currentLoc.accuracy,
                  useRadiusInMeter: true,
                  color: Colors.blue.withOpacity(0.2),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              ],
            ),

          // Markers untuk semua GPS readings
          MarkerLayer(
            markers: [
              // Current location marker
              if (currentLoc != null)
                Marker(
                  point: LatLng(currentLoc.latitude, currentLoc.longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),

              // History markers
              ...readings.map((loc) => Marker(
                    point: LatLng(loc.latitude, loc.longitude),
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${readings.indexOf(loc) + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildControlPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        final currentLoc = controller.currentLocation;
        final isRunning = controller.isExperimentRunning.value;

        return Column(
          children: [
            // Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(
                  'Provider',
                  'GPS',
                  Colors.green,
                  Icons.gps_fixed,
                ),
                _buildStatusChip(
                  'Readings',
                  '${controller.gpsReadings.length}',
                  Colors.blue,
                  Icons.location_on,
                ),
                _buildStatusChip(
                  'Experiment',
                  isRunning ? 'Active' : 'Idle',
                  isRunning ? Colors.orange : Colors.grey,
                  isRunning ? Icons.science : Icons.science_outlined,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Current location info
            if (currentLoc != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoTile('Lat', currentLoc.latitude.toStringAsFixed(6)),
                  _buildInfoTile('Lng', currentLoc.longitude.toStringAsFixed(6)),
                  _buildInfoTile('Acc', '${currentLoc.accuracy.toStringAsFixed(1)}m'),
                ],
              ),
            ] else ...[
              const Text(
                'Tap "Capture GPS" to get location',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildStatusChip(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Obx(() {
      final readings = controller.gpsReadings;

      if (readings.isEmpty) {
        return const Center(
          child: Text(
            'No GPS readings yet.\nCapture some locations to see data here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 16,
            columns: const [
              DataColumn(label: Text('#')),
              DataColumn(label: Text('Latitude')),
              DataColumn(label: Text('Longitude')),
              DataColumn(label: Text('Accuracy')),
              DataColumn(label: Text('Time')),
            ],
            rows: readings.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final loc = entry.value;
              return DataRow(cells: [
                DataCell(Text('$index')),
                DataCell(Text(loc.latitude.toStringAsFixed(6))),
                DataCell(Text(loc.longitude.toStringAsFixed(6))),
                DataCell(Text('${loc.accuracy.toStringAsFixed(1)}m')),
                DataCell(Text(_formatTime(loc.timestamp))),
              ]);
            }).toList(),
          ),
        ),
      );
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }

  Future<void> _captureLocation(BuildContext context) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final location = await controller.captureGpsLocation(
      experimentId: controller.currentExperiment.value?.id,
    );

    Get.back();

    if (location != null) {
      Get.snackbar(
        'GPS Captured',
        'Accuracy: ${location.accuracy.toStringAsFixed(1)}m',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to get GPS location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showStartExperimentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String condition = 'outdoor';

    Get.dialog(
      AlertDialog(
        title: const Text('Start GPS Experiment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Experiment Name',
                  hintText: 'e.g., Static Outdoor Test 1',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., GPS test at campus field',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: const [
                  DropdownMenuItem(value: 'outdoor', child: Text('Outdoor')),
                  DropdownMenuItem(value: 'indoor', child: Text('Indoor')),
                ],
                onChanged: (value) => condition = value ?? 'outdoor',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar('Error', 'Please enter experiment name');
                return;
              }
              controller.startExperiment(
                name: nameController.text,
                description: descController.text,
                experimentType: 'static_gps',
                condition: condition,
              );
              Get.back();
              Get.snackbar(
                'Experiment Started',
                nameController.text,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showEndExperimentDialog(BuildContext context) {
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('End Experiment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total GPS readings: ${controller.gpsReadings.length}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any observations?',
              ),
              maxLines: 3,
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
              controller.endExperiment(notes: notesController.text);
              Get.back();
              Get.snackbar(
                'Experiment Ended',
                'Data saved successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('End & Save'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('GPS Location Info'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'GPS Mode',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Uses device GPS chip\n'
                '• Highest accuracy (1-10m typical)\n'
                '• Best for outdoor use\n'
                '• May take longer to get first fix\n'
                '• Higher battery consumption',
              ),
              SizedBox(height: 16),
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Start an experiment (optional)\n'
                '2. Tap "Capture GPS" button\n'
                '3. Wait for location fix\n'
                '4. Repeat at intervals (10-20s)\n'
                '5. End experiment to save data',
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
