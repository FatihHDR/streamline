import 'package:flutter/material.dart';

/// Widget untuk handle animasi navigation bar dan responsiveness orientation
class ResponsiveUILayout extends StatefulWidget {
  final Widget child;
  final bool hideNavBarOnStartup;
  final Duration animationDuration;

  const ResponsiveUILayout({
    super.key,
    required this.child,
    this.hideNavBarOnStartup = true,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<ResponsiveUILayout> createState() => _ResponsiveUILayoutState();
}

class _ResponsiveUILayoutState extends State<ResponsiveUILayout>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _navBarAnimationController;
  late Animation<Offset> _navBarSlideAnimation;
  bool _isNavBarHidden = false;
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize animation controller for nav bar slide
    _navBarAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Slide animation - from top (visible) to bottom (hidden)
    _navBarSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5), // Slide down below screen
    ).animate(CurvedAnimation(
      parent: _navBarAnimationController,
      curve: Curves.easeInOut,
    ));

    // Auto hide nav bar on startup
    if (widget.hideNavBarOnStartup) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _hideNavBar();
        }
      });
    }
  }

  @override
  void dispose() {
    _navBarAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isNavBarHidden) {
      // Re-hide nav bar when app is resumed
      _hideNavBar();
    }
  }

  void _hideNavBar() {
    if (!_isNavBarHidden && mounted) {
      _navBarAnimationController.forward();
      setState(() => _isNavBarHidden = true);
      debugPrint('📊 Navigation bar hidden with animation');
    }
  }

  void _showNavBar() {
    if (_isNavBarHidden && mounted) {
      _navBarAnimationController.reverse();
      setState(() => _isNavBarHidden = false);
      debugPrint('📊 Navigation bar shown with animation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    // Detect orientation change
    if (_currentOrientation != orientation) {
      _currentOrientation = orientation;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🔄 Orientation changed to: ${orientation.name}');
          // Auto hide nav bar on landscape
          if (isLandscape && !_isNavBarHidden) {
            _hideNavBar();
          }
          // Show nav bar on portrait
          else if (!isLandscape && _isNavBarHidden) {
            _showNavBar();
          }
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          widget.child,
          
          // Animated nav bar overlay (transparent, just for animation effect)
          SlideTransition(
            position: _navBarSlideAnimation,
            child: Container(
              height: 56, // Standard Android nav bar height
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension untuk easy access ke ResponsiveUILayout methods
extension ResponsiveUILayoutExt on BuildContext {
  /// Toggle nav bar visibility
  void toggleNavBar() {
    final parent = findAncestorStateOfType<_ResponsiveUILayoutState>();
    if (parent != null) {
      if (parent._isNavBarHidden) {
        parent._showNavBar();
      } else {
        parent._hideNavBar();
      }
    }
  }

  /// Hide nav bar
  void hideNavBar() {
    findAncestorStateOfType<_ResponsiveUILayoutState>()?._hideNavBar();
  }

  /// Show nav bar
  void showNavBar() {
    findAncestorStateOfType<_ResponsiveUILayoutState>()?._showNavBar();
  }
}
