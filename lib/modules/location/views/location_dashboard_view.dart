import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../models/location_data.dart';
import '../../../utils/app_theme.dart';
import 'gps_location_view.dart';
import 'network_location_view.dart';
import 'live_location_view.dart';

/// Dashboard utama untuk Location Experiments
class LocationDashboardView extends GetView<LocationController> {
  const LocationDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Experiments'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showExperimentHistory(context),
            tooltip: 'Experiment History',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearDataDialog(context),
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // Quick Stats
            _buildQuickStats(),

            const SizedBox(height: 20),

            // Location Mode Cards
            const Text(
              'Location Modes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildModeCard(
              title: 'GPS Location',
              subtitle: 'High accuracy using GPS satellite',
              icon: Icons.gps_fixed,
              color: Colors.green,
              features: ['Best outdoor accuracy (1-10m)', 'Uses GPS chip', 'Higher battery usage'],
              onTap: () => Get.to(() => const GpsLocationView()),
            ),

            const SizedBox(height: 12),

            _buildModeCard(
              title: 'Network Location',
              subtitle: 'Using WiFi & Cell towers',
              icon: Icons.cell_tower,
              color: Colors.orange,
              features: ['Works indoor', 'Lower accuracy (10-100m)', 'Battery efficient'],
              onTap: () => Get.to(() => const NetworkLocationView()),
            ),

            const SizedBox(height: 12),

            _buildModeCard(
              title: 'Live Location',
              subtitle: 'Real-time tracking with path',
              icon: Icons.timeline,
              color: Colors.purple,
              features: ['Continuous tracking', 'Path visualization', 'Speed & distance'],
              onTap: () => Get.to(() => const LiveLocationView()),
            ),

            const SizedBox(height: 24),

            // Experiment Guide
            const Text(
              'Experiment Guide',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildExperimentGuide(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS vs Network',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Accuracy Comparison Experiment',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Compare GPS and Network location providers under different conditions: static outdoor, static indoor, and dynamic (moving).',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'GPS Readings',
              value: '${controller.totalGpsReadings.value}',
              icon: Icons.gps_fixed,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Network Readings',
              value: '${controller.totalNetworkReadings.value}',
              icon: Icons.cell_tower,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Experiments',
              value: '${controller.allExperiments.length}',
              icon: Icons.science,
              color: Colors.blue,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<String> features,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: features
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(fontSize: 11, color: color),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperimentGuide() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuideSection(
              number: '1',
              title: 'Static Outdoor',
              description: 'Pilih titik uji di area terbuka (halaman/lapangan). '
                  'Catat data GPS dan Network pada interval 10-20 detik.',
              color: Colors.green,
            ),
            const Divider(height: 24),
            _buildGuideSection(
              number: '2',
              title: 'Static Indoor',
              description: 'Pilih titik uji di dalam ruangan (lab/kelas). '
                  'Bandingkan hasil dengan kondisi outdoor.',
              color: Colors.orange,
            ),
            const Divider(height: 24),
            _buildGuideSection(
              number: '3',
              title: 'Dynamic (Bergerak)',
              description: 'Gunakan Live Location, berjalan mengelilingi area. '
                  'Bandingkan jalur GPS vs Network.',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection({
    required String number,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExperimentHistory(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Experiment History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Obx(() {
            final experiments = controller.allExperiments;

            if (experiments.isEmpty) {
              return const Center(
                child: Text('No experiments yet'),
              );
            }

            return ListView.builder(
              itemCount: experiments.length,
              itemBuilder: (context, index) {
                final exp = experiments[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getExperimentColor(exp.experimentType),
                      child: Icon(
                        _getExperimentIcon(exp.experimentType),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(exp.name),
                    subtitle: Text(
                      '${exp.experimentType} • ${exp.condition}\n'
                      '${exp.locationIds.length} readings',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'export',
                          child: const Row(
                            children: [
                              Icon(Icons.file_download),
                              SizedBox(width: 8),
                              Text('Export Data'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: const Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'export') {
                          _exportExperiment(exp);
                        } else if (value == 'delete') {
                          _deleteExperiment(exp);
                        }
                      },
                    ),
                  ),
                );
              },
            );
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getExperimentColor(String type) {
    if (type.contains('gps')) return Colors.green;
    if (type.contains('network')) return Colors.orange;
    return Colors.purple;
  }

  IconData _getExperimentIcon(String type) {
    if (type.contains('gps')) return Icons.gps_fixed;
    if (type.contains('network')) return Icons.cell_tower;
    return Icons.timeline;
  }

  void _exportExperiment(LocationExperiment exp) {
    final data = controller.exportExperimentData(exp.id);

    Get.dialog(
      AlertDialog(
        title: Text('Export: ${exp.name}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: SelectableText(
              data,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteExperiment(LocationExperiment exp) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Experiment?'),
        content: Text('This will delete "${exp.name}" and all its data.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteExperiment(exp.id);
              Get.back();
              Get.snackbar('Deleted', 'Experiment deleted');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will delete all experiments and location readings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearAllData();
              Get.back();
              Get.snackbar(
                'Cleared',
                'All data has been deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
