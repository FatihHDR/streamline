# Analisis Kompleksitas Implementasi Data Persistence

Dokumen ini menganalisis kompleksitas implementasi dari tiga pendekatan penyimpanan data yang digunakan dalam aplikasi Streamline: **SharedPreferences**, **Hive**, dan **Supabase**.

---

## 1. Struktur Kode dan File yang Terlibat

### 📊 Ringkasan per Teknologi

| Teknologi | File Utama | File Pendukung | Total File | Baris Kode Utama |
|-----------|------------|----------------|------------|------------------|
| **SharedPreferences** | `preferences_service.dart` | - | 1 | ~107 lines |
| **Hive** | `hive_service.dart` | `stock_item.dart` + annotations<br>`stock_transaction.dart` + annotations<br>`*.g.dart` (generated) | 5 files | ~110 lines service<br>+40 lines annotations |
| **Supabase** | `supabase_service.dart`<br>`auth_service.dart` | `schema.sql`<br>`.env` config<br>Fix SQL files | 6+ files | ~114 lines service<br>+74 lines auth<br>+156 lines SQL |

---

## 2. SharedPreferences - Implementasi Paling Sederhana

### Struktur File
```
lib/services/
  └── preferences_service.dart (107 lines)
```

### Kompleksitas Implementasi

#### ✅ Kelebihan
- **1 file saja** untuk semua operasi
- **Tidak perlu code generation**
- **Tidak perlu SQL schema**
- API sangat sederhana: `getString()`, `setString()`, `setInt()`, `setBool()`

#### Jumlah Baris Kode untuk Operasi Umum

**Inisialisasi (5 baris):**
```dart
SharedPreferences? _prefs;
Future<void> _initPreferences() async {
  _prefs = await SharedPreferences.getInstance();
}
```

**Menyimpan data (3 baris):**
```dart
await _prefs?.setString(_keyAnimationMode, mode);
animationMode.value = mode;
Get.log('Animation mode saved: $mode');
```

**Membaca data (1 baris):**
```dart
animationMode.value = _prefs?.getString(_keyAnimationMode) ?? 'animated_container';
```

**Error handling (built-in):**
- Null-safe dengan `?` operator
- Default value handling dengan `??`
- **Tidak perlu try-catch** untuk operasi dasar

#### ⚠️ Keterbatasan
- Hanya untuk **data primitif** (String, int, bool, double)
- **Tidak bisa menyimpan object kompleks** (harus serialize manual ke JSON string)
- **Tidak ada query/filter** capability
- **Tidak cocok untuk data besar** (maksimal beberapa KB)

---

## 3. Hive - Kompleksitas Sedang, Powerful untuk Lokal

### Struktur File
```
lib/
├── services/
│   └── hive_service.dart (110 lines)
├── models/
│   ├── stock_item.dart
│   ├── stock_item.g.dart (auto-generated, ~150 lines)
│   ├── stock_transaction.dart (dengan @HiveType annotations, ~75 lines)
│   └── stock_transaction.g.dart (auto-generated, ~140 lines)
└── main.dart (inisialisasi Hive, +10 lines)
```

### Kompleksitas Implementasi

#### Tahap Setup (One-time)

**1. Tambah annotations ke model (+40 baris total):**
```dart
import 'package:hive/hive.dart';
part 'stock_item.g.dart';

@HiveType(typeId: 0)
class StockItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  // dan
}
```

**2. Generate adapter (1 command):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**3. Register adapter di main.dart (+4 baris):**
```dart
await Hive.initFlutter();
Hive.registerAdapter(StockItemAdapter());
Hive.registerAdapter(StockTransactionAdapter());
Hive.registerAdapter(TransactionTypeAdapter());
```

#### Operasi Runtime

**Inisialisasi box (5 baris):**
```dart
Box<StockItem>? _itemsBox;
Future<void> init() async {
  _itemsBox = await Hive.openBox<StockItem>('stock_items');
}
```

**Menyimpan data (2 baris):**
```dart
await _itemsBox!.put(item.id, item);
Get.log('Item cached: ${item.name}');
```

**Membaca data (1 baris):**
```dart
return _itemsBox!.values.toList();
```

**Query/Filter (1-2 baris):**
```dart
return _itemsBox!.values
    .where((item) => item.quantity <= item.minStock)
    .toList();
```

**Error handling (perlu manual try-catch, +5 baris):**
```dart
try {
  await _itemsBox!.put(item.id, item);
} catch (e) {
  Get.log('Hive write error: $e', isError: true);
  rethrow;
}
```

#### ✅ Kelebihan
- **Object kompleks bisa disimpan langsung** (no manual JSON parsing)
- **Query capability** dengan `.where()`, `.filter()`
- **Type-safe** dengan generics
- **Performa sangat cepat** (NoSQL local)
- **Bisa menyimpan data besar** (MB - GB)

#### ⚠️ Kompleksitas Tambahan
- **Code generation** diperlukan (adds build step)
- **Type adapter** harus di-maintain untuk setiap model
- **Migration** manual jika struktur data berubah
- **~40 baris annotations** per model

---

## 4. Supabase - Kompleksitas Tinggi, Cloud Database Penuh

### Struktur File
```
lib/
├── services/
│   ├── supabase_service.dart (114 lines - CRUD operations)
│   └── auth_service.dart (74 lines - authentication)
├── providers/
│   └── inventory_data_provider.dart (150+ lines - caching strategy)
├── models/
│   ├── stock_item.dart (+30 lines toJson/fromJson)
│   └── stock_transaction.dart (+30 lines toJson/fromJson)
└── main.dart (+8 lines Supabase.initialize)

supabase/
├── schema.sql (156 lines - tabel, trigger, RLS, views)
├── fix_owner_id_for_anon.sql (60 lines)
└── remove_fkey_constraint.sql (40 lines)

.env (4 lines - credentials)
```

### Kompleksitas Implementasi

#### Tahap Setup (One-time, Extensive)

**1. Setup Database Schema (156 baris SQL):**
```sql
-- Extensions
create extension if not exists "pgcrypto";

-- Enums
create type public.inventory_transaction_type as enum ('incoming', 'outgoing');

-- Tables dengan constraints, foreign keys, indexes
create table public.inventory_items (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null,
  name text not null,
  -- ... 10+ kolom lainnya
);

-- Indexes untuk performance
create index idx_inventory_items_owner_category on ...;

-- Triggers untuk auto-update
create trigger trg_inventory_items_updated_at ...;

-- Row Level Security policies
create policy inventory_items_allow_all on ...;

-- Views untuk aggregasi
create or replace view inventory_dashboard_metrics as ...;
```

**2. Model serialization (+60 baris total untuk 2 model):**
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'name': name,
    'category': category,
    // ... semua field mapping ke snake_case
  };
}

factory StockItem.fromJson(Map<String, dynamic> json) {
  return StockItem(
    id: json['id'] as String,
    name: json['name'] as String,
    // ... parsing dengan type casting
  );
}
```

**3. Environment setup (+8 baris config):**
```dart
// .env file
SUPABASE_URL=https://...
SUPABASE_ANON_KEY=eyJ...

// main.dart
await dotenv.load(fileName: '.env');
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

**4. Authentication setup (+74 baris):**
```dart
// auth_service.dart - handle login, logout, session
final authService = Get.put(AuthService());
await authService.signInAnonymously();
```

#### Operasi Runtime

**Inisialisasi (sudah di-handle saat app start, 0 baris tambahan):**
```dart
final SupabaseClient _client = Supabase.instance.client;
```

**Menyimpan data (~15 baris dengan error handling):**
```dart
Future<StockItem> createStockItem(StockItem item) async {
  try {
    final data = item.toJson();
    data.remove('id');  // Auto-generated
    data.remove('created_at');
    data.remove('updated_at');

    final response = await _client
        .from('inventory_items')
        .insert(data)
        .select()
        .single();

    return StockItem.fromJson(response);
  } catch (e) {
    throw Exception('Failed to create stock item: $e');
  }
}
```

**Membaca data (~12 baris dengan error handling):**
```dart
Future<List<StockItem>> getStockItems() async {
  try {
    final response = await _client
        .from('inventory_items')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => StockItem.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch stock items: $e');
  }
}
```

**Query/Filter (~8 baris):**
```dart
final response = await _client
    .from('inventory_items')
    .select()
    .eq('category', 'Elektronik')
    .lte('quantity', 'minStock')
    .order('quantity', ascending: true);
```

**Error handling (WAJIB, +5-10 baris per method):**
```dart
try {
  // operation
} catch (e) {
  if (e is PostgrestException) {
    // Handle specific DB errors
  } else if (e is SocketException) {
    // Handle network errors
  }
  throw Exception('Failed: $e');
}
```

**Caching strategy (tambahan ~150 baris di provider):**
```dart
Future<List<StockItem>> fetchStockItems() async {
  try {
    final items = await _supabaseService.getStockItems();
    await _hiveService.cacheStockItems(items);  // Sync to local
    return items;
  } catch (e) {
    // Fallback to Hive cache
    return await _hiveService.getStockItems();
  }
}
```

#### ✅ Kelebihan
- **Real-time sync** antar device
- **Cloud backup** otomatis
- **Powerful query** dengan PostgreSQL
- **Built-in auth & RLS** untuk security
- **Scalable** untuk jutaan records

#### ⚠️ Kompleksitas Tinggi
- **~156 baris SQL schema** yang harus di-maintain
- **Manual serialization** untuk setiap model (+30 baris/model)
- **Error handling kompleks** (network, auth, DB constraints)
- **Memerlukan internet** (atau caching strategy tambahan)
- **RLS policies** harus dipahami untuk security
- **Migration strategy** untuk schema changes
- **API credentials management** (.env, security)

---

## 5. Perbandingan Jumlah Baris Kode

### Untuk Operasi: **Simpan 1 Item**

| Teknologi | LOC Setup | LOC Runtime | LOC Error Handling | Total |
|-----------|-----------|-------------|-------------------|-------|
| **SharedPreferences** | 5 | 3 | 0 (built-in null-safe) | **8 lines** |
| **Hive** | 40 (annotations) + 4 (register) | 2 | 5 (try-catch) | **51 lines** |
| **Supabase** | 156 (SQL) + 30 (serialization) + 8 (env) | 15 | 10 (network + DB) | **219 lines** |

### Untuk Operasi: **Baca Semua Item**

| Teknologi | LOC Runtime | LOC Error Handling | Total |
|-----------|-------------|-------------------|-------|
| **SharedPreferences** | 1 | 0 | **1 line** |
| **Hive** | 1 | 5 | **6 lines** |
| **Supabase** | 12 | 10 | **22 lines** |

### Untuk Operasi: **Query/Filter Data**

| Teknologi | Capability | LOC |
|-----------|------------|-----|
| **SharedPreferences** | ❌ Tidak ada (harus manual loop) | **N/A** |
| **Hive** | ✅ `.where()` in-memory | **2 lines** |
| **Supabase** | ✅ PostgreSQL query dengan index | **8 lines** |

---

## 6. Kompleksitas Error Handling

### SharedPreferences
```dart
// Minimal error handling - mostly null-safe
final value = _prefs?.getString(key) ?? defaultValue;
// Auto-handled: file system errors, corruption
```
**Error cases:** ~2-3 (file system, null checks)

### Hive
```dart
try {
  await box.put(key, value);
} catch (e) {
  // Handle: box not opened, disk full, corruption
  Get.log('Hive error: $e');
}
```
**Error cases:** ~5-7 (box lifecycle, disk issues, type mismatches)

### Supabase
```dart
try {
  final response = await _client.from('table').insert(data);
} catch (e) {
  if (e is PostgrestException) {
    // DB constraint violations, RLS policy errors
  } else if (e is SocketException) {
    // Network timeout, no connection
  } else if (e is AuthException) {
    // Unauthorized, session expired
  }
}
```
**Error cases:** ~15+ (network, auth, DB constraints, RLS, timeouts, rate limits)

---

## 7. Kesimpulan Kompleksitas

### 🥉 **Kompleksitas Rendah: SharedPreferences**
- **Total setup:** ~10 lines
- **Per operation:** 1-3 lines
- **File count:** 1 file
- **Best for:** Preferences sederhana, flags, settings
- **Learning curve:** 1 hari

### 🥈 **Kompleksitas Sedang: Hive**
- **Total setup:** ~60 lines (one-time)
- **Per operation:** 2-7 lines
- **File count:** 3-5 files (model + service + generated)
- **Best for:** Cache lokal, offline data, object storage
- **Learning curve:** 3-5 hari

### 🥇 **Kompleksitas Tinggi: Supabase**
- **Total setup:** ~250+ lines (SQL + config + serialization)
- **Per operation:** 12-25 lines
- **File count:** 10+ files (services, SQL, config, auth)
- **Best for:** Multi-device sync, cloud storage, collaboration
- **Learning curve:** 1-2 minggu

---

## 8. Trade-offs Summary

| Aspek | SharedPreferences | Hive | Supabase |
|-------|------------------|------|----------|
| **Lines of Code** | ✅ Minimal (8-10) | 🟡 Sedang (50-60) | ❌ Banyak (200+) |
| **Setup Complexity** | ✅ Sangat mudah | 🟡 Perlu generator | ❌ Perlu DB setup |
| **Maintenance** | ✅ Hampir tidak ada | 🟡 Adapter updates | ❌ Schema migrations |
| **Type Safety** | ❌ Primitives only | ✅ Full type-safe | 🟡 Manual casting |
| **Query Power** | ❌ Tidak ada | 🟡 In-memory filter | ✅ SQL full-power |
| **Performance** | ✅ Instan | ✅ Sangat cepat | 🟡 Network dependent |
| **Offline Support** | ✅ Native | ✅ Native | ❌ Perlu caching layer |
| **Multi-device Sync** | ❌ Tidak | ❌ Tidak | ✅ Real-time |
| **Data Size Limit** | ❌ KB range | 🟡 MB-GB range | ✅ Unlimited (cloud) |

---

**Rekomendasi Arsitektur Hybrid (seperti di Streamline):**
- **SharedPreferences** → UI preferences, flags (animationMode, isFirstLaunch)
- **Hive** → Local cache, offline data (cachedItems, cachedTransactions)
- **Supabase** → Source of truth, multi-device sync (remote DB)

Dengan strategi ini, kita mendapat **best of all worlds**:
- Cepat (SharedPreferences untuk settings)
- Offline-capable (Hive sebagai cache)
- Scalable & Syncable (Supabase sebagai backend)
