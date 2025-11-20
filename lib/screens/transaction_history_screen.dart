import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../models/stock_transaction.dart';
import '../modules/inventory/controllers/inventory_controller.dart';
import '../widgets/animation_mode_selector.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final AnimationMode animationMode;

  const TransactionHistoryScreen({super.key, required this.animationMode});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  String _filterType = 'Semua';
  late AnimationController _refreshController;
  late final InventoryController _inventoryController;

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.find<InventoryController>();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    // Load data when screen initializes
    Future.microtask(() => _inventoryController.loadTransactions());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _refreshList() {
    _refreshController.reset();
    _refreshController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = _inventoryController.transactionsError.value;
      final transactions = _inventoryController.transactions.toList();
      final filteredTransactions = _filteredTransactions(transactions);
      final isLoading = _inventoryController.isTransactionsLoading.value;

      return Column(
        children: [
          // Header and Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                // Filter Tabs
                Row(
                  children: [
                    Expanded(child: _buildFilterTab('Semua')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFilterTab('Masuk')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildFilterTab('Keluar')),
                  ],
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  _buildErrorBanner(error),
                ],
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTransactions.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];

                          if (widget.animationMode ==
                              AnimationMode.animatedContainer) {
                            return _buildAnimatedTransactionCard(
                              transaction,
                              index,
                            );
                          } else {
                            return _buildControllerTransactionCard(
                              transaction,
                              index,
                            );
                          }
                        },
                      ),
          ),
        ],
      );
    });
  }

  List<StockTransaction> _filteredTransactions(
    List<StockTransaction> source,
  ) {
    if (_filterType == 'Semua') {
      return source;
    }
    return source.where((t) {
      if (_filterType == 'Masuk') {
        return t.type == TransactionType.incoming;
      } else {
        return t.type == TransactionType.outgoing;
      }
    }).toList();
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.dangerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppTheme.dangerColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          TextButton(
            onPressed: () => _inventoryController.loadTransactions(force: true),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _filterType == label;

    if (widget.animationMode == AnimationMode.animatedContainer) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _filterType = label;
            _refreshList();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: isSelected ? 14 : 13,
            ),
          ),
        ),
      );
    } else {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _filterType = label;
                _refreshList();
              });
            },
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.grey.shade100,
                    AppTheme.primaryColor,
                    value,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.grey.shade300,
                      AppTheme.primaryColor,
                      value,
                    )!,
                    width: 1 + value,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.lerp(
                      AppTheme.textSecondary,
                      Colors.white,
                      value,
                    ),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildAnimatedTransactionCard(
    StockTransaction transaction,
    int index,
  ) {
    final isIncoming = transaction.type == TransactionType.incoming;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: () => _showTransactionDetail(transaction),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIncoming
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncoming
                        ? AppTheme.successColor
                        : AppTheme.infoColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.typeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: isIncoming
                              ? AppTheme.successColor
                              : AppTheme.infoColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (transaction.note != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.note!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncoming ? '+' : '-'}${transaction.quantity}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isIncoming
                            ? AppTheme.successColor
                            : AppTheme.infoColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.date),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControllerTransactionCard(
    StockTransaction transaction,
    int index,
  ) {
    final isIncoming = transaction.type == TransactionType.incoming;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: InkWell(
                  onTap: () => _showTransactionDetail(transaction),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isIncoming
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncoming
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isIncoming
                                ? AppTheme.successColor
                                : AppTheme.infoColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.itemName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transaction.typeLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isIncoming
                                      ? AppTheme.successColor
                                      : AppTheme.infoColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (transaction.note != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  transaction.note!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${isIncoming ? '+' : '-'}${transaction.quantity}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isIncoming
                                    ? AppTheme.successColor
                                    : AppTheme.infoColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(transaction.date),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaksi akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(StockTransaction transaction) {
    final isIncoming = transaction.type == TransactionType.incoming;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isIncoming
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            isIncoming
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: isIncoming
                                ? AppTheme.successColor
                                : AppTheme.infoColor,
                            size: 48,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.typeLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isIncoming
                                      ? AppTheme.successColor
                                      : AppTheme.infoColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transaction.itemName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('ID Transaksi', transaction.id),
                    _buildDetailRow('ID Barang', transaction.itemId),
                    _buildDetailRow(
                      'Kuantitas',
                      '${isIncoming ? '+' : '-'}${transaction.quantity}',
                    ),
                    _buildDetailRow(
                      'Tanggal',
                      _formatDateLong(transaction.date),
                    ),
                    if (transaction.performedBy != null)
                      _buildDetailRow(
                        'Dilakukan oleh',
                        transaction.performedBy!,
                      ),
                    if (transaction.note != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          transaction.note!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m yang lalu';
      }
      return '${difference.inHours}j yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else {
      return '${difference.inDays}h yang lalu';
    }
  }

  String _formatDateLong(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
