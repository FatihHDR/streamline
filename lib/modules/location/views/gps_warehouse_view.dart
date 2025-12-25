import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../models/warehouse_model.dart';
import '../services/warehouse_service.dart';
import '../../../utils/app_theme.dart';

/// GPS Warehouse Locator View dengan fitur map interaktif
class GpsWarehouseView extends StatefulWidget {
  const GpsWarehouseView({super.key});

  @override
  State<GpsWarehouseView> createState() => _GpsWarehouseViewState();
}

class _GpsWarehouseViewState extends State<GpsWarehouseView> {
  late MapController _mapController;
  final warehouseService = Get.find<WarehouseService>();
  
  // Initial view: Indonesia
  LatLng _currentCenter = const LatLng(-2.5489, 113.9213);
  double _currentZoom = 5.0;
  bool _showWarehouseList = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warehouses = warehouseService.getAllWarehouses();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Warehouse Locator'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: _currentZoom,
              minZoom: 2.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              ),
              MarkerLayer(
                markers: _buildWarehouseMarkers(warehouses),
              ),
            ],
          ),

          // Warehouse List Sidebar (Bottom Sheet)
          if (_showWarehouseList)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildWarehouseListPanel(warehouses),
            ),

          // Toggle button
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                setState(() {
                  _showWarehouseList = !_showWarehouseList;
                });
              },
              tooltip: _showWarehouseList ? 'Sembunyikan Daftar' : 'Tampilkan Daftar',
              child: Icon(
                _showWarehouseList ? Icons.list : Icons.list_outlined,
              ),
            ),
          ),

          // Reset button
          Positioned(
            top: 72,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                _mapController.move(
                  const LatLng(-2.5489, 113.9213),
                  5.0,
                );
              },
              tooltip: 'Fokus ke Indonesia',
              child: const Icon(Icons.home),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildWarehouseMarkers(List<Warehouse> warehouses) {
    return warehouses
        .map((warehouse) => Marker(
              point: LatLng(warehouse.latitude, warehouse.longitude),
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () {
                  _navigateToWarehouse(warehouse);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Pin with warehouse icon
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.warehouse,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // Popup indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        warehouse.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  Widget _buildWarehouseListPanel(List<Warehouse> warehouses) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showWarehouseList ? 300 : 0,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Pilih Gudang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${warehouses.length} gudang',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: warehouses.length,
              itemBuilder: (context, index) {
                final warehouse = warehouses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warehouse,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    title: Text(
                      warehouse.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${warehouse.city} • ${warehouse.occupancyPercentage.toStringAsFixed(0)}% terisi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    onTap: () {
                      _navigateToWarehouse(warehouse);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToWarehouse(Warehouse warehouse) {
    // Navigate to warehouse with smooth animation
    _mapController.move(
      LatLng(warehouse.latitude, warehouse.longitude),
      15.0, // Zoom in close to warehouse
    );

    // Show warehouse details in bottom sheet
    _showWarehouseDetails(warehouse);
  }

  void _showWarehouseDetails(Warehouse warehouse) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.warehouse,
                      color: Colors.blue,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          warehouse.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${warehouse.city}, ${warehouse.province}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Warehouse Location
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Lokasi',
                value: warehouse.location,
              ),

              const SizedBox(height: 12),

              // Warehouse Size
              _buildDetailRow(
                icon: Icons.aspect_ratio,
                label: 'Ukuran Gudang',
                value: '${warehouse.sizeInSquareMeter.toStringAsFixed(0)} m²',
              ),

              const SizedBox(height: 12),

              // Capacity
              _buildDetailRow(
                icon: Icons.inventory_2,
                label: 'Kapasitas',
                value:
                    '${warehouse.occupiedSlots}/${warehouse.totalSlots} slots',
              ),

              const SizedBox(height: 12),

              // Occupancy percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        'Utilisasi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${warehouse.occupancyPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: warehouse.occupancyPercentage >= 80
                              ? Colors.red
                              : warehouse.occupancyPercentage >= 50
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: warehouse.occupancyPercentage / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        warehouse.occupancyPercentage >= 80
                            ? Colors.red
                            : warehouse.occupancyPercentage >= 50
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Coordinates
              _buildDetailRow(
                icon: Icons.public,
                label: 'Koordinat',
                value:
                    '${warehouse.latitude.toStringAsFixed(4)}, ${warehouse.longitude.toStringAsFixed(4)}',
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Description
              if (warehouse.description.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      warehouse.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
