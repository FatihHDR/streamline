# Streamline Logo Widget

## 📝 Overview

Widget logo custom untuk aplikasi Streamline yang diimplementasikan menggunakan `CustomPainter` untuk performa optimal dan skalabilitas sempurna.

## 🎨 Design

Logo Streamline berbentuk huruf "S" dengan dua kurva yang saling berlawanan:
- **Upper Curve**: Seperti huruf "C" terbalik (menghadap kanan)
- **Lower Curve**: Seperti huruf "C" normal (menghadap kiri)

Kedua kurva ini membentuk huruf "S" yang stylish dan modern.

## 🔧 Implementation

### Static Logo

```dart
import 'package:streamline/widgets/streamline_logo.dart';

// Penggunaan sederhana
StreamlineLogo(
  size: 32,
  color: Colors.white,
)

// Custom size
StreamlineLogo(
  size: 64,
  color: Colors.blue,
)
```

### Animated Logo

```dart
import 'package:streamline/widgets/streamline_logo.dart';

// Logo dengan draw animation
AnimatedStreamlineLogo(
  size: 48,
  color: Colors.white,
  duration: Duration(milliseconds: 2000),
)
```

## 📊 Technical Details

### CustomPainter Implementation

```dart
class _StreamlineLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15  // 15% dari lebar
      ..strokeCap = StrokeCap.round;

    // Upper curve (C terbalik)
    path.addArc(
      upperCurveRect,
      -0.3,  // Start angle
      3.8,   // Sweep angle (hampir full circle)
    );

    // Lower curve (C normal)
    path.addArc(
      lowerCurveRect,
      3.4,   // Start angle
      -3.8,  // Sweep angle (berlawanan arah)
    );
  }
}
```

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `size` | `double` | `32` | Ukuran logo (width = height) |
| `color` | `Color?` | `Colors.white` | Warna stroke logo |
| `duration` | `Duration` | `2000ms` | Durasi animasi (animated only) |

### Advantages

✅ **Vector-based**: Scalable tanpa loss quality  
✅ **No assets**: Tidak perlu image files  
✅ **Performant**: Rendered langsung di canvas  
✅ **Customizable**: Size dan color bisa diubah  
✅ **Animated**: Versi animated dengan smooth drawing  

## 🎯 Usage Examples

### 1. AppBar Logo
```dart
AppBar(
  title: Row(
    children: [
      StreamlineLogo(size: 28, color: Colors.white),
      SizedBox(width: 12),
      Text('Streamline'),
    ],
  ),
)
```

### 2. Splash Screen
```dart
Center(
  child: AnimatedStreamlineLogo(
    size: 120,
    color: AppTheme.primaryColor,
    duration: Duration(milliseconds: 3000),
  ),
)
```

### 3. Dashboard Header
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(12),
  ),
  child: StreamlineLogo(size: 32),
)
```

### 4. Loading Indicator
```dart
Column(
  children: [
    AnimatedStreamlineLogo(
      size: 64,
      color: AppTheme.primaryColor,
    ),
    SizedBox(height: 16),
    Text('Loading...'),
  ],
)
```

## 🎨 Color Variations

```dart
// White (for dark backgrounds)
StreamlineLogo(color: Colors.white)

// Primary brand color
StreamlineLogo(color: AppTheme.primaryColor)

// Accent color
StreamlineLogo(color: AppTheme.accentColor)

// Custom color
StreamlineLogo(color: Color(0xFF5F6C7B))
```

## 📐 Size Guidelines

| Context | Recommended Size |
|---------|------------------|
| AppBar | 24-28px |
| Button Icon | 20-24px |
| Card Header | 32-40px |
| Hero/Splash | 80-120px |
| Favicon | 16-24px |

## 🎭 Animation Details

### Draw Animation Sequence

1. **Phase 1 (0-50%)**: Upper curve draws from left to right
2. **Phase 2 (50-100%)**: Lower curve draws from right to left

```dart
if (progress < 0.5) {
  // Draw upper curve progressively
  final sweepAngle = 3.8 * (progress * 2);
  path.addArc(upperCurveRect, -0.3, sweepAngle);
} else {
  // Draw full upper curve + progressive lower curve
  path.addArc(upperCurveRect, -0.3, 3.8);
  final lowerProgress = (progress - 0.5) * 2;
  final sweepAngle = -3.8 * lowerProgress;
  path.addArc(lowerCurveRect, 3.4, sweepAngle);
}
```

## 🔄 Integration with Themes

```dart
// Light theme
StreamlineLogo(
  color: Theme.of(context).primaryColor,
)

// Dark theme
StreamlineLogo(
  color: Theme.of(context).colorScheme.onPrimary,
)

// Adaptive
StreamlineLogo(
  color: Theme.of(context).brightness == Brightness.dark
    ? Colors.white
    : AppTheme.primaryColor,
)
```

## 🚀 Performance Tips

1. **Use const constructor** when possible:
   ```dart
   const StreamlineLogo(size: 32)
   ```

2. **Wrap in RepaintBoundary** for complex screens:
   ```dart
   RepaintBoundary(
     child: StreamlineLogo(size: 32),
   )
   ```

3. **Cache for repeated use** in lists:
   ```dart
   static const _logo = StreamlineLogo(size: 24);
   ```

## 📝 Notes

- Logo menggunakan `StrokeCap.round` untuk ujung yang smooth
- Stroke width adalah 15% dari ukuran total
- Kedua arc menggunakan rect yang sama tapi dengan angle berbeda
- Animation menggunakan `SingleTickerProviderStateMixin`

---

**Created for Streamline Warehouse Management App**  
*Vector-based, performant, and beautiful* ✨
