# Flutter DevTools - Panduan Lengkap

## 🎯 Apa itu Flutter DevTools?

Flutter DevTools adalah suite tools untuk debugging, profiling, dan inspecting aplikasi Flutter. DevTools menyediakan UI berbasis web untuk membantu Anda:

- 📊 **Inspect UI** - Lihat widget tree dan properties
- 🔍 **Debug** - Set breakpoints, inspect variables
- 📈 **Performance** - CPU dan memory profiling
- 🌳 **Widget Inspector** - Analisa layout dan rendering
- 📱 **Network** - Monitor HTTP requests
- 💾 **Memory** - Track memory usage dan leaks
- 🔥 **Performance Overlay** - FPS dan rendering metrics

---

## 🚀 Cara Menggunakan DevTools

### Method 1: Via Flutter Run (Otomatis)

#### Step 1: Jalankan Aplikasi
```bash
flutter run -d <device_id>
# Contoh:
flutter run -d 24090RA29G
```

#### Step 2: Tunggu Build Selesai
Setelah aplikasi berhasil running, Anda akan melihat output seperti ini:

```
Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on 24090RA29G is available at: http://127.0.0.1:xxxxx/xxxxxxx=/

The Flutter DevTools debugger and profiler on 24090RA29G is available at:
http://127.0.0.1:9100?uri=http://127.0.0.1:xxxxx/xxxxxxx=/
```

#### Step 3: Buka DevTools di Browser
1. **Copy URL** yang ditampilkan di terminal (yang mengandung DevTools)
2. **Paste di browser** (Chrome, Edge, atau Firefox)
3. DevTools akan terbuka otomatis!

---

### Method 2: Manual Launch DevTools

#### Step 1: Jalankan Aplikasi
```bash
flutter run -d 24090RA29G
```

#### Step 2: Launch DevTools
Buka terminal baru dan jalankan:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Atau lebih singkat:
```bash
dart devtools
```

#### Step 3: Connect ke App
1. DevTools akan terbuka di browser di `http://127.0.0.1:9100`
2. Copy **Dart VM Service URI** dari terminal app Anda
3. Paste di field "Connect" di DevTools
4. Klik "Connect"

---

### Method 3: Via VS Code (Termudah!)

#### Step 1: Install Extension
Pastikan Anda sudah install extension:
- **Flutter**
- **Dart**

#### Step 2: Run & Debug
1. Tekan `F5` atau klik `Run > Start Debugging`
2. Pilih device Anda
3. Tunggu aplikasi running

#### Step 3: Open DevTools
Di VS Code, Anda akan melihat beberapa opsi:

**Option A: Via Command Palette**
- Tekan `Ctrl+Shift+P`
- Ketik "Dart: Open DevTools"
- Pilih salah satu:
  - `Dart: Open DevTools in Web Browser`
  - `Dart: Open DevTools in Web Browser (Widget Inspector)`
  - `Dart: Open DevTools in Web Browser (Performance)`

**Option B: Via Debug Console**
- Klik pada "DEBUG CONSOLE" panel
- Klik link DevTools yang muncul

**Option C: Via Status Bar**
- Lihat status bar di bawah
- Klik "Open DevTools"

---

## 🛠️ Fitur-Fitur DevTools

### 1. **Flutter Inspector** 🔍

**Kegunaan:**
- Inspect widget tree
- Lihat properties widget
- Debug layout issues
- Toggle debug paint
- Slow animations

**Cara Pakai:**
1. Buka tab "Flutter Inspector"
2. Klik widget di tree atau di emulator
3. Lihat properties di panel kanan
4. Toggle options:
   - ✅ Select Widget Mode
   - ✅ Enable Slow Animations
   - ✅ Show Guidelines
   - ✅ Show Baselines

**Tips untuk Streamline App:**
```dart
// Debug overflow issues
- Aktifkan "Show Guidelines"
- Klik pada StatCard yang overflow
- Lihat constraint violations di Inspector
```

---

### 2. **Performance** 📈

**Kegunaan:**
- Monitor FPS
- CPU profiling
- Find jank (dropped frames)
- Optimize rendering

**Cara Pakai:**
1. Buka tab "Performance"
2. Klik "Record" button
3. Interact dengan aplikasi
4. Klik "Stop"
5. Analisa timeline

**Metrics Penting:**
- **Frame Rendering Time**: Harus < 16ms (60 FPS)
- **Build Time**: Waktu rebuild widgets
- **Layout Time**: Waktu layout calculations
- **Paint Time**: Waktu painting

**Tips untuk Animasi:**
```dart
// Compare AnimatedContainer vs AnimationController
1. Record performance di Dashboard (AnimatedContainer mode)
2. Switch ke AnimationController mode
3. Record lagi
4. Bandingkan frame times
```

---

### 3. **Memory** 💾

**Kegunaan:**
- Track memory usage
- Detect memory leaks
- Analyze heap
- Monitor allocations

**Cara Pakai:**
1. Buka tab "Memory"
2. Klik "Profile Memory"
3. Navigate aplikasi
4. Take snapshot
5. Analyze objects

**Warning Signs:**
- Memory terus naik (possible leak)
- Banyak duplicate objects
- AnimationController tidak di-dispose

**Tips:**
```dart
// Check AnimationController disposal
1. Go to AnimationController dashboard
2. Navigate away
3. Take memory snapshot
4. Check if controllers are disposed
```

---

### 4. **Network** 🌐

**Kegunaan:**
- Monitor HTTP requests
- View request/response
- Debug API calls
- Check timing

**Cara Pakai:**
1. Buka tab "Network"
2. Enable recording
3. Trigger network calls
4. Click requests untuk detail

**Note:** 
Streamline app saat ini menggunakan dummy data, jadi tidak ada network calls. Berguna untuk future development ketika integrasi API.

---

### 5. **Logging** 📝

**Kegunaan:**
- View print statements
- Debug.print output
- Error logs
- Custom logging

**Cara Pakai:**
1. Buka tab "Logging"
2. Filter by level (info, warning, error)
3. Search logs
4. Clear logs

**Add Logging ke Streamline:**
```dart
import 'dart:developer' as developer;

// Di AnimatedContainer mode
developer.log(
  'Dashboard loaded with AnimatedContainer',
  name: 'Streamline.Dashboard',
);

// Track animation
developer.log(
  'Card animation started',
  name: 'Streamline.Animation',
  time: DateTime.now(),
);
```

---

### 6. **Debugger** 🐛

**Kegunaan:**
- Set breakpoints
- Step through code
- Inspect variables
- Evaluate expressions

**Cara Pakai:**
1. Set breakpoint di VS Code (klik di line number)
2. Trigger action di app
3. Execution akan pause
4. Use debugger controls:
   - Continue (F5)
   - Step Over (F10)
   - Step Into (F11)
   - Step Out (Shift+F11)

**Debug Animation Issues:**
```dart
// Set breakpoint di StatCardAnimated
@override
Widget build(BuildContext context) {
  // Breakpoint here
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    // Check _isHovered value
    // Check widget.color value
  );
}
```

---

## 📊 Analisa Performa Streamline App

### Scenario 1: Analyze Dashboard Animations

**Steps:**
1. Launch app dengan DevTools
2. Go to Performance tab
3. Record performance
4. Tap cards, expand/collapse sections
5. Stop recording
6. Check:
   - Frame rendering times
   - Build times for AnimatedContainer vs AnimationController
   - Any dropped frames (jank)

**Expected Results:**
- Most frames < 16ms (60 FPS)
- AnimationController might be slightly more efficient
- No major jank during animations

---

### Scenario 2: Memory Usage

**Steps:**
1. Go to Memory tab
2. Take baseline snapshot
3. Navigate: Dashboard → Stock List → Transactions → Dashboard
4. Take another snapshot
5. Compare snapshots

**Check for:**
- Memory increases after navigation
- AnimationControllers properly disposed
- No widget tree leaks

---

### Scenario 3: Widget Inspector

**Steps:**
1. Open Widget Inspector
2. Enable "Select Widget Mode"
3. Tap on StatCard
4. Check:
   - Widget tree depth
   - Constraints
   - Render object properties

**Debug Overflow:**
1. Look for RenderFlex with errors
2. Check constraints (red if violated)
3. See actual vs expected sizes

---

## 🎯 Keyboard Shortcuts di DevTools

| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + F` | Search |
| `Ctrl/Cmd + P` | Command palette |
| `Esc` | Close panels |
| `F5` | Refresh |

---

## 💡 Tips & Tricks

### 1. Performance Overlay di App
Aktifkan FPS overlay langsung di app:

**Cara 1: Via DevTools**
- Inspector tab → Toggle "Performance Overlay"

**Cara 2: Via Code**
```dart
// In main.dart
MaterialApp(
  showPerformanceOverlay: true, // Add this
  // ...
)
```

### 2. Debug Paint
Lihat border semua widgets:

```dart
MaterialApp(
  debugShowCheckedModeBanner: false,
  debugShowMaterialGrid: false, // Grid overlay
  // ...
)
```

### 3. Slow Animations
Perlambat animasi untuk debugging:

**Via DevTools:**
- Inspector → Enable "Slow Animations"

**Via Code:**
```dart
import 'package:flutter/scheduler.dart';

void main() {
  timeDilation = 2.0; // 2x slower
  runApp(const StreamlineApp());
}
```

### 4. Widget Select Mode
Di emulator, enable widget select:
- Tap pada widget untuk highlight di inspector
- Lihat properties real-time

---

## 🔧 Troubleshooting

### DevTools tidak connect?

**Solution 1: Check VM Service URI**
```bash
# Di terminal flutter run, cari baris:
A Dart VM Service on xxx is available at: http://...
# Copy URL lengkap dan paste di DevTools
```

**Solution 2: Restart DevTools**
```bash
# Kill DevTools
Ctrl+C

# Restart
dart devtools
```

**Solution 3: Check Port**
```bash
# DevTools default port: 9100
# Jika bentrok, specify port lain:
dart devtools --port 9101
```

### App terlalu lambat setelah attach DevTools?

**Normal!** DevTools menambah overhead untuk profiling.

**Solutions:**
- Disable features yang tidak dipakai
- Profile mode lebih cepat dari debug mode:
  ```bash
  flutter run --profile -d 24090RA29G
  ```

### Widget Inspector tidak show UI?

**Check:**
1. App running di debug mode (bukan release)
2. Flutter version compatible
3. Refresh browser
4. Reconnect ke VM Service

---

## 📱 DevTools untuk Streamline App

### Recommended Analysis

#### 1. Compare Animation Modes
```
Performance Tab:
1. Record AnimatedContainer dashboard
2. Record AnimationController dashboard
3. Compare frame times
4. Document in ANIMATION_GUIDE.md
```

#### 2. Memory Profiling
```
Memory Tab:
1. Test navigation flow
2. Check AnimationController disposal
3. Verify no leaks in StatCards
```

#### 3. Layout Debugging
```
Widget Inspector:
1. Debug StatCard overflow
2. Optimize GridView layout
3. Check responsive constraints
```

---

## 🌐 DevTools di Web Browser

### Supported Browsers:
- ✅ Chrome (Recommended)
- ✅ Edge (Chromium)
- ✅ Firefox
- ⚠️ Safari (Limited support)

### Best Experience:
- Use Chrome untuk full features
- Responsive UI
- Can dock to side or bottom
- Multi-monitor support

---

## 📚 Resources

### Official Docs:
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

### Video Tutorials:
- [DevTools Overview](https://www.youtube.com/watch?v=nq43mP7hjAE)
- [Performance Profiling](https://www.youtube.com/watch?v=vVg9It7cOfY)

---

## ✅ Quick Start Checklist

- [ ] Run `flutter run -d <device>`
- [ ] Wait for build to complete
- [ ] Copy DevTools URL from terminal
- [ ] Open in Chrome browser
- [ ] Start with Flutter Inspector
- [ ] Record Performance profile
- [ ] Take Memory snapshot
- [ ] Check Logging tab
- [ ] Analyze results
- [ ] Document findings

---

**Happy Debugging! 🚀**

*Last Updated: October 16, 2025*
