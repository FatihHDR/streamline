# 🚀 Quick Start: Flutter DevTools untuk Streamline App

## ✅ Aplikasi Sudah Running!

Aplikasi Streamline sudah berjalan di device **24090RA29G**.

---

## 🌐 Akses DevTools Sekarang

### Option 1: Klik Link Ini (TERMUDAH!)

**Copy dan paste URL ini di browser Chrome/Edge:**

```
http://127.0.0.1:9101?uri=http://127.0.0.1:61063/gMqMMBMHyfg=/
```

### Option 2: Manual

1. **Buka browser** (Chrome atau Edge)
2. **Ketik di address bar:**
   ```
   http://127.0.0.1:9101
   ```
3. **Paste VM Service URI** (jika diminta):
   ```
   http://127.0.0.1:61063/gMqMMBMHyfg=/
   ```
4. **Klik Connect**

---

## 🎯 Langkah Pertama di DevTools

### 1. **Flutter Inspector** - Inspect UI

**Apa yang bisa dilakukan:**
- ✅ Lihat widget tree lengkap
- ✅ Inspect properties setiap widget
- ✅ Debug layout overflow
- ✅ Toggle slow animations
- ✅ Enable debug paint

**Coba ini:**
1. Klik tab **"Flutter Inspector"** di DevTools
2. Di aplikasi, tap salah satu **StatCard**
3. Lihat widget tree di Inspector
4. Toggle **"Select Widget Mode"** untuk select widget
5. Toggle **"Show Guidelines"** untuk lihat layout bounds

**Tips untuk Debug Overflow:**
- Klik card yang overflow
- Lihat constraints (merah = violated)
- Check RenderFlex properties

---

### 2. **Performance** - Analyze Animations

**Apa yang bisa dilakukan:**
- ✅ Monitor FPS (target: 60 FPS)
- ✅ Profiling CPU usage
- ✅ Detect jank (dropped frames)
- ✅ Compare animation performance

**Coba ini:**
1. Klik tab **"Performance"**
2. Klik button **"Record"** (merah)
3. Di aplikasi:
   - Tap beberapa cards
   - Expand/collapse low stock alert
   - Switch between tabs
4. Klik **"Stop"** button
5. Analyze timeline:
   - Green = good frame (<16ms)
   - Red/Yellow = jank (>16ms)

**Compare Animation Modes:**
```
Test 1: AnimatedContainer Mode
1. Di app, tap icon animasi (top right)
2. Pilih "AnimatedContainer"
3. Record performance
4. Interact dengan cards & charts
5. Stop & save results

Test 2: AnimationController Mode
1. Switch ke "AnimationController"
2. Record performance lagi
3. Interact dengan cards & charts
4. Stop & compare dengan Test 1

Pertanyaan:
- Mana yang lebih smooth?
- Frame time lebih konsisten?
- Ada dropped frames?
```

---

### 3. **Memory** - Check Memory Usage

**Apa yang bisa dilakukan:**
- ✅ Track memory consumption
- ✅ Detect memory leaks
- ✅ See object allocations
- ✅ Verify controller disposal

**Coba ini:**
1. Klik tab **"Memory"**
2. Klik **"Profile Memory"**
3. Di aplikasi:
   - Navigate: Dashboard → Stock List → Transactions
   - Back to Dashboard
   - Switch animation modes beberapa kali
4. Klik **"Snapshot"** button
5. Analyze:
   - Memory trend (naik terus = leak)
   - AnimationController count
   - Widget instances

**Warning Signs:**
- Memory terus naik tanpa turun (leak!)
- Banyak AnimationController tidak disposed
- Duplicate widget instances

---

### 4. **Network** - Monitor API Calls

**Note:** Streamline app saat ini menggunakan **dummy data**, jadi tidak ada network calls.

**Untuk Future Development:**
Ketika integrasi dengan backend API, gunakan tab ini untuk:
- Monitor HTTP requests
- Check response times
- Debug API errors
- View request/response headers

---

### 5. **Logging** - View Debug Logs

**Apa yang bisa dilakukan:**
- ✅ View print statements
- ✅ Filter by log level
- ✅ Search logs
- ✅ Export logs

**Coba ini:**
1. Klik tab **"Logging"**
2. Di aplikasi, interact dengan UI
3. Lihat logs yang muncul
4. Filter by:
   - Info
   - Warning
   - Error

**Add Custom Logs:**
```dart
// Di dashboard_animated_container.dart
import 'dart:developer' as developer;

@override
void initState() {
  super.initState();
  developer.log(
    'Dashboard AnimatedContainer initialized',
    name: 'Streamline.Dashboard',
  );
}

// Di stat_card_animated.dart
void _onTap() {
  developer.log(
    'Card tapped: ${widget.title}',
    name: 'Streamline.Card',
  );
  setState(() => _isHovered = !_isHovered);
}
```

---

## 🎨 Analisa Khusus untuk Streamline

### Scenario 1: Debug StatCard Overflow ✅

**Problem:** Card overflow by pixels

**Steps:**
1. **Flutter Inspector** → Enable "Select Widget Mode"
2. Tap card yang overflow
3. Look for **RenderFlex** in tree
4. Check **constraints** (merah = violated)
5. Lihat actual size vs expected size
6. Fix: Reduce font size / padding / icon size

**Already Fixed!** ✅ Tapi coba lihat di Inspector untuk learning.

---

### Scenario 2: Compare Animation Performance

**Goal:** Bandingkan AnimatedContainer vs AnimationController

**Steps:**
1. **Performance tab** → Record
2. **AnimatedContainer mode:**
   - Tap cards (hover effect)
   - Expand header
   - Collapse alerts
3. Stop → Note average frame time
4. **Switch to AnimationController mode**
5. Repeat steps 2-3
6. **Compare:**
   - Which is smoother?
   - Frame consistency?
   - Build times?

**Expected Results:**
- Both should be ~60 FPS
- AnimationController might be slightly more efficient
- AnimatedContainer easier to implement

---

### Scenario 3: Memory Leak Check

**Goal:** Ensure AnimationControllers are disposed

**Steps:**
1. **Memory tab** → Take snapshot (baseline)
2. **Navigate:**
   - Dashboard (AnimationController mode)
   - Stock List
   - Transactions
   - Back to Dashboard
3. Repeat 5x
4. Take snapshot again
5. **Compare:**
   - Memory increase?
   - AnimationController count?
   - Widget instances?

**Expected Results:**
- Memory should stabilize (not keep growing)
- AnimationControllers disposed properly
- No widget tree leaks

---

## 🔧 DevTools Tips & Tricks

### Enable Performance Overlay
Show FPS directly in app:

1. **Via DevTools:**
   - Inspector → Toggle "Performance Overlay"

2. **Via Code** (already in code):
   ```dart
   MaterialApp(
     showPerformanceOverlay: true, // Uncomment this
   )
   ```

### Slow Down Animations
See animations in detail:

1. **Via DevTools:**
   - Inspector → Enable "Slow Animations"

2. **Via Code:**
   ```dart
   import 'package:flutter/scheduler.dart';
   
   void main() {
     timeDilation = 5.0; // 5x slower
     runApp(const StreamlineApp());
   }
   ```

### Toggle Debug Paint
See all widget bounds:

**Via DevTools:**
- Inspector → Toggle "Debug Paint"

**Via Code:**
```dart
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;
  runApp(const StreamlineApp());
}
```

---

## 🎯 Hot Reload Commands (di Terminal)

Saat aplikasi running, Anda bisa:

| Key | Action | When to Use |
|-----|--------|-------------|
| `r` | Hot Reload 🔥 | After code changes |
| `R` | Hot Restart | Reset state |
| `p` | Toggle Performance Overlay | Quick FPS check |
| `w` | Toggle Widget Inspector | Quick inspect mode |
| `d` | Detach | Keep app running, stop debugging |
| `q` | Quit | Close app |

---

## 📊 Analyze Results

### Good Performance Indicators:
- ✅ Most frames < 16ms (60 FPS)
- ✅ No red bars in performance timeline
- ✅ Memory stable or decreasing
- ✅ No layout violations in Inspector
- ✅ Smooth animations

### Warning Signs:
- ⚠️ Many frames > 16ms (jank)
- ⚠️ Red bars in timeline
- ⚠️ Memory continuously increasing
- ⚠️ Layout overflow errors
- ⚠️ Slow build times (>100ms)

---

## 📱 Next Steps

### 1. **Document Findings**
Create a performance report:
```markdown
# Streamline App - Performance Analysis

## Test Date: October 16, 2025
## Device: 24090RA29G

### Dashboard Performance
- AnimatedContainer: avg XX fps
- AnimationController: avg XX fps
- Conclusion: ...

### Memory Usage
- Initial: XX MB
- After navigation: XX MB
- Memory leaks: None / Found

### Recommendations
1. ...
2. ...
```

### 2. **Optimize Based on Findings**
- Fix any jank
- Reduce memory usage
- Optimize animations
- Improve build times

### 3. **Test on Different Devices**
- Test on slower devices
- Test on different screen sizes
- Test on iOS (if available)

---

## 🆘 Troubleshooting

### DevTools tidak connect?

**Solution:**
```bash
# Di terminal baru
dart devtools

# Kemudian paste URI:
http://127.0.0.1:61063/gMqMMBMHyfg=/
```

### App terlalu lambat?

**Normal!** DevTools adds overhead.

**Solutions:**
- Disable unused features
- Use profile mode:
  ```bash
  flutter run --profile -d 24090RA29G
  ```

### Widget Inspector kosong?

**Check:**
1. App in debug mode (not release)
2. Refresh browser
3. Reconnect to VM Service

---

## 📚 Learn More

**Full Guide:** Lihat `DEVTOOLS_GUIDE.md` untuk dokumentasi lengkap.

**Official Docs:**
- https://docs.flutter.dev/tools/devtools
- https://docs.flutter.dev/perf/best-practices

---

## ✅ Quick Checklist

- [ ] Open DevTools URL di browser
- [ ] Explore Flutter Inspector
- [ ] Record Performance profile
- [ ] Take Memory snapshot
- [ ] Check Logging output
- [ ] Compare animation modes
- [ ] Document findings
- [ ] Optimize based on results

---

**Happy Analyzing! 🚀**

*Your DevTools URL:*
```
http://127.0.0.1:9101?uri=http://127.0.0.1:61063/gMqMMBMHyfg=/
```

*Copy dan paste di browser sekarang!*
