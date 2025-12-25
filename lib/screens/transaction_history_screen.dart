import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                final error = _inventoryController.transactionsError.value;
                final transactions = _inventoryController.transactions.toList();
                final filteredTransactions = _filteredTransactions(transactions);
                final isLoading = _inventoryController.isTransactionsLoading.value;
                final groupedTransactions = _groupTransactionsByDate(filteredTransactions);

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredTransactions.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: groupedTransactions.length + (error != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (error != null && index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildErrorBanner(error),
                      );
                    }
                    
                    final groupIndex = error != null ? index - 1 : index;
                    final group = groupedTransactions[groupIndex];
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Text(
                            group.dateLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...group.transactions.map((transaction) {
                          return _buildTransactionCard(transaction);
                        }),
                      ],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pantau keluar masuk barang',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildFilterTab('Semua')),
              const SizedBox(width: 12),
              Expanded(child: _buildFilterTab('Masuk')),
              const SizedBox(width: 12),
              Expanded(child: _buildFilterTab('Keluar')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _filterType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterType = label;
          _refreshList();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(StockTransaction transaction) {
    final isIncoming = transaction.type == TransactionType.incoming;
    final color = isIncoming ? AppTheme.successColor : AppTheme.warningColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showTransactionDetail(transaction),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: color,
                      size: 24,
                    ),
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
                      if (transaction.note != null && transaction.note!.isNotEmpty)
                        Text(
                          transaction.note!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          DateFormat('HH:mm').format(transaction.date), // Show time if no note
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncoming ? '+' : '-'}${transaction.quantity}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isIncoming ? 'Masuk' : 'Keluar',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaksi stok masuk/keluar akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dangerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: AppTheme.dangerColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: AppTheme.dangerColor, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => _inventoryController.loadTransactions(force: true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.dangerColor,
              padding: EdgeInsets.zero,
              minimumSize: const Size(60, 36),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<StockTransaction> _filteredTransactions(List<StockTransaction> source) {
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

  List<_TransactionGroup> _groupTransactionsByDate(List<StockTransaction> transactions) {
    if (transactions.isEmpty) return [];

    final grouped = <String, List<StockTransaction>>{};
    
    for (var transaction in transactions) {
      final dateKey = _formatDateKey(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped.entries
        .map((e) => _TransactionGroup(e.key, e.value))
        .toList();
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Hari Ini';
    } else if (transactionDate == yesterday) {
      return 'Kemarin';
    } else {
      return DateFormat('d MMMM yyyy', 'id_ID').format(date);
    }
  }

  void _showTransactionDetail(StockTransaction transaction) {
    final isIncoming = transaction.type == TransactionType.incoming;
    final color = isIncoming ? AppTheme.successColor : AppTheme.warningColor;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncoming ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: color,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${isIncoming ? '+' : '-'}${transaction.quantity}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                isIncoming ? 'Stok Masuk' : 'Stok Keluar',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              _buildDetailItem('Nama Barang', transaction.itemName),
              _buildDetailItem('Waktu', DateFormat('dd MMM yyyy • HH:mm').format(transaction.date)),
              if (transaction.note != null)
                _buildDetailItem('Catatan', transaction.note!),
              if (transaction.performedBy != null)
                _buildDetailItem('Oleh', transaction.performedBy!),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: AppTheme.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionGroup {
  final String dateLabel;
  final List<StockTransaction> transactions;

  _TransactionGroup(this.dateLabel, this.transactions);
}
