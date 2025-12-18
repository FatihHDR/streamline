# 🔔 Modul 6: Implementasi Push Notification dengan Firebase Cloud Messaging (FCM)

**Aplikasi:** Streamline - Aplikasi Manajemen Stok Gudang  
**State Management:** GetX  
**Struktur:** Modular (Controller, View, Service)

---

## 📋 Daftar Isi

1. [Ringkasan Implementasi](#ringkasan-implementasi)
2. [Struktur Project](#struktur-project)
3. [Setup dan Konfigurasi](#setup-dan-konfigurasi)
4. [Integrasi dengan Alur Bisnis](#integrasi-dengan-alur-bisnis)
5. [Eksperimen Notifikasi](#eksperimen-notifikasi)
6. [Analisis Perilaku & Latensi](#analisis-perilaku--latensi)
7. [Refleksi & Studi Kasus](#refleksi--studi-kasus)

---

## 🎯 Ringkasan Implementasi

Sistem notifikasi telah diintegrasikan ke dalam aplikasi **Streamline** untuk menangani berbagai skenario warehouse management:

### Skenario Notifikasi:
1. **Stok Menipis (`low_stock`)** - Notifikasi ketika stok barang mencapai batas minimum
2. **Stok Habis (`out_of_stock`)** - Alert ketika barang habis total
3. **Transaksi Baru (`new_transaction`)** - Notifikasi saat ada transaksi masuk/keluar barang
4. **Pengingat Restok (`restock_reminder`)** - Reminder untuk melakukan restok barang

### Teknologi yang Digunakan:
- **Firebase Cloud Messaging (FCM)** - Push notification
- **Flutter Local Notifications** - Notifikasi lokal dengan custom sound
- **GetX** - State management dan dependency injection
- **Hive** - Local storage untuk riwayat notifikasi

---

## 📁 Struktur Project

```
lib/
├── main.dart                                      # ✅ Inisialisasi FCM
├── firebase_options.dart                          # ✅ Konfigurasi Firebase
│
├── services/
│   └── fcm_notification_service.dart              # ✅ Service utama FCM
│
├── modules/
│   └── notification/
│       ├── controllers/
│       │   └── notification_controller.dart       # ✅ State management
│       ├── views/
│       │   ├── notification_list_screen.dart      # ✅ Daftar notifikasi
│       │   └── notification_detail_screen.dart    # ✅ Detail notifikasi
│       └── bindings/
│           └── notification_binding.dart          # ✅ GetX binding
│
├── models/
│   └── notification_item.dart                     # Model data notifikasi
│
└── assets/
    └── sounds/
        └── notification_sound.mp3                 # Custom sound

android/
├── app/
│   ├── google-services.json                       # ✅ Firebase config
│   └── src/main/
│       ├── AndroidManifest.xml                    # ✅ Permissions & metadata
│       └── res/raw/
│           └── notification_sound.mp3             # ✅ Android sound file
```

---

## 🔧 Setup dan Konfigurasi

### 1. Firebase Setup

#### A. Buat Project Firebase
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Buat project baru atau gunakan yang ada
3. Tambahkan aplikasi Android

#### B. Download `google-services.json`
1. Masuk ke Project Settings > Your apps
2. Download file `google-services.json`
3. Letakkan di: `android/app/google-services.json`

#### C. Konfigurasi `firebase_options.dart`

**PENTING:** Update file `lib/firebase_options.dart` dengan credential dari Firebase Console:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...', // Ganti dengan API Key Anda
  appId: '1:123456...', // Ganti dengan App ID Anda
  messagingSenderId: '123456789', // Ganti dengan Messaging Sender ID
  projectId: 'your-project-id', // Ganti dengan Project ID Anda
  storageBucket: 'your-project.appspot.com', // Ganti dengan Storage Bucket
);
```

**Cara Mendapatkan Credentials:**
1. Firebase Console > Project Settings > General
2. Scroll ke bawah ke bagian "Your apps"
3. Klik aplikasi Android Anda
4. Semua values akan terlihat di sana

### 2. Install Dependencies

Jalankan command berikut:

```bash
flutter pub get
```

### 3. Custom Notification Sound

#### A. Persiapkan File Audio
- Format: **MP3** atau **WAV**
- Durasi: **1-3 detik** (recommended)
- Size: **< 500KB** (recommended)

#### B. Letakkan File di Dua Tempat:

**1. Untuk Assets (iOS & Testing):**
```
assets/sounds/notification_sound.mp3
```

**2. Untuk Android Native:**
```
android/app/src/main/res/raw/notification_sound.mp3
```

**CATATAN:** Nama file harus **lowercase** dan **tanpa spasi**!

### 4. Build Project

```bash
# Clean dan rebuild
flutter clean
flutter pub get
flutter build apk --debug

# Atau jalankan langsung
flutter run
```

---

## 🔗 Integrasi dengan Alur Bisnis

### Skenario 1: Notifikasi Stok Menipis

**Trigger:** Ketika stok barang < 10 unit

**Payload Data:**
```json
{
  "notification": {
    "title": "⚠️ Stok Menipis",
    "body": "Barang [Nama Barang] tersisa [X] unit"
  },
  "data": {
    "type": "low_stock",
    "screen": "inventory",
    "item_id": "abc123",
    "item_name": "Laptop Asus",
    "current_stock": "8"
  }
}
```

**Navigasi:** Membuka halaman inventory dengan filter stok menipis

### Skenario 2: Notifikasi Stok Habis

**Trigger:** Ketika stok barang = 0

**Payload Data:**
```json
{
  "notification": {
    "title": "🚨 Stok Habis",
    "body": "Barang [Nama Barang] telah habis"
  },
  "data": {
    "type": "out_of_stock",
    "screen": "inventory",
    "item_id": "def456",
    "item_name": "Mouse Logitech"
  }
}
```

**Navigasi:** Membuka halaman inventory dengan filter stok habis

### Skenario 3: Notifikasi Transaksi Baru

**Trigger:** Ketika ada transaksi barang masuk/keluar

**Payload Data:**
```json
{
  "notification": {
    "title": "📦 Transaksi Baru",
    "body": "[IN/OUT] [Qty] unit [Nama Barang]"
  },
  "data": {
    "type": "new_transaction",
    "screen": "transaction",
    "transaction_id": "txn789",
    "transaction_type": "IN",
    "quantity": "50"
  }
}
```

**Navigasi:** Membuka halaman riwayat transaksi

### Skenario 4: Pengingat Restok

**Trigger:** Dijadwalkan untuk barang yang perlu direstock

**Payload Data:**
```json
{
  "notification": {
    "title": "🔔 Pengingat Restok",
    "body": "Saatnya restok [Nama Barang]"
  },
  "data": {
    "type": "restock_reminder",
    "screen": "inventory",
    "item_id": "ghi012",
    "item_name": "Keyboard Mechanical"
  }
}
```

**Navigasi:** Membuka detail barang spesifik

---

## 🧪 Eksperimen Notifikasi

### Eksperimen 1: Kondisi Foreground (Aplikasi Sedang Dibuka)

#### Langkah-langkah:

1. **Buka aplikasi** dan biarkan di halaman Home
2. **Kirim notifikasi** dari Firebase Console:
   - Firebase Console > Cloud Messaging > Send your first message
   - Title: "🧪 Test Foreground"
   - Body: "Testing notifikasi saat app terbuka"
   - Target: Single device (gunakan FCM token dari log)

3. **Amati hasil:**
   - ✅ Heads-up notification muncul di atas layar
   - ✅ Custom sound terdengar
   - ✅ Log terminal menampilkan payload data

#### Log yang Diharapkan:

```
I/flutter (12345): 📱 [FOREGROUND] Message received!
I/flutter (12345): 📱 [FOREGROUND] Title: 🧪 Test Foreground
I/flutter (12345): 📱 [FOREGROUND] Body: Testing notifikasi saat app terbuka
I/flutter (12345): 📱 [FOREGROUND] Data: {type: test, ...}
I/flutter (12345): ✅ [FOREGROUND] Local notification displayed
```

#### Screenshot yang Perlu Diambil:
- [ ] Heads-up notification banner
- [ ] Log terminal dengan payload
- [ ] Notification di system tray

---

### Eksperimen 2: Kondisi Background (Aplikasi Di-minimize)

#### Langkah-langkah:

1. **Tekan tombol Home** pada HP (aplikasi berjalan di background)
2. **Kirim notifikasi** dari Firebase Console dengan data:
   ```json
   {
     "notification": {
       "title": "🧪 Test Background",
       "body": "Testing notifikasi background"
     },
     "data": {
       "type": "low_stock",
       "screen": "inventory"
     }
   }
   ```

3. **Amati:**
   - ✅ Notifikasi masuk ke System Tray
   - ✅ Sound dan vibration aktif
   
4. **Tap notifikasi:**
   - ✅ App terbuka kembali
   - ✅ Navigasi otomatis ke halaman inventory

#### Log yang Diharapkan:

```
I/flutter (12345): 📱 [BACKGROUND] Handling message: msg-id-123
I/flutter (12345): 📱 [BACKGROUND TAP] Notification opened!
I/flutter (12345): 🧭 Navigating to: /home with args: {initialTab: 1}
```

#### Screenshot yang Perlu Diambil:
- [ ] Notifikasi di system tray
- [ ] App membuka halaman inventory
- [ ] Log navigation

---

### Eksperimen 3: Kondisi Terminated (Aplikasi Ditutup Paksa)

#### Langkah-langkah:

1. **Kill aplikasi** dari Recent Apps (swipe up atau force stop)
2. **Kirim notifikasi** dari Firebase Console:
   ```json
   {
     "notification": {
       "title": "🧪 Test Terminated",
       "body": "Testing notifikasi saat app mati"
     },
     "data": {
       "type": "new_transaction",
       "screen": "transaction"
     }
   }
   ```

3. **Amati:**
   - ✅ Notifikasi tetap masuk meskipun app mati
   - ✅ Notifikasi tampil di system tray

4. **Tap notifikasi:**
   - ✅ App melakukan cold start (splash screen muncul)
   - ✅ Setelah inisialisasi, navigasi otomatis ke halaman transaksi

#### Log yang Diharapkan:

```
I/flutter (12345): 🔔 Initializing FCM Notification Service...
I/flutter (12345): 📱 [TERMINATED TAP] App opened from notification!
I/flutter (12345): 📱 [TERMINATED TAP] Data: {type: new_transaction, ...}
I/flutter (12345): 🧭 Navigating to: /home with args: {initialTab: 2}
```

#### Screenshot yang Perlu Diambil:
- [ ] Notifikasi saat app mati
- [ ] Splash screen saat app dibuka
- [ ] Navigasi ke halaman transaksi
- [ ] Log inisialisasi dan navigation

---

## 📊 Analisis Perilaku & Latensi

### Pengukuran Latensi

#### Metodologi:
1. Catat waktu saat tombol "Send" ditekan di Firebase Console
2. Catat waktu saat notifikasi muncul di HP
3. Hitung selisih waktu

#### Hasil Pengujian (Template):

| Kondisi App | Waktu Kirim | Waktu Terima | Latensi | Keterangan |
|-------------|-------------|--------------|---------|------------|
| **Foreground** | 14:30:00 | 14:30:01 | ~1 detik | Sangat cepat |
| **Background** | 14:35:00 | 14:35:02 | ~2 detik | Cepat |
| **Terminated** | 14:40:00 | 14:40:05 | ~5 detik | Moderat |

#### Analisis Perbedaan Latensi:

**1. Foreground (Paling Cepat)**
- **Alasan:** App sudah running, connection FCM aktif
- **Koneksi:** Persistent connection ke FCM server
- **Proses:** Langsung dihandle oleh `FirebaseMessaging.onMessage`

**2. Background (Cepat)**
- **Alasan:** App masih di memori, proses background aktif
- **Koneksi:** FCM connection masih maintained oleh sistem
- **Proses:** System tray notification + background handler

**3. Terminated (Paling Lambat)**
- **Alasan:** App harus dibangunkan dari state terminated
- **Android Doze Mode:** Bisa menunda notifikasi untuk hemat baterai
- **Prioritas FCM:** 
  - High priority message: Bypass Doze Mode
  - Normal priority: Ikut batch processing

#### Faktor yang Mempengaruhi Latensi:

1. **Kecepatan Internet**
   - WiFi: Lebih stabil dan cepat
   - Mobile data: Bisa lebih lambat tergantung sinyal

2. **Kondisi HP**
   - Battery Saver Mode: Bisa menunda notifikasi
   - Doze Mode: Mengoptimalkan baterai dengan menunda background task
   - RAM: Low memory bisa memperlambat processing

3. **Prioritas Notifikasi**
   - **High Priority:** Langsung delivered, bypass Doze Mode
   - **Normal Priority:** Ikut batch processing (bisa delay 5-15 menit)

4. **FCM Server Load**
   - Peak hours: Bisa lebih lambat
   - Server location: Jarak geografis mempengaruhi latency

### Rekomendasi Optimasi:

```dart
// Set high priority di FCM payload
{
  "message": {
    "token": "device_token",
    "notification": { ... },
    "android": {
      "priority": "high" // ⚡ Bypass Doze Mode
    },
    "apns": {
      "headers": {
        "apns-priority": "10" // iOS high priority
      }
    }
  }
}
```

---

## 💭 Refleksi & Studi Kasus

### 1. Strategi User Engagement

#### A. Meningkatkan Retensi Pengguna

**Skenario Pengingat Pasif:**
- Jika user tidak membuka app selama **3 hari**
- Kirim notifikasi: "👋 Hai Admin! Ada [X] barang yang perlu dicek"
- Tujuan: Remind tanpa spam

**Implementasi dengan Cloud Functions (Firebase):**
```javascript
// Scheduled function - jalan setiap hari jam 9 pagi
exports.sendDailyReminder = functions.pubsub
  .schedule('0 9 * * *')
  .timeZone('Asia/Jakarta')
  .onRun(async (context) => {
    // Query users yang tidak login 3 hari
    const inactiveUsers = await getInactiveUsers(3);
    
    for (const user of inactiveUsers) {
      await admin.messaging().send({
        token: user.fcmToken,
        notification: {
          title: '👋 Streamline merindukanmu!',
          body: 'Ada item yang perlu perhatianmu'
        },
        data: {
          type: 'engagement',
          screen: 'home'
        }
      });
    }
  });
```

#### B. Smart Notification berdasarkan Aktivitas

**Pola Penggunaan:**
- Tracking jam aktif user (misal: 08:00-17:00)
- Kirim notifikasi penting di jam aktif
- Tunda notifikasi non-urgent di luar jam aktif

**Benefit:**
- Notifikasi lebih relevan
- Menghindari gangguan di waktu istirahat
- Meningkatkan engagement rate

---

### 2. Etika Notifikasi

#### A. Kapan Notifikasi Dianggap "Spam"?

**🚫 Tanda-tanda Spam:**

1. **Frekuensi Berlebihan**
   - ❌ Lebih dari 5 notifikasi per hari
   - ❌ Notifikasi beruntun dalam 1 menit

2. **Konten Tidak Relevan**
   - ❌ Promosi terus-menerus
   - ❌ Info yang tidak sesuai role user

3. **Waktu Tidak Tepat**
   - ❌ Malam hari (22:00-06:00) untuk non-urgent
   - ❌ Weekend untuk notifikasi rutin

4. **Tidak Bisa Di-kontrol**
   - ❌ Tidak ada opsi unsubscribe
   - ❌ Tidak ada setting preferensi

**✅ Best Practices:**

1. **Kategorisasi Notifikasi**
   ```dart
   enum NotificationCategory {
     critical,    // Stok habis, error system
     important,   // Stok menipis, transaksi besar
     informative, // Laporan harian, tips
     marketing,   // Promo, update fitur
   }
   ```

2. **User Preferences**
   - Biarkan user mengatur kategori mana yang mau diterima
   - Do Not Disturb hours
   - Frekuensi maksimal per hari

3. **Implementasi Setting:**
   ```dart
   class NotificationPreferences {
     bool enableCritical = true;    // Always ON
     bool enableImportant = true;
     bool enableInformative = true;
     bool enableMarketing = false;  // Default OFF
     
     TimeOfDay quietHoursStart = TimeOfDay(hour: 22, minute: 0);
     TimeOfDay quietHoursEnd = TimeOfDay(hour: 7, minute: 0);
     
     int maxNotificationsPerDay = 10;
   }
   ```

#### B. Push vs Local Notifications

| Aspek | Push Notification | Local Notification |
|-------|-------------------|-------------------|
| **Trigger** | Server-side | Client-side |
| **Internet** | Diperlukan | Tidak perlu |
| **Use Case** | Event real-time, broadcast | Pengingat, alarm lokal |
| **Latency** | Tergantung network | Instant |
| **Personalisasi** | Server logic | Client logic |

**Kapan Pakai Push:**
- ✅ Stok update dari sistem pusat
- ✅ Transaksi dari user lain
- ✅ Alert system-wide
- ✅ Broadcast announcement

**Kapan Pakai Local:**
- ✅ Reminder personal (check-in harian)
- ✅ Scheduled task
- ✅ Offline mode
- ✅ Timer/countdown

**Strategi Hybrid:**
```dart
// Push notification dari server untuk data baru
// Tapi jadwalkan local notification untuk reminder

// Contoh: Server kirim "Stok X menipis"
// Client jadwalkan reminder lokal 3 hari kemudian jika belum direstock
```

---

### 3. Studi Kasus: Integrasi dengan Supabase

#### Alur Lengkap: Trigger Otomatis dari Database

**Skenario:**  
Ketika admin lain menambahkan transaksi baru di Supabase, semua admin lain mendapat notifikasi real-time.

#### Arsitektur Integrasi:

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Flutter    │────────▶│   Supabase   │────────▶│  Edge Func  │
│  Client A   │  Insert │   Database   │ Trigger │  (Webhook)  │
│             │  Data   │              │         │             │
└─────────────┘         └──────────────┘         └──────┬──────┘
                                                         │
                                                         │ HTTP POST
                                                         ▼
                                                  ┌─────────────┐
                                                  │   Firebase  │
                                                  │     FCM     │
                                                  │   Server    │
                                                  └──────┬──────┘
                                                         │
                              ┌──────────────────────────┼───────────────┐
                              ▼                          ▼               ▼
                        ┌───────────┐            ┌───────────┐   ┌───────────┐
                        │ Client B  │            │ Client C  │   │ Client D  │
                        │ (Phone 1) │            │ (Phone 2) │   │ (Phone 3) │
                        └───────────┘            └───────────┘   └───────────┘
```

#### Implementasi Step-by-Step:

**Step 1: Buat Database Trigger (Supabase)**

```sql
-- Function untuk send webhook ke FCM
CREATE OR REPLACE FUNCTION notify_stock_change()
RETURNS TRIGGER AS $$
BEGIN
  -- Kirim webhook ke Edge Function
  PERFORM
    net.http_post(
      url := 'https://your-project.supabase.co/functions/v1/send-fcm-notification',
      headers := '{"Content-Type": "application/json", "Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb,
      body := json_build_object(
        'event', TG_OP,
        'table', TG_TABLE_NAME,
        'data', row_to_json(NEW)
      )::jsonb
    );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger ke tabel stock_transactions
CREATE TRIGGER on_stock_transaction_insert
  AFTER INSERT ON stock_transactions
  FOR EACH ROW
  EXECUTE FUNCTION notify_stock_change();
```

**Step 2: Buat Supabase Edge Function**

```typescript
// supabase/functions/send-fcm-notification/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const { event, table, data } = await req.json()
  
  if (table === 'stock_transactions' && event === 'INSERT') {
    const transaction = data
    
    // Call Firebase Admin SDK
    const fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/YOUR_PROJECT/messages:send'
    
    const message = {
      message: {
        topic: 'warehouse_transactions', // Semua admin subscribe
        notification: {
          title: '📦 Transaksi Baru',
          body: `${transaction.type} ${transaction.quantity} unit ${transaction.item_name}`
        },
        data: {
          type: 'new_transaction',
          transaction_id: transaction.id,
          screen: 'transaction'
        },
        android: {
          priority: 'high'
        }
      }
    }
    
    // Send to FCM
    const response = await fetch(fcmEndpoint, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('FCM_SERVER_KEY')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(message)
    })
    
    return new Response(
      JSON.stringify({ success: true }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  }
  
  return new Response('No action taken', { status: 200 })
})
```

**Step 3: Subscribe to Topic di Flutter**

```dart
// Di FCM service initialization
await fcmService.subscribeToTopic('warehouse_transactions');
```

#### Alternatif: Realtime Subscription + Local Push

Jika tidak mau setup Edge Function, bisa gunakan Supabase Realtime:

```dart
// Setup realtime listener
supabase
  .from('stock_transactions')
  .stream(primaryKey: ['id'])
  .listen((data) async {
    // Data baru masuk
    final transaction = data.first;
    
    // Trigger LOCAL notification
    await _localNotifications.show(
      transaction.id.hashCode,
      '📦 Transaksi Baru',
      '${transaction.type} ${transaction.quantity} unit',
      notificationDetails,
    );
  });
```

**Trade-offs:**
- ✅ Lebih simple (no backend logic)
- ❌ Hanya kerja saat app running/background
- ❌ Tidak kerja saat terminated

---

## 🎯 Checklist Pengumpulan

### Implementasi Teknis
- [ ] Firebase project setup
- [ ] `google-services.json` configured
- [ ] `firebase_options.dart` dengan credential valid
- [ ] FCM service dengan GetX structure
- [ ] Local notifications dengan custom sound
- [ ] Notification controller
- [ ] UI untuk notification list & detail
- [ ] Navigation handling dari notifikasi

### Eksperimen
- [ ] Eksperimen 1: Foreground (dengan screenshot & log)
- [ ] Eksperimen 2: Background (dengan screenshot & log)
- [ ] Eksperimen 3: Terminated (dengan screenshot & log)
- [ ] Pengukuran latensi (tabel hasil)
- [ ] Analisis perbedaan latensi

### Dokumentasi
- [ ] Skenario notifikasi sesuai bisnis app
- [ ] Screenshot heads-up notification
- [ ] Screenshot system tray notification
- [ ] Log terminal dengan payload data
- [ ] Screenshot navigasi ke halaman terkait
- [ ] Analisis latency measurement
- [ ] Refleksi user engagement strategy
- [ ] Pembahasan etika notifikasi
- [ ] Studi kasus integrasi dengan backend

---

## 🔍 Testing Checklist

### Manual Testing

**1. Notifikasi Foreground:**
```bash
# Kirim test notification saat app terbuka
# Expected: Heads-up banner muncul dengan sound
```

**2. Notifikasi Background:**
```bash
# Minimize app, kirim notifikasi
# Expected: Notifikasi di system tray, tap -> navigate correctly
```

**3. Notifikasi Terminated:**
```bash
# Force stop app, kirim notifikasi
# Expected: Notifikasi masuk, tap -> cold start -> navigate
```

**4. Custom Sound:**
```bash
# Pastikan sound bukan default system sound
# Cek di Android: Settings > Apps > Streamline > Notifications
```

**5. Navigation:**
```bash
# Test setiap type notifikasi navigate ke screen yang benar
# - low_stock -> inventory with filter
# - out_of_stock -> inventory with filter
# - new_transaction -> transaction tab
# - restock_reminder -> item detail
```

### Debugging Tips

**Jika notifikasi tidak muncul:**
1. Cek permission di Android Settings
2. Lihat logcat: `adb logcat | grep -i fcm`
3. Verifikasi FCM token di log
4. Test dengan Firebase Console "Send test message"

**Jika sound tidak keluar:**
1. Pastikan file ada di `android/app/src/main/res/raw/`
2. Nama file lowercase tanpa spasi
3. Notification channel sudah dibuat
4. HP tidak dalam silent mode

**Jika navigation tidak bekerja:**
1. Cek payload data format
2. Log `_navigateBasedOnPayload` function
3. Pastikan route sudah terdaftar di GetX routes

---

## 📚 Referensi

1. **Firebase Cloud Messaging:**
   - [FCM Documentation](https://firebase.google.com/docs/cloud-messaging)
   - [Flutter Firebase](https://firebase.flutter.dev/docs/messaging/overview/)

2. **Flutter Local Notifications:**
   - [Package Documentation](https://pub.dev/packages/flutter_local_notifications)
   - [Android Notification Channels](https://developer.android.com/training/notify-user/channels)

3. **GetX State Management:**
   - [GetX Documentation](https://pub.dev/packages/get)
   - [GetX Pattern Guide](https://github.com/jonataslaw/getx#the-three-pillars)

4. **Supabase Integration:**
   - [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
   - [Database Triggers](https://supabase.com/docs/guides/database/triggers)

---

## 🎓 Kesimpulan

Sistem notifikasi push telah berhasil diimplementasikan dengan:

✅ **Arsitektur Modular** - Menggunakan GetX pattern (Service, Controller, View)  
✅ **Lifecycle Handling** - Foreground, Background, dan Terminated state  
✅ **Custom Sound** - Suara notifikasi yang unik  
✅ **Smart Navigation** - Context-aware routing berdasarkan payload  
✅ **Business Integration** - Terintegrasi dengan alur warehouse management  
✅ **User Engagement** - Strategi untuk meningkatkan retensi  
✅ **Ethical Design** - Mempertimbangkan user experience dan privacy

Sistem ini siap untuk production dengan kemampuan scale ke ribuan user menggunakan Firebase Cloud Messaging infrastructure.

---

**Dibuat untuk:** Modul 6 - Push Notification  
**Aplikasi:** Streamline Warehouse Management  
**Tanggal:** Desember 2024  
**Tech Stack:** Flutter + GetX + Firebase FCM + Supabase
