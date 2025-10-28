import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/stock_item.dart';

class LowStockAlertAnimated extends StatefulWidget {
  final List<StockItem> lowStockItems;

  const LowStockAlertAnimated({
    super.key,
    required this.lowStockItems,
  });

  @override
  State<LowStockAlertAnimated> createState() => _LowStockAlertAnimatedState();
}

class _LowStockAlertAnimatedState extends State<LowStockAlertAnimated> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.lowStockItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Peringatan Stok Menipis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.lowStockItems.length} item memerlukan perhatian',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.expand_more,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ClipRect prevents children from briefly overflowing during AnimatedSize
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      children: widget.lowStockItems.map((item) {
                        return _buildLowStockItem(item);
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(StockItem item) {
    final isOutOfStock = item.isOutOfStock;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? AppTheme.dangerColor.withOpacity(0.05)
            : AppTheme.warningColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOutOfStock
              ? AppTheme.dangerColor.withOpacity(0.2)
              : AppTheme.warningColor.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? AppTheme.dangerColor.withOpacity(0.1)
                    : AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isOutOfStock ? Icons.error_outline : Icons.inventory_2_outlined,
                color: isOutOfStock ? AppTheme.dangerColor : AppTheme.warningColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.location} • ${item.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.quantity} ${item.unit}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock ? AppTheme.dangerColor : AppTheme.warningColor,
                  ),
                ),
                Text(
                  isOutOfStock ? 'Habis' : 'Menipis',
                  style: TextStyle(
                    fontSize: 10,
                    color: isOutOfStock ? AppTheme.dangerColor : AppTheme.warningColor,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 28,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 28),
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.06),
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Placeholder action: navigate to stock detail or reorder
                      // Implement actual action as needed
                    },
                    child: const Text('Tindak', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
