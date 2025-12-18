# 🚀 Quick Setup Guide - Push Notifications

## Langkah Cepat (5 Menit)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase

#### A. Update `lib/firebase_options.dart`

Ganti placeholder dengan credential dari Firebase Console:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...',           // ← Ganti ini
  appId: '1:123456...',          // ← Ganti ini
  messagingSenderId: '123456789', // ← Ganti ini
  projectId: 'your-project-id',   // ← Ganti ini
  storageBucket: 'your-project.appspot.com', // ← Ganti ini
);
```

**Cara mendapatkan:**
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Settings ⚙️ > Project Settings > General
4. Scroll ke "Your apps" > Android app
5. Copy semua values

#### B. Download `google-services.json`

1. Di Firebase Console > Project Settings
2. Download `google-services.json`
3. Letakkan di: `android/app/google-services.json`

### 3. Setup Custom Sound

**Download sample sound atau gunakan milik Anda:**
- Format: MP3 atau WAV
- Durasi: 1-3 detik
- Nama file: **notification_sound.mp3**

**Letakkan di 2 tempat:**
1. `assets/sounds/notification_sound.mp3`
2. `android/app/src/main/res/raw/notification_sound.mp3`

### 4. Build & Run

```bash
flutter clean
flutter pub get
flutter run
```

### 5. Test Notifikasi

#### Cara 1: Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Cloud Messaging > Send your first message
3. Title: "Test Notification"
4. Target: Copy FCM token dari app log

#### Cara 2: Dalam App
1. Buka app
2. Menu notifikasi
3. Klik "Test Notification" di menu (⋮)

## 🔍 Troubleshooting

### Notifikasi tidak muncul?

**Check 1:** Permission
```bash
# Lihat di Android Settings > Apps > Streamline > Permissions
# Pastikan "Notifications" ON
```

**Check 2:** FCM Token
```bash
# Lihat log saat app start
# Cari: "🔑 FCM Token: ..."
# Gunakan token ini untuk testing
```

**Check 3:** Logcat
```bash
adb logcat | grep -E "fcm|firebase|notification"
```

### Sound tidak keluar?

1. ✅ File ada di `android/app/src/main/res/raw/notification_sound.mp3`
2. ✅ Nama file lowercase, tanpa spasi
3. ✅ HP tidak silent mode
4. ✅ Notification channel priority = HIGH

### Navigation tidak jalan?

1. ✅ Payload data format benar
2. ✅ Check log: `🧭 Navigating based on payload`
3. ✅ Routes terdaftar di `main.dart`

## 📱 Testing Scenarios

### Test 1: Foreground
- App terbuka
- Kirim notif
- ✅ Heads-up banner muncul
- ✅ Sound keluar
- ✅ Log payload terlihat

### Test 2: Background
- Minimize app (home button)
- Kirim notif
- ✅ System tray notification
- Tap → ✅ App buka & navigate

### Test 3: Terminated
- Force stop app
- Kirim notif
- ✅ Notif tetap masuk
- Tap → ✅ Cold start → navigate

## 📋 Example Payloads

### Stok Menipis
```json
{
  "notification": {
    "title": "⚠️ Stok Menipis",
    "body": "Laptop Asus tersisa 5 unit"
  },
  "data": {
    "type": "low_stock",
    "item_id": "abc123",
    "screen": "inventory"
  }
}
```

### Transaksi Baru
```json
{
  "notification": {
    "title": "📦 Transaksi Baru",
    "body": "Barang masuk: Mouse Logitech 50 unit"
  },
  "data": {
    "type": "new_transaction",
    "transaction_id": "txn789",
    "screen": "transaction"
  }
}
```

## 📖 Full Documentation

Lihat dokumentasi lengkap di:
- [`documentation/MODULE_6_NOTIFICATION_GUIDE.md`](./MODULE_6_NOTIFICATION_GUIDE.md)

## 🆘 Need Help?

1. Check log dengan: `flutter run -v`
2. Lihat Firebase Console > Cloud Messaging > Reports
3. Review dokumentasi lengkap

---

**Status:** ✅ Ready for Testing  
**Last Updated:** Desember 2024
