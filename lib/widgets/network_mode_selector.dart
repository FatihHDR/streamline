import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

enum NetworkMode { http, dio }

class NetworkModeSelector extends StatelessWidget {
  final NetworkMode currentMode;
  final ValueChanged<NetworkMode> onModeChanged;

  const NetworkModeSelector({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NetworkMode>(
      icon: const Icon(Icons.cloud),
      tooltip: 'Network mode',
      onSelected: onModeChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: NetworkMode.http,
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: currentMode == NetworkMode.http ? AppTheme.primaryColor : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text('http'),
            ],
          ),
        ),
        PopupMenuItem(
          value: NetworkMode.dio,
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: currentMode == NetworkMode.dio ? AppTheme.primaryColor : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              const Text('dio'),
            ],
          ),
        ),
      ],
    );
  }
}
