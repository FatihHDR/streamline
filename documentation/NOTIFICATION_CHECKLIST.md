# 📋 Module 6 - Notification Implementation Checklist

## 🔧 Setup Tasks

### Firebase Configuration
- [ ] **Step 1:** Buka Firebase Console (https://console.firebase.google.com/)
- [ ] **Step 2:** Buat/pilih project Firebase
- [ ] **Step 3:** Tambahkan aplikasi Android
- [ ] **Step 4:** Download `google-services.json`
- [ ] **Step 5:** Place `google-services.json` di `android/app/`
- [ ] **Step 6:** Copy Firebase credentials ke `lib/firebase_options.dart`
  - [ ] apiKey
  - [ ] appId
  - [ ] messagingSenderId
  - [ ] projectId
  - [ ] storageBucket

### Custom Sound Setup
- [ ] **Step 1:** Download atau buat custom sound (1-3 detik, MP3)
- [ ] **Step 2:** Rename file ke `notification_sound.mp3`
- [ ] **Step 3:** Place di `assets/sounds/notification_sound.mp3`
- [ ] **Step 4:** Place di `android/app/src/main/res/raw/notification_sound.mp3`

### Build & Install
- [ ] **Step 1:** Run `flutter pub get`
- [ ] **Step 2:** Run `flutter clean`
- [ ] **Step 3:** Run `flutter run` atau build APK
- [ ] **Step 4:** Verify app launches successfully
- [ ] **Step 5:** Check logs for FCM token

---

## 🧪 Eksperimen 1: Foreground

### Setup
- [ ] Open app dan biarkan di halaman Home
- [ ] Catat waktu sebelum mengirim notifikasi

### Testing Steps
- [ ] Buka Firebase Console > Cloud Messaging
- [ ] Klik "Send your first message"
- [ ] Fill:
  - Title: "🧪 Test Foreground"
  - Body: "Testing notifikasi foreground"
- [ ] Target: Single device (paste FCM token)
- [ ] Click "Send"
- [ ] Catat waktu notifikasi diterima

### Verification
- [ ] ✅ Heads-up notification muncul di atas layar
- [ ] ✅ Custom sound terdengar (bukan default)
- [ ] ✅ Log terminal menampilkan:
  - [ ] `📱 [FOREGROUND] Message received!`
  - [ ] `📱 [FOREGROUND] Title: ...`
  - [ ] `📱 [FOREGROUND] Data: ...`
- [ ] ✅ Notification muncul di system tray

### Screenshots to Capture
- [ ] Screenshot: Heads-up banner di layar
- [ ] Screenshot: System tray notification
- [ ] Screenshot: Log terminal dengan payload

### Measurements
- [ ] Waktu kirim: __:__:__
- [ ] Waktu terima: __:__:__
- [ ] Latensi: ______ detik

---

## 🧪 Eksperimen 2: Background

### Setup
- [ ] App terbuka di Home
- [ ] Press tombol Home (minimize app)
- [ ] Verify app di Recent Apps (tidak di-kill)

### Testing Steps
- [ ] Kirim notifikasi dari Firebase Console:
  ```json
  Title: "🧪 Test Background"
  Body: "Testing background notification"
  Data: {
    "type": "low_stock",
    "screen": "inventory"
  }
  ```
- [ ] Catat waktu kirim dan terima

### Verification
- [ ] ✅ Notification masuk ke system tray
- [ ] ✅ Sound dan vibration aktif
- [ ] ✅ Tap notification
- [ ] ✅ App terbuka kembali (tidak cold start)
- [ ] ✅ Navigasi otomatis ke halaman inventory
- [ ] ✅ Log menampilkan:
  - [ ] `📱 [BACKGROUND] Handling message: ...`
  - [ ] `📱 [BACKGROUND TAP] Notification opened!`
  - [ ] `🧭 Navigating to: /home`

### Screenshots to Capture
- [ ] Screenshot: Notification di system tray
- [ ] Screenshot: App membuka halaman inventory
- [ ] Screenshot: Log navigation

### Measurements
- [ ] Waktu kirim: __:__:__
- [ ] Waktu terima: __:__:__
- [ ] Latensi: ______ detik

---

## 🧪 Eksperimen 3: Terminated

### Setup
- [ ] Force stop app dari Recent Apps (swipe up)
- [ ] Or: Settings > Apps > Streamline > Force Stop
- [ ] Verify app tidak muncul di Recent Apps

### Testing Steps
- [ ] Kirim notifikasi dari Firebase Console:
  ```json
  Title: "🧪 Test Terminated"
  Body: "Testing terminated state"
  Data: {
    "type": "new_transaction",
    "screen": "transaction"
  }
  ```
- [ ] Catat waktu kirim

### Verification
- [ ] ✅ Notification tetap masuk meskipun app mati
- [ ] ✅ Notification tampil di system tray
- [ ] ✅ Tap notification
- [ ] ✅ App melakukan cold start (splash screen muncul)
- [ ] ✅ Setelah load, navigasi ke halaman transaction
- [ ] ✅ Log menampilkan:
  - [ ] `🔔 Initializing FCM Notification Service...`
  - [ ] `📱 [TERMINATED TAP] App opened from notification!`
  - [ ] `🧭 Navigating to: ...`

### Screenshots to Capture
- [ ] Screenshot: Notification saat app killed
- [ ] Screenshot: Splash screen saat app dibuka
- [ ] Screenshot: Navigasi ke halaman transaksi
- [ ] Screenshot: Full log dari cold start ke navigation

### Measurements
- [ ] Waktu kirim: __:__:__
- [ ] Waktu terima: __:__:__
- [ ] Latensi: ______ detik

---

## 📊 Analisis Latensi

### Data Collection
| Kondisi | Waktu Kirim | Waktu Terima | Latensi | Keterangan |
|---------|-------------|--------------|---------|------------|
| Foreground | | | | |
| Background | | | | |
| Terminated | | | | |

### Analysis Questions
- [ ] Kondisi mana yang paling cepat? Mengapa?
- [ ] Perbedaan latensi Background vs Terminated?
- [ ] Pengaruh koneksi internet (WiFi vs mobile data)?
- [ ] Pengaruh Android Doze Mode?
- [ ] Pengaruh message priority (high vs normal)?

### Write Analysis
- [ ] Tulis penjelasan perbedaan latensi
- [ ] Hubungkan dengan Android Doze Mode
- [ ] Jelaskan prioritas FCM
- [ ] Diskusikan faktor-faktor lain yang mempengaruhi

---

## 📝 Dokumentasi Laporan

### Skenario Uji
- [ ] Dokumentasikan semua 3 eksperimen
- [ ] Jelaskan setup untuk setiap eksperimen
- [ ] Catat hasil observasi

### Bukti Implementasi
- [ ] Kumpulkan semua screenshot
- [ ] Kumpulkan log terminal
- [ ] Capture tampilan notifikasi
- [ ] Record navigation behavior

### Analisis Perbandingan
- [ ] Buat tabel perbandingan
- [ ] Analisis perbedaan perilaku
- [ ] Jelaskan alasan teknis
- [ ] Referensi dokumentasi Android/Firebase

---

## 💭 Refleksi

### User Engagement Strategy
- [ ] Bagaimana notifikasi meningkatkan retensi?
- [ ] Strategi untuk user yang tidak aktif 3 hari?
- [ ] Smart notification berdasarkan pola penggunaan?
- [ ] Personalisasi berdasarkan role user?

### Etika Notifikasi
- [ ] Kapan notifikasi dianggap spam?
- [ ] Berapa frekuensi ideal per hari?
- [ ] Waktu terbaik kirim notifikasi?
- [ ] Push vs Local notification - kapan pakai masing-masing?
- [ ] User control dan preferences?

### Studi Kasus Integrasi
- [ ] Jelaskan alur trigger dari Supabase
- [ ] Contoh: Data baru → Trigger → FCM → Notification
- [ ] Implementasi dengan Edge Function atau Realtime
- [ ] Trade-offs berbagai approach

---

## 🎯 Business Scenarios (Streamline)

### Low Stock Notification
- [ ] Payload format sudah benar
- [ ] Navigation ke inventory + filter
- [ ] User bisa langsung lihat barang yang perlu direstock

### Out of Stock Notification
- [ ] Payload format sudah benar
- [ ] Navigation ke inventory + filter
- [ ] Alert yang mendesak untuk restok

### New Transaction Notification
- [ ] Payload format sudah benar
- [ ] Navigation ke transaction history
- [ ] Real-time update untuk semua admin

### Restock Reminder
- [ ] Payload format sudah benar
- [ ] Navigation ke detail barang
- [ ] Scheduled reminder lokal

---

## ✅ Final Checklist

### Code Quality
- [ ] Semua imports resolved
- [ ] No compilation errors
- [ ] Code follows GetX patterns
- [ ] Proper error handling
- [ ] Logs are informative

### Functionality
- [ ] All 3 lifecycle states work
- [ ] Navigation works correctly
- [ ] Custom sound plays
- [ ] UI is responsive
- [ ] State management works

### Documentation
- [ ] All experiments documented
- [ ] Screenshots collected
- [ ] Logs captured
- [ ] Analysis written
- [ ] Reflection completed

### Submission Ready
- [ ] Laporan lengkap
- [ ] Screenshot berkualitas baik
- [ ] Log terminal jelas
- [ ] Analisis mendalam
- [ ] Refleksi bisnis relevan

---

## 📚 Resources Reference

### Documentation Files
- [ ] Read: `MODULE_6_NOTIFICATION_GUIDE.md`
- [ ] Read: `NOTIFICATION_QUICKSTART.md`
- [ ] Read: `NOTIFICATION_SOUND_SETUP.md`
- [ ] Read: `NOTIFICATION_IMPLEMENTATION_SUMMARY.md`

### Code Files
- [ ] Review: `fcm_notification_service.dart`
- [ ] Review: `notification_controller.dart`
- [ ] Review: `notification_list_screen.dart`
- [ ] Review: `notification_detail_screen.dart`

### External Resources
- [ ] Firebase Console: https://console.firebase.google.com/
- [ ] FCM Docs: https://firebase.google.com/docs/cloud-messaging
- [ ] Flutter Firebase: https://firebase.flutter.dev/
- [ ] GetX Docs: https://pub.dev/packages/get

---

**Progress: __ / __ tasks completed**

**Notes:**
- Keep all screenshots organized by experiment
- Save all logs in text files
- Document any issues encountered
- Note any modifications made to code

**Good luck with your Module 6 submission! 🎉**
