import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StatCardAnimated extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? trend;

  const StatCardAnimated({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });

  @override
  State<StatCardAnimated> createState() => _StatCardAnimatedState();
}

class _StatCardAnimatedState extends State<StatCardAnimated> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isHovered = !_isHovered),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(_isHovered ? 16 : 12),
            border: Border.all(
              color: _isHovered ? widget.color : Colors.grey.shade200,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.color.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: _isHovered ? 12 : 6,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_isHovered ? 10 : 8),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(_isHovered ? 12 : 8),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: _isHovered ? 24 : 20,
                    ),
                  ),
                  if (widget.trend != null)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isHovered ? 1.0 : 0.6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.trend!.startsWith('+')
                              ? AppTheme.successColor.withOpacity(0.2)
                              : widget.trend!.startsWith('-')
                                  ? AppTheme.dangerColor.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.trend!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.trend!.startsWith('+')
                                ? AppTheme.successColor
                                : widget.trend!.startsWith('-')
                                    ? AppTheme.dangerColor
                                    : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _isHovered ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: _isHovered ? widget.color : AppTheme.textPrimary,
                  ),
                  child: Text(widget.value),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
