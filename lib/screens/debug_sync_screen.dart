import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/debug_supabase.dart';
import '../services/hive_service.dart';
import '../services/sync_queue_service.dart';
import '../providers/inventory_provider.dart';
import '../providers/offline_first_data_provider.dart';
import '../modules/inventory/controllers/inventory_controller.dart';

/// Debug screen untuk testing Supabase sync
class DebugSyncScreen extends StatefulWidget {
  const DebugSyncScreen({super.key});

  @override
  State<DebugSyncScreen> createState() => _DebugSyncScreenState();
}

class _DebugSyncScreenState extends State<DebugSyncScreen> {
  final _logs = <String>[].obs;
  final _isRunning = false.obs;

  void _addLog(String message) {
    _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
  }

  Future<void> _runDiagnostics() async {
    _isRunning.value = true;
    _logs.clear();
    
    try {
      _addLog('Starting diagnostics...');
      await DebugSupabase.runFullDiagnostics();
      _addLog('Diagnostics completed! Check console for details.');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _checkRLS() async {
    _isRunning.value = true;
    try {
      _addLog('Checking RLS status...');
      await DebugSupabase.checkRLSStatus();
      _addLog('Check console for RLS status');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _checkData() async {
    _isRunning.value = true;
    try {
      _addLog('Checking Supabase data...');
      await DebugSupabase.checkDataExists();
      _addLog('Check console for data details');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _insertTest() async {
    _isRunning.value = true;
    try {
      _addLog('Inserting test data...');
      await DebugSupabase.insertTestData();
      _addLog('Check console for insert result');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _compareData() async {
    _isRunning.value = true;
    try {
      _addLog('Comparing local vs remote...');
      
      // Get local data
      final hiveService = HiveService();
      await hiveService.init();
      final localItems = await hiveService.getStockItems();
      _addLog('Local (Hive): ${localItems.length} items');
      
      // Get remote data
      await DebugSupabase.compareLocalAndRemote();
      _addLog('Check console for comparison details');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _forceSync() async {
    _isRunning.value = true;
    try {
      _addLog('Force syncing from Supabase...');
      
      final provider = InventoryDataProvider();
      final items = await provider.fetchStockItems();
      
      _addLog('✅ Synced ${items.length} items');
      _addLog('Items cached locally');
      
      // Refresh inventory controller to reload data
      try {
        final inventoryController = Get.find<InventoryController>();
        _addLog('Refreshing inventory controller...');
        await inventoryController.refreshAll();
        _addLog('✅ Stock List refreshed!');
        _addLog('Navigate to Stock List to see data');
      } catch (e) {
        _addLog('⚠️ Controller not found: $e');
        _addLog('Data synced but screen needs manual refresh');
      }
    } catch (e) {
      _addLog('❌ Sync failed: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _clearCache() async {
    _isRunning.value = true;
    try {
      _addLog('Clearing local cache...');
      
      final hiveService = HiveService();
      await hiveService.init();
      await hiveService.clearAll();
      
      _addLog('✅ Cache cleared');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  Future<void> _clearPendingQueue() async {
    _isRunning.value = true;
    try {
      _addLog('Clearing pending sync queue...');
      
      final syncQueueService = Get.find<SyncQueueService>();
      final pendingCount = syncQueueService.getPendingCount();
      
      _addLog('Found $pendingCount pending operations');
      await syncQueueService.clearAll();
      
      // Refresh the provider's pending count
      try {
        final provider = Get.find<OfflineFirstDataProvider>();
        provider.refreshPendingCount();
        _addLog('Provider pending count refreshed');
      } catch (e) {
        _addLog('⚠️ Could not refresh provider: $e');
      }
      
      _addLog('✅ Pending queue cleared!');
      _addLog('"X pending" status should disappear now');
    } catch (e) {
      _addLog('ERROR: $e');
    } finally {
      _isRunning.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Supabase Sync'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _runDiagnostics,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Run Full Diagnostics'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _checkRLS,
                  icon: const Icon(Icons.security),
                  label: const Text('Check RLS'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _checkData,
                  icon: const Icon(Icons.storage),
                  label: const Text('Check Data'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _insertTest,
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Insert Test'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _compareData,
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('Compare Local/Remote'),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _forceSync,
                  icon: const Icon(Icons.sync),
                  label: const Text('Force Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _clearCache,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunning.value ? null : _clearPendingQueue,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Pending Queue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Logs Section
          Expanded(
            child: Obx(() {
              if (_logs.isEmpty) {
                return const Center(
                  child: Text(
                    'No logs yet. Run a diagnostic test.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color color = Colors.black87;
                  
                  if (log.contains('ERROR') || log.contains('❌')) {
                    color = Colors.red;
                  } else if (log.contains('✅') || log.contains('Success')) {
                    color = Colors.green;
                  } else if (log.contains('⚠️') || log.contains('WARNING')) {
                    color = Colors.orange;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          
          // Loading Indicator
          Obx(() {
            if (!_isRunning.value) return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black12,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Running...'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
