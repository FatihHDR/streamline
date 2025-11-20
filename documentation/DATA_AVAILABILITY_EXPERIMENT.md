# Eksperimen Ketersediaan Data

Eksperimen ini membantu membandingkan ketahanan data lokal (SharedPreferences & Hive) dengan data cloud (Supabase) pada berbagai kondisi jaringan dan perangkat. Gunakan panduan ini sebelum presentasi atau sesi demo agar setiap skenario terdokumentasi rapi.

---

## 1. Prasyarat Teknis

| Komponen | Keterangan |
| --- | --- |
| Flutter SDK | Versi 3.8.0+ (mengikuti `environment` pada `pubspec.yaml`) |
| Paket yang diperlukan | Tambahkan ke `pubspec.yaml` jika belum ada:<br>`shared_preferences: ^2.2.3`<br>`hive: ^2.2.3` & `hive_flutter: ^1.1.0`<br>`supabase_flutter: ^2.5.6` |
| Inisialisasi awal | Di `main.dart`, jalankan:<br>```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    headers: {
      'apikey': dotenv.env['SUPABASE_ANON_KEY']!,
    },
  );
  runApp(const StreamlineApp());
}
``` |
| Lokasi penyimpanan lokal | - `SharedPreferences` → simpan preferensi sederhana (mis. mode animasi terakhir)<br>- `Hive` → simpan cache item stok dan riwayat transaksi |
| Catatan implementasi | Buat adapter Hive untuk `StockItem` & `StockTransaction`. Gunakan box terpisah agar mudah diuji (mis. `itemsBox`, `txBox`). |

> **Catatan**: Saat ini repositori belum mengandung penggunaan SharedPreferences, Hive, maupun Supabase. Pastikan modul penyimpanan sudah diimplementasikan sebelum menjalankan eksperimen ini.

---

## 2. Konfigurasi `.env` (Supabase + IPv4 Pooler)

Buat file `.env` di root proyek (tidak dikomit). Template:

```
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_ANON_KEY=<anon-public-key>
SUPABASE_IPV4_HOST=<project-ref>.supabase.co
SUPABASE_POOLER_PORT=6543
SUPABASE_SERVICE_ROLE=<opsional-jika-butuh>
SUPABASE_DB_SCHEMA=public
```

### Tips
- Gunakan **IPv4 pooler** (`SUPABASE_IPV4_HOST`) bila jaringan kampus mengharuskan jalur IPv4 statis. Gunakan port 6543 (default pgbouncer).
- Simpan host/port tambahan ini pada service Supabase Anda, contoh:
  ```dart
  final pooler = '${dotenv.env['SUPABASE_IPV4_HOST']}:${dotenv.env['SUPABASE_POOLER_PORT'] ?? '6543'}';
  ```
- Jangan log kredensial di konsol. Pakai `logger` untuk menampilkan kode status saja.

---

## 3. Eksperimen Mode Offline

### Tujuan
Memastikan data lokal masih dapat dibaca/ditulis saat internet mati, sekaligus mengevaluasi fallback fitur Supabase.

### Persiapan
1. **Seed data lokal**
   - Pastikan box Hive sudah berisi minimal 5 `StockItem` & 5 `StockTransaction`.
   - Simpan preferensi sederhana di `SharedPreferences` (mis. `animation_mode=controller`).
2. **Pastikan Supabase tersambung** untuk mengisi cache sebelum jaringan dimatikan.
3. Siapkan lembar observasi (lihat tabel di bawah) + aktifkan logging (`logger` / `flutter logs`).

### Langkah Eksperimen
| Langkah | Detail |
| --- | --- |
| 1 | Jalankan aplikasi (online). Pastikan data tersinkron dan cache lokal terisi. |
| 2 | Aktifkan mode pesawat / matikan Wi-Fi & data seluler. Verifikasi perangkat benar-benar offline. |
| 3 | Buka modul **Daftar Stok** → pastikan daftar tampil dari Hive. |
| 4 | Edit satu item (mis. ubah `quantity`). Simpan ke Hive dan cek apakah perubahan bertahan setelah hot-restart. |
| 5 | Buka modul **Riwayat Transaksi**, tambahkan transaksi dummy ke Hive. |
| 6 | Buka shared settings (mis. toggle mode animasi) dan pastikan nilainya terbaca setelah restart aplikasi. |
| 7 | Jalankan fitur yang memanggil Supabase (mis. sinkronisasi manual). Catat error/fallback UI. |

### Observasi yang Dicatat
| Komponen | Bisa Dibaca? | Bisa Ditulis? | Catatan/Error |
| --- | --- | --- | --- |
| SharedPreferences |  |  |  |
| Hive Items Box |  |  |  |
| Hive Tx Box |  |  |  |
| Supabase Sync |  |  |  |

### Validasi Tambahan
- Pastikan UI menampilkan banner "Offline" atau snackbar error saat Supabase gagal.
- Periksa log: request Supabase seharusnya gagal dengan `SocketException`. Pastikan aplikasi menangkap error tersebut dan tidak crash.

---

## 4. Eksperimen Mode Multi-Device (Supabase)

### Tujuan
Mengamati konsistensi data cloud ketika dua perangkat menggunakan akun Supabase yang sama.

### Persiapan
1. **Device A & B**: Bisa berupa emulator berbeda atau kombinasi emulator + fisik.
2. **Masuk dengan kredensial sama** (mis. `inventory-admin@streamline.dev`).
3. Pastikan kedua perangkat sudah menerima seed data terbaru (jalankan refresh sebelum eksperimen).
4. Sediakan tombol/aksi sinkronisasi manual (mis. `pull to refresh` yang memanggil Supabase → controller → Hive cache).

### Prosedur
| Langkah | Perangkat A | Perangkat B |
| --- | --- | --- |
| 1 | Tambahkan catatan/`StockItem` baru via Supabase RPC/API. | Diam di halaman yang sama. |
| 2 | Tekan refresh setelah perubahan tersimpan. | Setelah A selesai, lakukan refresh/scroll agar memicu fetch. |
| 3 | Edit data yang sama (mis. ubah quantity) lalu simpan. | Validasikan perubahan muncul. |
| 4 | Hapus item yang tadi dibuat di A. | Jalankan refresh → item harus hilang. |

### Log Observasi
| Aksi | Waktu A | Waktu B menerima | Status sinkronisasi |
| --- | --- | --- | --- |
| Tambah |  |  |  |
| Edit |  |  |  |
| Hapus |  |  |  |

### Hal yang Diverifikasi
- Tidak ada duplikasi data saat dua perangkat melakukan perubahan bersamaan.
- Jika konflik terjadi, catat strategi resolusi (mis. last-write-wins).
- Pastikan cache Hive diperbarui setelah setiap fetch agar offline mode tetap menampilkan data terbaru.

---

## 5. Dokumentasi & Pelaporan
Setelah dua eksperimen selesai:
1. Simpan log terminal (`flutter run -d <device> > logs/offline.txt`).
2. Export screenshot bukti (offline banner, perubahan sinkron).
3. Lengkapi tabel observasi dan lampirkan pada laporan atau wiki internal.
4. Catat isu yang ditemukan + langkah mitigasi yang diusulkan.

---

## 6. Troubleshooting Cepat
| Masalah | Solusi |
| --- | --- |
| `.env` tidak terbaca | Pastikan `flutter_dotenv` dipanggil sebelum `runApp` dan file `.env` berada di root. |
| Tidak bisa konek pooler IPv4 | Pastikan firewall lokal tidak memblokir port 6543. Gunakan IP publik Supabase, bukan domain default IPv6. |
| Hive tidak memuat adapter | Registrasikan adapter (`Hive.registerAdapter(StockItemAdapter())`) sebelum membuka box. |
| SharedPreferences gagal menyimpan | Pastikan operasi dijalankan setelah `WidgetsFlutterBinding.ensureInitialized()`. |
| Data tidak sinkron antar perangkat | Verifikasi `SupabaseClient` menggunakan channel yang sama dan refresh dipanggil setelah mutasi. Tambahkan notifikasi real-time (`SupabaseChannel`) bila dibutuhkan. |

---

Dengan mengikuti panduan ini, Anda dapat menunjukkan perbedaan nyata antara data yang hanya hidup di perangkat (lokal) dan data cloud yang sinkron lintas perangkat secara terukur dan terdokumentasi.
