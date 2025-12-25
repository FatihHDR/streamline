import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class for debugging Supabase connection and sync issues
class DebugSupabase {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Check if RLS is properly disabled or policies are permissive
  static Future<void> checkRLSStatus() async {
    try {
      print('=== CHECKING RLS STATUS ===');
      
      // Check auth status
      final session = _client.auth.currentSession;
      final user = _client.auth.currentUser;
      
      print('Auth Status:');
      print('  - Has Session: ${session != null}');
      print('  - User ID: ${user?.id ?? "NO USER"}');
      print('  - User Role: ${user?.role ?? "NO ROLE"}');
      print('  - Is Anonymous: ${user?.isAnonymous ?? true}');
      
      // Try to fetch data without auth
      print('\nTrying to fetch inventory_items...');
      final response = await _client
          .from('inventory_items')
          .select()
          .limit(10);
      
      print('Success! Found ${(response as List).length} items');
      print('Sample data: ${response.isNotEmpty ? response.first : "EMPTY"}');
      
    } catch (e, stackTrace) {
      print('ERROR fetching inventory_items:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
      
      if (e.toString().contains('row-level security')) {
        print('\n⚠️ RLS IS STILL ENABLED! Run bypass_rls_for_testing.sql');
      } else if (e.toString().contains('JWT')) {
        print('\n⚠️ AUTH TOKEN ISSUE! Check authentication setup');
      } else if (e.toString().contains('permission')) {
        print('\n⚠️ PERMISSION DENIED! Check RLS policies');
      }
    }
  }

  /// Check if data exists in Supabase
  static Future<void> checkDataExists() async {
    try {
      print('\n=== CHECKING DATA IN SUPABASE ===');
      
      // Count total inventory items
      final count = await _client
          .from('inventory_items')
          .select('id')
          .count();
      
      print('Total inventory_items in Supabase: $count');
      
      // Get all items
      final items = await _client
          .from('inventory_items')
          .select()
          .order('created_at', ascending: false);
      
      print('\nAll items:');
      for (var item in items as List) {
        print('  - ${item['name']} (ID: ${item['id']}, Owner: ${item['owner_id']})');
      }
      
    } catch (e) {
      print('ERROR: $e');
    }
  }

  /// Insert test data to verify sync
  static Future<void> insertTestData() async {
    try {
      print('\n=== INSERTING TEST DATA ===');
      
      final testItem = {
        'name': 'Test Item ${DateTime.now().millisecondsSinceEpoch}',
        'category': 'Testing',
        'quantity': 100,
        'unit': 'pcs',
        'location': 'Test Warehouse',
        'min_stock': 10,
        'description': 'Test item for debugging sync',
        'last_updated': DateTime.now().toUtc().toIso8601String(),
      };
      
      print('Inserting: ${testItem['name']}');
      
      final response = await _client
          .from('inventory_items')
          .insert(testItem)
          .select()
          .single();
      
      print('✅ Success! Created item with ID: ${response['id']}');
      
    } catch (e, stackTrace) {
      print('❌ ERROR inserting test data:');
      print('Error: $e');
      print('StackTrace: $stackTrace');
    }
  }

  /// Compare local (Hive) data with Supabase data
  static Future<void> compareLocalAndRemote() async {
    try {
      print('\n=== COMPARING LOCAL vs REMOTE DATA ===');
      
      // Get remote data
      final remoteItems = await _client
          .from('inventory_items')
          .select();
      
      print('Remote (Supabase): ${(remoteItems as List).length} items');
      
      // Get local data - would need HiveService instance
      print('Local (Hive): [NEED TO CHECK MANUALLY]');
      
      print('\nRemote items:');
      for (var item in remoteItems) {
        print('  - ${item['name']} (qty: ${item['quantity']})');
      }
      
    } catch (e) {
      print('ERROR: $e');
    }
  }

  /// Run all diagnostics
  static Future<void> runFullDiagnostics() async {
    print('╔════════════════════════════════════════════╗');
    print('║   SUPABASE SYNC DIAGNOSTICS                ║');
    print('╚════════════════════════════════════════════╝\n');
    
    await checkRLSStatus();
    await checkDataExists();
    await compareLocalAndRemote();
    
    print('\n╔════════════════════════════════════════════╗');
    print('║   DIAGNOSTICS COMPLETE                     ║');
    print('╚════════════════════════════════════════════╝');
  }
}
