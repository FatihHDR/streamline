import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_controller.dart';
import '../models/location_data.dart';
import '../../../utils/app_theme.dart';

/// View untuk Network Location dengan mode low power
class NetworkLocationView extends GetView<LocationController> {
  const NetworkLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Location'),
        backgroundColor: Colors.orange,
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
        icon: const Icon(Icons.cell_tower),
        label: const Text('Capture Network'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildMap() {
    return Obx(() {
      final currentLoc = controller.currentLocation;
      final readings = controller.networkReadings;

      // Default center (Indonesia)
      LatLng center = const LatLng(-6.200000, 106.816666);
      double zoom = 5.0;

      if (currentLoc != null) {
        center = LatLng(currentLoc.latitude, currentLoc.longitude);
        zoom = 16.0;
      } else if (readings.isNotEmpty) {
        center = LatLng(readings.last.latitude, readings.last.longitude);
        zoom = 16.0;
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
                  color: Colors.orange.withOpacity(0.2),
                  borderColor: Colors.orange,
                  borderStrokeWidth: 2,
                ),
              ],
            ),

          // Markers untuk semua Network readings
          MarkerLayer(
            markers: [
              // Current location marker
              if (currentLoc != null)
                Marker(
                  point: LatLng(currentLoc.latitude, currentLoc.longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.cell_tower,
                    color: Colors.orange,
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
                        color: Colors.deepOrange.withOpacity(0.8),
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
                  'Network',
                  Colors.orange,
                  Icons.cell_tower,
                ),
                _buildStatusChip(
                  'Readings',
                  '${controller.networkReadings.length}',
                  Colors.deepOrange,
                  Icons.location_on,
                ),
                _buildStatusChip(
                  'Experiment',
                  isRunning ? 'Active' : 'Idle',
                  isRunning ? Colors.green : Colors.grey,
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
                'Tap "Capture Network" to get location',
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
      final readings = controller.networkReadings;

      if (readings.isEmpty) {
        return const Center(
          child: Text(
            'No Network readings yet.\nCapture some locations to see data here.',
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

    final location = await controller.captureNetworkLocation(
      experimentId: controller.currentExperiment.value?.id,
    );

    Get.back();

    if (location != null) {
      Get.snackbar(
        'Network Captured',
        'Accuracy: ${location.accuracy.toStringAsFixed(1)}m',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to get Network location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showStartExperimentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String condition = 'indoor';

    Get.dialog(
      AlertDialog(
        title: const Text('Start Network Experiment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Experiment Name',
                  hintText: 'e.g., Static Indoor Test 1',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Network test in lab room',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: const [
                  DropdownMenuItem(value: 'indoor', child: Text('Indoor')),
                  DropdownMenuItem(value: 'outdoor', child: Text('Outdoor')),
                ],
                onChanged: (value) => condition = value ?? 'indoor',
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
                experimentType: 'static_network',
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
            Text('Total Network readings: ${controller.networkReadings.length}'),
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
        title: const Text('Network Location Info'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Network Mode',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Uses WiFi & Cell towers\n'
                '• Lower accuracy (10-100m typical)\n'
                '• Works indoors\n'
                '• Faster first fix\n'
                '• Lower battery consumption',
              ),
              SizedBox(height: 16),
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '1. Start an experiment (optional)\n'
                '2. Tap "Capture Network" button\n'
                '3. Wait for location fix\n'
                '4. Repeat at intervals (10-20s)\n'
                '5. End experiment to save data',
              ),
              SizedBox(height: 16),
              Text(
                'Best for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Indoor positioning\n'
                '• Battery-conscious tracking\n'
                '• Approximate location needs',
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
