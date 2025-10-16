# Technical Documentation - Streamline App

## 📋 Table of Contents
1. [Architecture](#architecture)
2. [Data Models](#data-models)
3. [Screens](#screens)
4. [Widgets](#widgets)
5. [Animation Implementation](#animation-implementation)
6. [Color Scheme](#color-scheme)

---

## 🏗️ Architecture

Aplikasi menggunakan **Stateful Widget Architecture** dengan state management sederhana menggunakan `setState()`.

```
┌─────────────────────────────────────────┐
│           StreamlineApp                 │
│         (MaterialApp)                   │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│           HomeScreen                    │
│    (Bottom Navigation + AppBar)         │
└──┬──────────────┬──────────────┬────────┘
   │              │              │
   ▼              ▼              ▼
┌─────┐    ┌──────────┐   ┌──────────────┐
│Dash │    │  Stock   │   │ Transaction  │
│board│    │   List   │   │   History    │
└─────┘    └──────────┘   └──────────────┘
```

---

## 📦 Data Models

### StockItem
```dart
class StockItem {
  final String id;              // Unique identifier
  final String name;            // Nama barang
  final String category;        // Kategori (Elektronik, ATK, dll)
  final int quantity;           // Jumlah stok
  final String unit;            // Satuan (Unit, Rim, Botol, dll)
  final DateTime lastUpdated;   // Waktu update terakhir
  final String location;        // Lokasi di gudang (Rak A-1, dll)
  final int minStock;           // Minimum stok untuk alert
  final String? description;    // Deskripsi opsional
  
  // Computed properties
  bool get isLowStock => quantity <= minStock;
  bool get isOutOfStock => quantity <= 0;
}
```

### StockTransaction
```dart
enum TransactionType { incoming, outgoing }

class StockTransaction {
  final String id;              // Unique identifier
  final String itemId;          // Reference ke StockItem
  final String itemName;        // Nama item (denormalized)
  final TransactionType type;   // Masuk atau Keluar
  final int quantity;           // Jumlah
  final DateTime date;          // Tanggal transaksi
  final String? note;           // Catatan opsional
  final String? performedBy;    // Siapa yang melakukan
  
  String get typeLabel => type == TransactionType.incoming 
      ? 'Masuk' 
      : 'Keluar';
}
```

---

## 📱 Screens

### 1. HomeScreen
**File**: `lib/screens/home_screen.dart`

**Responsibilities**:
- Navigation management (Bottom Navigation Bar)
- Animation mode switching
- Screen routing

**State**:
```dart
int _selectedIndex = 0;                          // Current tab
AnimationMode _animationMode = AnimationMode.animatedContainer;
```

**Key Widgets**:
- `NavigationBar` - Bottom navigation
- `AnimationModeSelector` - Mode switcher in AppBar

---

### 2. Dashboard (Dual Implementation)

#### DashboardAnimatedContainer
**File**: `lib/screens/dashboard_animated_container.dart`

**Features**:
- Expandable header with AnimatedContainer
- 4 Statistics cards
- Interactive bar chart
- Low stock alerts

**Animations**:
- Header expansion on tap
- Card hover effects
- Chart bar selection
- Alert expansion

#### DashboardAnimationController
**File**: `lib/screens/dashboard_animation_controller.dart`

**Features**:
- Same as AnimatedContainer version
- Different animation implementation

**Animations**:
- Scale + Slide header entrance
- Staggered card animations
- Sequential bar animations
- Pulse effect on alerts

**Animation Controllers**:
```dart
AnimationController _headerController;   // 1200ms, elastic
AnimationController _fadeController;     // 800ms, ease
Animation<double> _scaleAnimation;       // 0.8 → 1.0
Animation<double> _fadeAnimation;        // 0.0 → 1.0
Animation<Offset> _slideAnimation;       // (0, -0.5) → (0, 0)
```

---

### 3. StockListScreen
**File**: `lib/screens/stock_list_screen.dart`

**Features**:
- Search functionality
- Category filtering
- Stock status indicators
- Detail modal

**State**:
```dart
String _searchQuery = '';
String _selectedCategory = 'Semua';
AnimationController _listController;
```

**Animations**:
- Search bar focus state
- Category chip selection
- Staggered card entrance
- Modal bottom sheet transition

---

### 4. TransactionHistoryScreen
**File**: `lib/screens/transaction_history_screen.dart`

**Features**:
- Transaction type filtering
- Transaction timeline
- Detail modal

**State**:
```dart
String _filterType = 'Semua';  // Semua, Masuk, Keluar
AnimationController _refreshController;
```

**Animations**:
- Filter tab transition
- List item slide-in
- Card entrance animations

---

## 🎨 Widgets

### Reusable Components

#### 1. StreamlineLogo
**File**: `lib/widgets/streamline_logo.dart`

**Purpose**: Custom logo widget menggunakan `CustomPainter`

**Variants**:
- `StreamlineLogo` - Static logo untuk AppBar
- `AnimatedStreamlineLogo` - Logo dengan draw animation

**Implementation**:
```dart
CustomPaint(
  size: Size(size, size),
  painter: _StreamlineLogoPainter(color: Colors.white),
)
```

**Features**:
- Vector-based rendering (scalable)
- Customizable size dan color
- Smooth curves menggunakan `Path.addArc()`
- Zero image assets (performance++)

---

#### 2. AnimationModeSelector
**File**: `lib/widgets/animation_mode_selector.dart`

```dart
enum AnimationMode {
  animatedContainer,
  animationController,
}
```

**Purpose**: PopupMenu untuk switch mode animasi

---

#### 3. StatCard (Dual Implementation)

**StatCardAnimated** (AnimatedContainer)
- Hover effect dengan MouseRegion
- Size and color transitions
- Border radius animation

**StatCardController** (AnimationController)
- Staggered entrance animation
- Scale + Rotation + Fade
- Tap to replay animation

---

#### 4. StockChart (Dual Implementation)

**StockChartAnimated**
- Bar height animation dengan AnimatedContainer
- Selection state dengan AnimatedOpacity
- Color transition

**StockChartController**
- Sequential bar entrance dengan delay
- TweenAnimationBuilder untuk smooth transitions
- Pulse animation on tap

---

#### 5. LowStockAlert (Dual Implementation)

**LowStockAlertAnimated**
- AnimatedSize untuk expand/collapse
- AnimatedRotation untuk chevron icon
- Nested AnimatedContainer untuk items

**LowStockAlertController**
- SizeTransition dengan CurvedAnimation
- RotationTransition untuk icon
- ScaleTransition untuk pulse effect
- TweenAnimationBuilder untuk staggered items

---

## 🎭 Animation Implementation Details

### AnimatedContainer Pattern

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  // Animated properties
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  color: _isExpanded ? Colors.blue : Colors.red,
  padding: EdgeInsets.all(_isExpanded ? 20 : 16),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(_isExpanded ? 20 : 12),
  ),
  child: YourWidget(),
)
```

### AnimationController Pattern

```dart
// 1. Setup (in State class)
class _MyWidgetState extends State<MyWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    
    // Create controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Create animation
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    // Start animation
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
      scale: _animation,
      child: YourWidget(),
    );
  }
}
```

### Common Animation Widgets Used

| Widget | Purpose | Example |
|--------|---------|---------|
| `AnimatedContainer` | Property transitions | Size, color, padding changes |
| `AnimatedOpacity` | Fade in/out | Show/hide elements |
| `AnimatedSize` | Height/width changes | Expand/collapse |
| `AnimatedRotation` | Rotation changes | Chevron icon rotation |
| `ScaleTransition` | Scale animations | Zoom effects |
| `FadeTransition` | Opacity animations | Fade effects |
| `SlideTransition` | Position animations | Slide in/out |
| `RotationTransition` | Rotation with controller | Spinning animations |
| `TweenAnimationBuilder` | Custom animations | Interpolated values |

---

## 🎨 Color Scheme

### Brand Colors
```dart
// Primary Colors (dari logo)
static const Color primaryColor = Color(0xFF5F6C7B);    // Slate Gray
static const Color primaryDark = Color(0xFF4A5568);     // Darker Slate
static const Color primaryLight = Color(0xFF8B95A5);    // Lighter Slate
static const Color accentColor = Color(0xFF7C8A99);     // Accent Gray

// Background Colors
static const Color backgroundColor = Color(0xFFF5F7FA); // Light Gray
static const Color cardColor = Color(0xFFFFFFFF);       // White

// Text Colors
static const Color textPrimary = Color(0xFF2D3748);     // Dark Gray
static const Color textSecondary = Color(0xFF718096);   // Medium Gray
```

### Status Colors
```dart
static const Color successColor = Color(0xFF48BB78);    // Green
static const Color warningColor = Color(0xFFED8936);    // Orange
static const Color dangerColor = Color(0xFFF56565);     // Red
static const Color infoColor = Color(0xFF4299E1);       // Blue
```

### Usage Guidelines

**Stok Tersedia**: `successColor` (Green)
- Quantity > minStock
- Icon: `Icons.inventory_2`

**Stok Menipis**: `warningColor` (Orange)
- 0 < Quantity ≤ minStock
- Icon: `Icons.warning_amber`

**Stok Habis**: `dangerColor` (Red)
- Quantity = 0
- Icon: `Icons.error_outline`

**Barang Masuk**: `successColor` (Green)
- TransactionType.incoming
- Icon: `Icons.arrow_downward`

**Barang Keluar**: `infoColor` (Blue)
- TransactionType.outgoing
- Icon: `Icons.arrow_upward`

---

## 🔧 Performance Considerations

### AnimatedContainer
- ✅ Lightweight for simple animations
- ⚠️ Can cause rebuilds if overused
- 💡 Best for isolated widget animations

### AnimationController
- ✅ Better performance for complex animations
- ✅ Can animate multiple properties efficiently
- ⚠️ Requires manual lifecycle management
- 💡 Use `RepaintBoundary` for expensive child widgets

### Best Practices
```dart
// ✅ Good - Isolate animations
RepaintBoundary(
  child: AnimatedWidget(),
)

// ✅ Good - Use const constructors
const Icon(Icons.check)
const Text('Label')

// ✅ Good - Dispose controllers
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ❌ Avoid - Animating entire screens
AnimatedContainer(
  child: EntireScreenWidget(),  // Too heavy
)
```

---

## 📊 State Flow

```
User Action → setState() → Widget Rebuild → Animation Trigger
     │                                            │
     │                                            ▼
     │                                    AnimatedContainer
     │                                            or
     └─────────────────────────────► AnimationController.forward()
```

---

## 🚀 Future Enhancements

### Technical Improvements
- [ ] Implement proper state management (Provider/Riverpod)
- [ ] Add repository pattern for data access
- [ ] Implement dependency injection
- [ ] Add unit and widget tests
- [ ] Performance profiling and optimization

### Features
- [ ] Offline-first with local database
- [ ] Real-time sync with backend
- [ ] Advanced filtering and sorting
- [ ] Data visualization with charts
- [ ] Export functionality

---

**Last Updated**: October 2025
**Flutter Version**: 3.8.0+
**Dart Version**: 3.8.0+
