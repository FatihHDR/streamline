import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum AnimationMode {
  animatedContainer,
  animationController,
}

class AnimationModeSelector extends StatelessWidget {
  final AnimationMode currentMode;
  final ValueChanged<AnimationMode> onModeChanged;

  const AnimationModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AnimationMode>(
      icon: const Icon(Icons.animation),
      tooltip: 'Mode Animasi',
      onSelected: onModeChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AnimationMode.animatedContainer,
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: currentMode == AnimationMode.animatedContainer
                    ? AppTheme.primaryColor
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text('AnimatedContainer'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AnimationMode.animationController,
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: currentMode == AnimationMode.animationController
                    ? AppTheme.primaryColor
                    : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text('AnimationController'),
            ],
          ),
        ),
      ],
    );
  }
}
