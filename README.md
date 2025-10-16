# Streamline - Aplikasi Manajemen Stok Gudang

![Streamline Logo](https://img.shields.io/badge/Streamline-Warehouse%20Management-5F6C7B?style=for-the-badge)

Aplikasi mobile modern untuk manajemen stok barang gudang yang dibangun dengan Flutter. Streamline menyediakan solusi digital yang efisien dengan tampilan interaktif dan animasi yang halus.

## 🎯 Fitur Utama

### Dashboard Interaktif
- **Statistik Real-time**: Monitoring total item, kuantitas, stok menipis, dan stok habis
- **Grafik Aktivitas**: Visualisasi aktivitas stok 7 hari terakhir
- **Peringatan Otomatis**: Notifikasi untuk barang dengan stok menipis atau habis
- **Dual Animation Mode**: Pilihan antara AnimatedContainer dan AnimationController

### Manajemen Stok
- **Daftar Barang Lengkap**: Lihat semua barang dengan detail lengkap
- **Pencarian & Filter**: Cari barang berdasarkan nama dan filter berdasarkan kategori
- **Status Real-time**: Indikator visual untuk status ketersediaan (Tersedia, Menipis, Habis)
- **Detail Barang**: Informasi lengkap termasuk lokasi, kategori, dan deskripsi

### Riwayat Transaksi
- **Tracking Barang Masuk/Keluar**: Catat semua pergerakan barang
- **Filter Transaksi**: Filter berdasarkan jenis transaksi (Masuk/Keluar)
- **Detail Transaksi**: Informasi lengkap termasuk waktu, penanggung jawab, dan catatan

## 🎨 Mode Animasi

Aplikasi ini dilengkapi dengan **2 mode animasi** yang dapat dibandingkan:

### 1. AnimatedContainer Mode
- Menggunakan widget `AnimatedContainer` untuk transisi halus
- Animasi implisit yang mudah diimplementasikan
- Cocok untuk animasi sederhana dan perubahan properti widget
- Contoh: Perubahan ukuran, warna, border radius

### 2. AnimationController Mode
- Menggunakan `AnimationController` untuk kontrol animasi yang lebih detail
- Animasi eksplisit dengan timing dan curve yang dapat dikustomisasi
- Mendukung animasi kompleks dan sekuensial
- Contoh: Scale, rotation, fade, dan slide transitions

**Cara mengubah mode**: Tap icon animasi di pojok kanan atas AppBar

## 🎨 Tema & Desain

Aplikasi menggunakan skema warna yang terinspirasi dari logo Streamline:

- **Primary Color**: `#5F6C7B` (Slate Gray)
- **Primary Dark**: `#4A5568`
- **Primary Light**: `#8B95A5`
- **Accent Color**: `#7C8A99`

Status Colors:
- **Success**: `#48BB78` (Hijau)
- **Warning**: `#ED8936` (Orange)
- **Danger**: `#F56565` (Merah)
- **Info**: `#4299E1` (Biru)

## 📱 Screenshots

### Dashboard
- Tampilan statistik dengan animasi card
- Grafik interaktif dengan tap detection
- Alert stok menipis dengan animasi expand/collapse

### Stok Barang
- Grid kategori dengan animasi selection
- Search bar dengan animasi focus
- Card list dengan staggered animation

### Riwayat Transaksi
- Tab filter dengan animasi transisi
- Timeline transaksi dengan slide animation
- Detail modal dengan smooth transition

## 🚀 Teknologi

- **Framework**: Flutter 3.8.0+
- **Language**: Dart
- **Architecture**: Widget-based with State Management
- **Animation**: AnimatedContainer & AnimationController
- **UI Components**: Material Design 3

## 📦 Instalasi

1. Clone repository:
```bash
git clone https://github.com/FatihHDR/streamline.git
cd streamline
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run aplikasi:
```bash
flutter run
```

## 📁 Struktur Proyek

```
lib/
├── main.dart                          # Entry point aplikasi
├── data/
│   └── dummy_data.dart               # Data dummy untuk testing
├── models/
│   ├── stock_item.dart               # Model barang
│   └── stock_transaction.dart        # Model transaksi
├── screens/
│   ├── home_screen.dart              # Halaman utama dengan navigation
│   ├── dashboard_animated_container.dart    # Dashboard mode AnimatedContainer
│   ├── dashboard_animation_controller.dart  # Dashboard mode AnimationController
│   ├── stock_list_screen.dart        # Halaman daftar stok
│   └── transaction_history_screen.dart      # Halaman riwayat transaksi
├── utils/
│   └── app_theme.dart                # Tema & konstanta warna
└── widgets/
    ├── animation_mode_selector.dart   # Selector mode animasi
    ├── stat_card_animated.dart        # Card statistik (AnimatedContainer)
    ├── stat_card_controller.dart      # Card statistik (AnimationController)
    ├── stock_chart_animated.dart      # Chart (AnimatedContainer)
    ├── stock_chart_controller.dart    # Chart (AnimationController)
    ├── low_stock_alert_animated.dart  # Alert (AnimatedContainer)
    └── low_stock_alert_controller.dart # Alert (AnimationController)
```

## 🎯 Use Cases

### Admin Gudang
- Monitor stok secara real-time
- Input barang masuk dan keluar
- Cek status ketersediaan barang
- Lihat riwayat transaksi

### Manajer
- Analisis tren aktivitas stok
- Review peringatan stok menipis
- Monitor performa gudang

### Staf Logistik
- Cari dan cek ketersediaan barang
- Catat pergerakan barang
- Update status stok

## 🔧 Pengembangan Selanjutnya

- [ ] Integrasi dengan backend API
- [ ] Database lokal dengan SQLite
- [ ] Export laporan ke PDF/Excel
- [ ] Barcode scanner untuk input barang
- [ ] Notifikasi push untuk alert
- [ ] Multi-user authentication
- [ ] Dark mode support
- [ ] Internationalization (i18n)

## 📄 License

Copyright © 2025 Streamline. All rights reserved.

## 👨‍💻 Developer

Developed with ❤️ using Flutter

---

**Streamline** - Simplifying Warehouse Management
