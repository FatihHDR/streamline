# Logo Guidelines - Streamline App

## 📁 Logo Files

### Main Logo
**File**: `assets/images/logo.png`
- **Format**: PNG with transparency
- **Recommended Size**: 512x512 pixels minimum
- **Current Usage**: AppBar header

## 🎨 Logo Design

Logo Streamline menampilkan huruf "S" dengan desain modern yang merepresentasikan:
- **Simplicity**: Desain minimalis untuk kemudahan identifikasi
- **Flow**: Bentuk yang mengalir seperti proses streamlining
- **Professionalism**: Tampilan yang clean dan profesional

### Color Scheme
Logo menggunakan warna konsisten dengan tema aplikasi:
- **Primary Color**: `#5F6C7B` (Slate Gray)
- Background dapat disesuaikan dengan konteks

## 📱 Implementation

### AppBar Logo
```dart
// In home_screen.dart
appBar: AppBar(
  title: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          width: 32,
          height: 32,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 12),
      const Text('Streamline'),
    ],
  ),
)
```

### Usage Examples

#### Small Size (AppBar)
```dart
ClipOval(
  child: Image.asset(
    'assets/images/logo.png',
    width: 32,
    height: 32,
    fit: BoxFit.cover,
  ),
)
```

#### Medium Size (Splash Screen)
```dart
ClipOval(
  child: Image.asset(
    'assets/images/logo.png',
    width: 120,
    height: 120,
    fit: BoxFit.cover,
  ),
)
```

#### Large Size (About Page)
```dart
ClipOval(
  child: Image.asset(
    'assets/images/logo.png',
    width: 200,
    height: 200,
    fit: BoxFit.cover,
  ),
)
```

## 🎯 Best Practices

### DO ✅
- Use `ClipOval()` for circular display
- Maintain aspect ratio (1:1)
- Use `BoxFit.cover` for consistent sizing
- Cache images for performance
- Provide fallback for loading errors

### DON'T ❌
- Distort the logo (stretch or squash)
- Use very low resolution versions
- Overlay heavy effects that obscure the design
- Use conflicting background colors

## 📦 Asset Configuration

Ensure `pubspec.yaml` includes:

```yaml
flutter:
  assets:
    - assets/images/logo.png
```

## 🔄 Updating Logo

To update the logo:

1. Replace `assets/images/logo.png` with new file
2. Keep the same filename to avoid code changes
3. Recommended size: 512x512 pixels minimum
4. Format: PNG with transparency
5. Run `flutter pub get` (if needed)
6. Hot reload/restart the app

## 🎨 Logo Variations

### Current Implementation
- **Main Logo**: PNG with circular crop
- **Size**: Flexible (32px to 200px+)
- **Background**: Transparent

### Future Considerations
- Light/Dark mode variants
- App icon versions (multiple sizes)
- Splash screen version
- Marketing materials version

## 📐 Dimensions

| Context | Size | Usage |
|---------|------|-------|
| AppBar | 32x32 | Navigation header |
| Bottom Sheet | 48x48 | Modal headers |
| Splash Screen | 120x120 | App launch |
| About Page | 200x200 | App information |
| App Icon | 1024x1024 | Store listing |

## 🖼️ Display Examples

### With Text
```dart
Row(
  children: [
    ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        width: 32,
        height: 32,
      ),
    ),
    const SizedBox(width: 12),
    const Text('Streamline'),
  ],
)
```

### Standalone
```dart
Center(
  child: ClipOval(
    child: Image.asset(
      'assets/images/logo.png',
      width: 120,
      height: 120,
    ),
  ),
)
```

### With Background
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor.withOpacity(0.1),
    shape: BoxShape.circle,
  ),
  child: Image.asset(
    'assets/images/logo.png',
    width: 80,
    height: 80,
  ),
)
```

## 🚀 Performance Tips

1. **Image Caching**: Flutter automatically caches images
2. **Size Optimization**: Use appropriate size for context
3. **Format**: PNG is optimal for logos with transparency
4. **Precaching**: For faster initial load, precache in `main.dart`:

```dart
@override
void didChangeDependencies() {
  precacheImage(
    const AssetImage('assets/images/logo.png'),
    context,
  );
  super.didChangeDependencies();
}
```

## 📱 Platform-Specific Icons

For app launcher icons, use different approach:

### Android
Place icons in `android/app/src/main/res/mipmap-*/`

### iOS
Place icons in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Tool: flutter_launcher_icons
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
```

Run: `flutter pub run flutter_launcher_icons`

---

**Last Updated**: October 16, 2025
**Logo Version**: 1.0
**Format**: PNG
