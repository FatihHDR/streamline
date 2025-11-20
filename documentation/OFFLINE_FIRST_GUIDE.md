# Offline-First Implementation Guide

## Overview

Aplikasi Streamline menggunakan **offline-first architecture** seperti WhatsApp, di mana:

1. ✅ **Offline**: Semua operasi (create/update/delete) langsung disimpan ke Hive dan masuk ke sync queue
2. ✅ **Online**: Otomatis sinkronisasi pending operations ke Supabase
3. ✅ **Real-time**: Connectivity listener otomatis trigger sync saat kembali online

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  (HomeScreen, StockListScreen, EditItemModal, etc.)         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  InventoryController                         │
│              (Business Logic Layer)                          │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              OfflineFirstDataProvider                        │
│           (Offline-First Strategy Pattern)                   │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Hive       │  │    Sync      │  │  Supabase    │     │
│  │   Service    │  │    Queue     │  │   Service    │     │
│  │  (Local DB)  │  │  (Pending)   │  │  (Remote DB) │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

## How It Works

### 1. Create Item (Offline-First)

```dart
// User clicks "Tambah Barang"
await controller.createStockItem(item);

// OfflineFirstDataProvider:
// 1. Save to Hive IMMEDIATELY ✓
await _hiveService.putStockItem(item);

// 2. Queue for sync
await _syncQueueService.queueCreate(
  entityType: 'stock_item',
  entityId: item.id,
  data: item.toJson(),
);

// 3. Try sync if online (background)
if (_isOnline.value) {
  syncPendingOperations(); // Non-blocking
}
```

**Result**: Item muncul di UI instantly, sync happens di background!

### 2. Update Item (Offline-First)

```dart
// User clicks "Simpan Perubahan"
await controller.updateStockItem(id, updatedItem);

// OfflineFirstDataProvider:
// 1. Update Hive IMMEDIATELY ✓
await _hiveService.putStockItem(updatedItem);

// 2. Queue for sync
await _syncQueueService.queueUpdate(
  entityType: 'stock_item',
  entityId: id,
  data: updatedItem.toJson(),
);

// 3. Try sync if online
if (_isOnline.value) {
  syncPendingOperations();
}
```

### 3. Delete Item (Offline-First)

```dart
// User confirms "Hapus Barang"
await controller.deleteStockItem(id);

// OfflineFirstDataProvider:
// 1. Remove from Hive IMMEDIATELY ✓
await _hiveService.deleteStockItem(id);

// 2. Queue for sync
await _syncQueueService.queueDelete(
  entityType: 'stock_item',
  entityId: id,
);

// 3. Try sync if online
if (_isOnline.value) {
  syncPendingOperations();
}
```

### 4. Auto-Sync When Back Online

```dart
// Connectivity listener in OfflineFirstDataProvider
_connectivity.onConnectivityChanged.listen((results) {
  final wasOffline = !_isOnline.value;
  _isOnline.value = !results.contains(ConnectivityResult.none);
  
  // Auto-sync when coming back online
  if (wasOffline && _isOnline.value) {
    Get.log('Back online! Starting auto-sync...');
    syncPendingOperations(); // 🔄 Automatic sync!
  }
});
```

## Sync Queue System

### PendingOperation Model

```dart
@HiveType(typeId: 3)
class PendingOperation {
  @HiveField(0) final String id;
  @HiveField(1) final OperationType type; // create/update/delete
  @HiveField(2) final String entityType; // 'stock_item' or 'transaction'
  @HiveField(3) final String entityId;
  @HiveField(4) final Map<String, dynamic>? data;
  @HiveField(5) final DateTime createdAt;
  @HiveField(6) int retryCount;
  @HiveField(7) String? errorMessage;
}
```

### Sync Flow

```
┌─────────────┐
│   Offline   │
│  Operation  │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Add to Queue   │
│  (Hive Box)     │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Wait for Online │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Auto-Sync Start │
│ (Connectivity)  │
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│ Process Queue   │
│ (FIFO Order)    │
└──────┬──────────┘
       │
       ├─ Success → Remove from queue ✓
       │
       └─ Failed → Retry (max 3x) → Remove if exceeded
```

## UI Indicators

### SyncStatusIndicator Widget

Menampilkan status real-time:

- 🟢 **Online**: Koneksi aktif, tidak ada pending operations
- 🟠 **Offline (X pending)**: Mode offline dengan X operasi belum sync
- 🔵 **X pending**: Online tapi masih ada operasi menunggu sync
- 🔄 **Syncing...**: Sedang proses sinkronisasi

## Testing Offline Mode

### 1. Simulate Offline

```dart
// Matikan WiFi/Data di device
// atau gunakan Airplane Mode
```

### 2. Perform Operations

```dart
// Tambah barang baru
// Edit barang existing
// Hapus barang
// Semua akan tersimpan di Hive + queued
```

### 3. Check Sync Queue

```dart
final stats = provider.getSyncStats();
print(stats); // { total: 3, creates: 1, updates: 1, deletes: 1 }
```

### 4. Go Back Online

```dart
// Nyalakan WiFi/Data
// Auto-sync akan trigger otomatis! 🎉
```

## Benefits

### 1. **Instant UI Response**
- Tidak perlu tunggu network request
- User experience seperti native app

### 2. **Offline Capability**
- App tetap berfungsi tanpa internet
- Data disimpan aman di local storage

### 3. **Automatic Sync**
- Tidak perlu manual sync button
- Background sync saat kembali online

### 4. **Retry Mechanism**
- Failed operations di-retry otomatis (max 3x)
- Error handling yang robust

### 5. **WhatsApp-like Experience**
- Checkmark indicators (bisa ditambahkan)
- Queue management system
- Real-time connectivity status

## Comparison: Old vs New

| Feature | Old (Online-First) | New (Offline-First) |
|---------|-------------------|---------------------|
| **Add Item** | Wait for Supabase → Show in UI | Save to Hive → Show instantly → Sync background |
| **Offline Support** | ❌ Error jika offline | ✅ Tetap berfungsi, queue for sync |
| **UI Responsiveness** | Slow (wait network) | Fast (instant local save) |
| **Sync Strategy** | Manual refresh | Automatic background sync |
| **Network Failure** | Data loss risk | Data safe in queue |
| **User Experience** | Blocking operations | Non-blocking, smooth |

## Files Modified/Created

### New Files
- `lib/models/pending_operation.dart` - Queue model
- `lib/services/sync_queue_service.dart` - Queue management
- `lib/providers/offline_first_data_provider.dart` - Offline-first logic
- `lib/providers/i_data_provider.dart` - Interface for providers
- `lib/widgets/sync_status_indicator.dart` - UI status indicator

### Modified Files
- `pubspec.yaml` - Added `connectivity_plus` + `uuid`
- `lib/main.dart` - Initialize SyncQueueService
- `lib/modules/inventory/bindings/inventory_binding.dart` - Use OfflineFirstDataProvider
- `lib/modules/inventory/controllers/inventory_controller.dart` - Use IDataProvider interface
- `lib/screens/home_screen.dart` - Add SyncStatusIndicator

## Dependencies Added

```yaml
connectivity_plus: ^6.0.5  # Network connectivity monitoring
uuid: ^4.5.1               # Generate unique IDs for operations
```

## Next Steps

1. ✅ Generate Hive adapters: `flutter pub run build_runner build --delete-conflicting-outputs`
2. ✅ Test offline mode (Airplane mode)
3. ✅ Verify auto-sync when back online
4. 🔄 Add checkmark indicators (optional, like WhatsApp)
5. 🔄 Add conflict resolution (optional, if 2 devices edit same item)

## Logs to Watch

```
✓ Item saved locally: Laptop HP          // Instant save
⏳ Queued for sync (1 pending)           // Added to queue
📴 Offline - will sync when online       // Connectivity check
🔄 Starting sync: 1 operations           // Auto-sync triggered
✓ Synced: CREATE stock_item:temp_123    // Sync success
✅ Sync complete: 1 success, 0 failed    // Done!
```

## Conclusion

Implementasi offline-first ini memberikan **user experience yang sangat baik** karena:
- App responsif dan cepat
- Tetap berfungsi offline
- Auto-sync seamless
- Data safety terjamin

Mirip dengan aplikasi modern seperti WhatsApp, Notion, atau Google Docs! 🚀
