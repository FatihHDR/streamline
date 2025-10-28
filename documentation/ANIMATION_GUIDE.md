# Panduan Perbandingan Mode Animasi

## 📚 Overview

Aplikasi Streamline menyediakan dua mode animasi yang berbeda untuk memberikan pengalaman visual yang menarik dan membantu developer memahami perbedaan antara **AnimatedContainer** dan **AnimationController** di Flutter.

## 🎭 AnimatedContainer Mode

### Karakteristik
- **Jenis**: Implicit Animation
- **Kompleksitas**: Sederhana
- **Setup**: Minimal
- **Kontrol**: Terbatas
- **Use Case**: Animasi property widget sederhana

### Kelebihan
✅ Mudah diimplementasikan (hanya perlu `setState()`)
✅ Kode lebih sedikit dan clean
✅ Tidak perlu dispose controller
✅ Cocok untuk animasi sederhana
✅ Automatic handling of animation lifecycle

### Kekurangan
❌ Kontrol timing terbatas
❌ Tidak support animasi kompleks
❌ Sulit untuk membuat sequence animation
❌ Tidak bisa pause/reverse manual

### Contoh Implementasi

```dart
class AnimatedExample extends StatefulWidget {
  @override
  State<AnimatedExample> createState() => _AnimatedExampleState();
}

class _AnimatedExampleState extends State<AnimatedExample> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isExpanded ? 200 : 100,
      height: _isExpanded ? 200 : 100,
      color: _isExpanded ? Colors.blue : Colors.red,
      child: GestureDetector(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Center(child: Text('Tap Me')),
      ),
    );
  }
}
```

### Digunakan di:
- `DashboardAnimatedContainer` - Header expansion
- `StatCardAnimated` - Card hover effects
- `StockChartAnimated` - Bar selection
- `LowStockAlertAnimated` - Expand/collapse alert
- `StockListScreen` - Search bar focus state
- `TransactionHistoryScreen` - Filter tab selection

---

## 🎮 AnimationController Mode

### Karakteristik
- **Jenis**: Explicit Animation
- **Kompleksitas**: Lebih kompleks
- **Setup**: Memerlukan setup controller
- **Kontrol**: Penuh
- **Use Case**: Animasi kompleks dan custom

### Kelebihan
✅ Kontrol penuh terhadap animasi
✅ Support untuk complex animations
✅ Bisa pause, reverse, repeat
✅ Multiple animations dengan satu controller
✅ Custom curves dan timing
✅ Staggered animations support

### Kekurangan
❌ Lebih banyak boilerplate code
❌ Harus dispose controller manually
❌ Memerlukan `TickerProviderStateMixin`
❌ Lebih kompleks untuk pemula

### Contoh Implementasi

```dart
class ControllerExample extends StatefulWidget {
  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: RotationTransition(
        turns: _rotationAnimation,
        child: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
        ),
      ),
    );
  }
}
```

### Digunakan di:
- `DashboardAnimationController` - Multiple synchronized animations
- `StatCardController` - Staggered card entrance
- `StockChartController` - Sequential bar animations
- `LowStockAlertController` - Pulse effect + expansion
- `StockListScreen` - Slide-in animations
- `TransactionHistoryScreen` - Fade + slide transitions

---

## 📊 Tabel Perbandingan

| Aspek | AnimatedContainer | AnimationController |
|-------|------------------|---------------------|
| **Kesulitan** | ⭐ Mudah | ⭐⭐⭐ Sedang-Sulit |
| **Kode** | Minimal | Lebih banyak |
| **Kontrol** | Terbatas | Penuh |
| **Performance** | Baik | Sangat Baik |
| **Flexibility** | Rendah | Tinggi |
| **Learning Curve** | Landai | Curam |
| **Cleanup** | Otomatis | Manual |
| **Use Case** | Simple UI changes | Complex animations |

---

## 🎯 Kapan Menggunakan?

### Gunakan AnimatedContainer Ketika:
- ✅ Animasi sederhana (warna, ukuran, posisi)
- ✅ Prototype cepat
- ✅ Tidak perlu kontrol timing detail
- ✅ Single property animation
- ✅ Triggered by user action

### Gunakan AnimationController Ketika:
- ✅ Multiple synchronized animations
- ✅ Custom animation curves
- ✅ Perlu pause/reverse/repeat
- ✅ Staggered animations
- ✅ Complex timing requirements
- ✅ Performance critical animations

---

## 💡 Tips & Best Practices

### AnimatedContainer
```dart
// ✅ Good - Simple and clean
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  color: isActive ? Colors.blue : Colors.grey,
)

// ❌ Avoid - Too many animated properties
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  width: width,
  height: height,
  color: color,
  padding: padding,
  margin: margin,
  transform: transform,
  decoration: decoration,
  // Too complex, consider AnimationController
)
```

### AnimationController
```dart
// ✅ Good - Always dispose
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ✅ Good - Check mounted before animation
Future.delayed(Duration(milliseconds: 100), () {
  if (mounted) {
    _controller.forward();
  }
});

// ✅ Good - Use appropriate Tween
Tween<double>(begin: 0.0, end: 1.0)
Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
ColorTween(begin: Colors.red, end: Colors.blue)
```

---

## 🔄 Cara Mencoba di Aplikasi

1. **Buka aplikasi Streamline**
2. **Tap icon animasi** di pojok kanan atas AppBar
3. **Pilih mode**:
   - `AnimatedContainer` - Lihat animasi implisit
   - `AnimationController` - Lihat animasi eksplisit
4. **Bandingkan**:
   - Perhatikan perbedaan smoothness
   - Coba refresh dashboard (pull down)
   - Tap pada cards dan chart
   - Expand/collapse alert section

---

## 📝 Kesimpulan

Kedua pendekatan memiliki tempatnya masing-masing:

- **AnimatedContainer** → Perfect untuk **simple, reactive animations**
- **AnimationController** → Best untuk **complex, choreographed animations**

Dalam aplikasi Streamline, Anda dapat **beralih antara kedua mode** untuk melihat perbedaan implementasi dan hasilnya secara langsung!

---

**Happy Coding! 🚀**
