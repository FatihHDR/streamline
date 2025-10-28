# 📊 Performance Benchmark Guide - Streamline App

## 🎯 Tujuan

Mengisi tabel perbandingan performance antara **AnimatedContainer** vs **AnimationController**:

| Jenis Animasi | Rata-rata CPU (%) | Rata-rata GPU (%) | Kompleksitas Implementasi |
|---------------|-------------------|-------------------|---------------------------|
| **AnimatedContainer** | ? | ? | Mudah, kode singkat |
| **AnimationController** | ? | ? | Lebih kompleks, kontrol penuh |

---

## 🔍 Cara Mengukur di DevTools

### 📍 **Anda Sudah Di DevTools? Perfect!**

---

## 🎬 STEP-BY-STEP: Ukur CPU & GPU

### **STEP 1: Buka Performance Tab**

1. Di DevTools, klik tab **"Performance"** (atau **"CPU Profiler"**)
2. Pastikan aplikasi masih running di device

---

### **STEP 2: Test AnimatedContainer Mode**

#### A. **Persiapan:**

1. **Di aplikasi (device):**
   - Tap icon animasi di kanan atas
   - Pilih **"AnimatedContainer"**
   - Pastikan sudah di Dashboard

2. **Di DevTools:**
   - Klik button **"Record"** (ikon merah ●)
   - Status berubah jadi "Recording..."

#### B. **Lakukan Interaksi (30 detik):**

Lakukan aktivitas ini berulang kali:
```
✅ Tap 4 StatCard (satu per satu)
✅ Expand header (tap judul "Warehouse Management")
✅ Collapse header
✅ Tap Low Stock Alert
✅ Scroll stock chart
✅ Ulangi 3-5 kali
```

**Timer: 30 detik** (gunakan stopwatch)

#### C. **Stop Recording:**

1. Klik button **"Stop"** di DevTools
2. Tunggu profiling data di-load
3. DevTools akan menampilkan **timeline**

---

### **STEP 3: Analisa Data AnimatedContainer**

#### 🔍 **Lihat di Timeline:**

Di performance timeline, Anda akan lihat:

```
┌─────────────────────────────────────┐
│ Frame Rendering Timeline            │
│ ▂▃▂▃▅▄▃▂▃▄▃▂▅▄▃▂▃▄▃▂▃▄▃▂           │ ← Frame bars
│ ■■■■■■■■■■■■■■■■■■■■■■■             │ ← CPU/GPU usage
└─────────────────────────────────────┘
```

**Warna Bars:**
- 🟢 **Hijau** = < 16ms (60 FPS) ✅ BAGUS
- 🟡 **Kuning** = 16-32ms (30-60 FPS) ⚠️ WARNING
- 🔴 **Merah** = > 32ms (< 30 FPS) ❌ JANK

---

#### 📊 **Cara Lihat CPU Usage:**

**Option 1: Flutter Performance View**

1. Di timeline, lihat section **"Frame Rendering Chart"**
2. Hover mouse ke bars
3. Tooltip akan muncul:
   ```
   Frame #123
   Total: 8.5ms
   Build: 2.1ms ← CPU intensive
   Layout: 1.8ms ← CPU intensive
   Paint: 2.3ms ← GPU intensive
   Rasterization: 2.3ms ← GPU intensive
   ```

4. **Hitung Manual:**
   - **CPU** = Build + Layout + Composition
   - **GPU** = Paint + Rasterization

**Option 2: CPU Flame Chart**

1. Klik salah satu frame di timeline
2. Di bawah, Anda akan lihat **"CPU Flame Chart"**
3. Ini menunjukkan breakdown CPU usage
4. Lihat **"Total CPU time"** di summary

---

#### 📊 **Cara Lihat GPU Usage:**

**Di Flutter, GPU Rasterization:**

1. Scroll timeline ke section **"GPU"** atau **"Rasterizer"**
2. Lihat bars di GPU section
3. Hover untuk lihat **GPU frame time**

**Contoh Reading:**
```
GPU Frame Time: 4.2ms
Rasterizer: 3.8ms
Other: 0.4ms
```

---

#### 📝 **Catat Hasilnya:**

**Buat spreadsheet atau note:**

```
=== AnimatedContainer ===
Recording Duration: 30 seconds
Total Frames: ~1800 (60 FPS × 30s)

Frame Times:
- Average: 8.5ms
- Min: 3.2ms
- Max: 14.8ms
- Dropped frames: 5

CPU Breakdown:
- Build: 2.1ms
- Layout: 1.8ms
- Composition: 0.5ms
- Total CPU: 4.4ms

GPU Breakdown:
- Paint: 2.3ms
- Rasterization: 1.8ms
- Total GPU: 4.1ms

Jank Count: 0 (good!)
```

**Atau Lihat di DevTools Summary Panel:**

DevTools biasanya menampilkan summary otomatis:
- Average frame time
- Jank count
- CPU/GPU breakdown

---

### **STEP 4: Test AnimationController Mode**

Ulangi STEP 2 & 3, tapi dengan **AnimationController mode**:

1. **Di aplikasi:**
   - Tap icon animasi
   - Pilih **"AnimationController"**
   
2. **Record** performance (30 detik)

3. **Lakukan interaksi yang sama:**
   ```
   ✅ Tap 4 StatCard
   ✅ Expand/collapse header
   ✅ Tap alerts
   ✅ Scroll chart
   ✅ Ulangi 3-5 kali
   ```

4. **Stop & Analisa**

5. **Catat hasilnya** (format sama seperti AnimatedContainer)

---

## 🧮 Cara Hitung Rata-Rata CPU & GPU (%)

### **Formula:**

```
CPU Usage (%) = (Total CPU Time / Total Frame Time) × 100
GPU Usage (%) = (Total GPU Time / Total Frame Time) × 100
```

### **Contoh Perhitungan:**

**AnimatedContainer:**
```
Average Frame Time: 8.5ms
CPU Time: 4.4ms (Build 2.1 + Layout 1.8 + Comp 0.5)
GPU Time: 4.1ms (Paint 2.3 + Raster 1.8)

CPU % = (4.4 / 8.5) × 100 = 51.8%
GPU % = (4.1 / 8.5) × 100 = 48.2%
```

**AnimationController:**
```
Average Frame Time: 9.2ms
CPU Time: 5.1ms
GPU Time: 4.1ms

CPU % = (5.1 / 9.2) × 100 = 55.4%
GPU % = (4.1 / 9.2) × 100 = 44.6%
```

---

## 📊 Alternative: Performance Overlay

### **Aktifkan Performance Overlay di App:**

Cara lebih simple untuk lihat FPS real-time:

#### **Option 1: Via DevTools**

1. Klik tab **"Flutter Inspector"**
2. Cari button **"Performance Overlay"**
3. Toggle ON

#### **Option 2: Via Code (Recommended)**

Edit `lib/main.dart`:

```dart
class StreamlineApp extends StatelessWidget {
  const StreamlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamline - Warehouse Management',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      
      // 🔥 TAMBAHKAN INI 🔥
      showPerformanceOverlay: true,
      
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**Hot Reload** (tekan `r` di terminal)

**Anda akan lihat overlay di app:**
```
┌─────────────────┐
│ 60.0 FPS        │ ← GPU
│ 12.5ms          │
├─────────────────┤
│ 60.0 FPS        │ ← UI (CPU)
│ 8.3ms           │
└─────────────────┘
```

**Top Graph** = GPU Rasterization
**Bottom Graph** = UI Thread (CPU)

---

## 📊 Performance Overlay - Cara Baca

### **Graph Bars:**

```
GPU: ▂▃▂▃▅▄▃▂ (green = good)
UI:  ▂▂▃▂▃▂▂▂ (green = good)
```

- **Hijau** = < 16ms (60 FPS) ✅
- **Merah** = > 16ms (< 60 FPS) ❌

### **Catat Data dengan Overlay:**

**Test 1: AnimatedContainer**
1. Enable overlay
2. Switch ke AnimatedContainer mode
3. Interact selama 1 menit
4. **Amati:**
   - GPU graph mostly green? Red spikes?
   - UI graph mostly green?
5. **Screenshot** atau **catat:**
   ```
   AnimatedContainer:
   - GPU: Mostly green, occasional yellow spike to ~18ms
   - UI: Consistently green, ~8-10ms
   - Dropped frames: Very rare
   ```

**Test 2: AnimationController**
1. Switch mode
2. Repeat observation
3. Compare graphs

---

## 🎯 Metrics Penting untuk Tabel

### **Yang Harus Diukur:**

| Metric | Where to Find | Target |
|--------|---------------|--------|
| **Average Frame Time** | DevTools Performance summary | < 16ms |
| **CPU Time** | Build + Layout + Composition | Variable |
| **GPU Time** | Paint + Rasterization | Variable |
| **Jank Count** | Performance timeline (red bars) | 0 |
| **95th Percentile** | DevTools statistics | < 16ms |

### **Untuk Tabel Anda:**

```markdown
| Jenis Animasi | Rata-rata CPU (%) | Rata-rata GPU (%) | Kompleksitas Implementasi |
|---------------|-------------------|-------------------|---------------------------|
| AnimatedContainer | 52% | 48% | Mudah, kode singkat |
| AnimationController | 55% | 45% | Lebih kompleks, kontrol penuh |
```

**Note:** Angka di atas contoh, ganti dengan hasil measurement Anda!

---

## 📱 Tips untuk Measurement Akurat

### ✅ **DO:**

1. **Consistent Test:**
   - Gunakan device yang sama
   - Durasi test sama (30s atau 60s)
   - Interaksi yang sama
   
2. **Warm-up:**
   - Run app 1-2 menit sebelum record
   - Agar JIT compiler optimized
   
3. **Multiple Runs:**
   - Test minimal 3x per mode
   - Hitung rata-rata dari 3 hasil
   
4. **Close Background Apps:**
   - Minimize interference
   - Agar CPU/GPU tidak shared

5. **Use Profile Mode (Optional):**
   ```bash
   flutter run --profile -d 24090RA29G
   ```
   - Lebih akurat untuk performance measurement
   - Debug mode ada overhead

### ❌ **DON'T:**

1. ❌ Test saat charging (CPU throttling berbeda)
2. ❌ Test saat device panas (thermal throttling)
3. ❌ Single run (bisa outlier)
4. ❌ Mix debug & profile mode

---

## 📊 Template Hasil Benchmark

### **Copy template ini untuk dokumentasi:**

```markdown
# Streamline App - Performance Benchmark Results

## Test Configuration
- **Date:** October 16, 2025
- **Device:** 24090RA29G
- **Flutter Version:** 3.8.0
- **Build Mode:** Debug / Profile
- **Test Duration:** 30 seconds per mode
- **Number of Runs:** 3 per mode

---

## Test Methodology

**Interactions Performed:**
1. Tap 4 StatCards (hover animations)
2. Expand/collapse dashboard header
3. Tap Low Stock Alert
4. Scroll stock chart
5. Repeat 3-5 times within 30s

---

## AnimatedContainer Results

### Run 1:
- Average Frame Time: X.Xms
- CPU Time: X.Xms (XX%)
- GPU Time: X.Xms (XX%)
- Jank Count: X

### Run 2:
- Average Frame Time: X.Xms
- CPU Time: X.Xms (XX%)
- GPU Time: X.Xms (XX%)
- Jank Count: X

### Run 3:
- Average Frame Time: X.Xms
- CPU Time: X.Xms (XX%)
- GPU Time: X.Xms (XX%)
- Jank Count: X

### **Average:**
- **CPU Usage: XX%**
- **GPU Usage: XX%**
- **Frame Time: X.Xms**
- **Jank Rate: X.X%**

---

## AnimationController Results

### Run 1:
- Average Frame Time: X.Xms
- CPU Time: X.Xms (XX%)
- GPU Time: X.Xms (XX%)
- Jank Count: X

### Run 2:
- Average Frame Time: X.Xms
- CPU Time: X.Xms (XX%)
- GPU Time: X.Xms (XX%)
- Jank Count: X

### Run 3:
- Average Frame Time: X.Xms
- CPU Time: X.Xms (XX%)
- GPU Time: X.Xms (XX%)
- Jank Count: X

### **Average:**
- **CPU Usage: XX%**
- **GPU Usage: XX%**
- **Frame Time: X.Xms**
- **Jank Rate: X.X%**

---

## Comparison Table

| Jenis Animasi | Rata-rata CPU (%) | Rata-rata GPU (%) | Frame Time | Jank Rate | Kompleksitas Implementasi |
|---------------|-------------------|-------------------|------------|-----------|---------------------------|
| **AnimatedContainer** | XX% | XX% | X.Xms | X.X% | Mudah, kode singkat (~50 LOC) |
| **AnimationController** | XX% | XX% | X.Xms | X.X% | Kompleks, kontrol penuh (~150 LOC) |

---

## Analysis

### Performance Winner:
- [ ] AnimatedContainer
- [ ] AnimationController
- [ ] Tie (no significant difference)

### Key Findings:
1. ...
2. ...
3. ...

### Recommendations:
1. ...
2. ...

---

## Screenshots

- [ ] DevTools Performance timeline (AnimatedContainer)
- [ ] DevTools Performance timeline (AnimationController)
- [ ] Performance Overlay comparison
- [ ] Flame chart comparison

```

---

## 🎓 Interpretation Guide

### **Apa Arti Angka-Angka Ini?**

#### **CPU Usage:**

- **< 40%**: Sangat efisien ✅
- **40-60%**: Normal untuk animasi 👍
- **60-80%**: Agak tinggi ⚠️
- **> 80%**: Terlalu berat ❌

#### **GPU Usage:**

- **< 40%**: Ringan ✅
- **40-60%**: Normal 👍
- **60-80%**: Agak berat ⚠️
- **> 80%**: Sangat berat ❌

#### **Frame Time:**

- **< 16ms**: Perfect 60 FPS ✅
- **16-32ms**: 30-60 FPS ⚠️
- **> 32ms**: < 30 FPS, jank! ❌

#### **Jank Rate:**

- **0%**: Perfect ✅
- **< 1%**: Excellent 👍
- **1-5%**: Acceptable ⚠️
- **> 5%**: Needs optimization ❌

---

## 🔧 Jika Performance Buruk

### **CPU Terlalu Tinggi? (> 60%)**

**Penyebab:**
- Terlalu banyak rebuilds
- Widget tree terlalu dalam
- Computation di build method

**Solutions:**
```dart
// ❌ BAD: Computation di build
Widget build(BuildContext context) {
  final expensiveValue = calculateExpensiveValue(); // Re-calc setiap build!
  return Text(expensiveValue);
}

// ✅ GOOD: Cache hasil
class MyWidget extends StatefulWidget {
  late final String cachedValue;
  
  @override
  void initState() {
    super.initState();
    cachedValue = calculateExpensiveValue(); // Calc sekali
  }
}
```

### **GPU Terlalu Tinggi? (> 60%)**

**Penyebab:**
- Terlalu banyak layer compositing
- Clip/shadow berlebihan
- Opacity animations

**Solutions:**
```dart
// ❌ BAD: Opacity animation (GPU heavy)
AnimatedOpacity(opacity: _opacity, child: ExpensiveWidget())

// ✅ GOOD: FadeTransition (GPU optimized)
FadeTransition(opacity: _animation, child: ExpensiveWidget())
```

### **Jank Detected?**

**Debug Steps:**
1. Lihat timeline, frame mana yang merah?
2. Klik frame tersebut
3. Lihat flame chart - widget mana yang lambat?
4. Optimize widget tersebut

---

## ✅ Checklist

**Persiapan:**
- [ ] DevTools connected
- [ ] App running di device
- [ ] Performance tab terbuka
- [ ] Template hasil benchmark disiapkan

**Test AnimatedContainer:**
- [ ] Switch ke AnimatedContainer mode
- [ ] Record performance (30s)
- [ ] Lakukan interaksi konsisten
- [ ] Stop & analisa
- [ ] Catat CPU%, GPU%, Frame Time
- [ ] Repeat 2 kali lagi (total 3 runs)
- [ ] Hitung rata-rata

**Test AnimationController:**
- [ ] Switch ke AnimationController mode
- [ ] Record performance (30s)
- [ ] Lakukan interaksi yang sama
- [ ] Stop & analisa
- [ ] Catat CPU%, GPU%, Frame Time
- [ ] Repeat 2 kali lagi (total 3 runs)
- [ ] Hitung rata-rata

**Dokumentasi:**
- [ ] Isi tabel perbandingan
- [ ] Screenshot timeline
- [ ] Tulis analysis
- [ ] Simpan hasil

---

## 🎯 Expected Results

**Prediction (untuk Streamline app):**

| Metric | AnimatedContainer | AnimationController |
|--------|-------------------|---------------------|
| **CPU** | 45-55% | 50-60% |
| **GPU** | 45-55% | 40-50% |
| **Frame Time** | 8-12ms | 9-13ms |
| **Kompleksitas** | Low (easy) | High (expert) |

**Kesimpulan Likely:**
- Performance **hampir sama** (difference < 10%)
- AnimationController **sedikit lebih CPU intensive** (karena lebih banyak control code)
- AnimatedContainer **lebih mudah maintain**
- Untuk simple animations → **AnimatedContainer** ✅
- Untuk complex synchronized animations → **AnimationController** ✅

---

**Selamat Benchmarking! 📊🚀**

*Ada pertanyaan tentang pembacaan metrics? Tanya saja!*
