import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../modules/inventory/controllers/inventory_controller.dart';
import '../widgets/animation_mode_selector.dart';
import 'edit_item_modal.dart';

class StockListScreen extends StatefulWidget {
  final AnimationMode animationMode;

  const StockListScreen({super.key, required this.animationMode});

  @override
  State<StockListScreen> createState() => _StockListScreenState();
}

class _StockListScreenState extends State<StockListScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  late AnimationController _listController;
  late final InventoryController _inventoryController;

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.find<InventoryController>();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();

    // Load data when screen initializes
    Future.microtask(() => _inventoryController.loadStockItems());
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _refreshList() {
    _listController.reset();
    _listController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = _inventoryController.itemsError.value;
      if (error != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    _inventoryController.loadStockItems(force: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final items = _inventoryController.items.toList();
      final categories = _buildCategories(items);
      final filteredItems = _filterItems(items);

      return Column(
        children: [
        // Search and Filter Section
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar dengan animasi
              widget.animationMode == AnimationMode.animatedContainer
                  ? _buildAnimatedSearchBar()
                  : _buildControllerSearchBar(),
              const SizedBox(height: 12),
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;

                    if (widget.animationMode ==
                        AnimationMode.animatedContainer) {
                      return _buildAnimatedCategoryChip(category, isSelected);
                    } else {
                      return _buildControllerCategoryChip(category, isSelected);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Stock List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await _inventoryController.loadStockItems(force: true);
            },
            child: _inventoryController.isItemsLoading.value
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];

                          if (widget.animationMode ==
                              AnimationMode.animatedContainer) {
                            return _buildAnimatedStockCard(item, index);
                          } else {
                            return _buildControllerStockCard(item, index);
                          }
                        },
                      ),
          ),
        ),
        ],
      );
    });
  }

  List<String> _buildCategories(List<StockItem> source) {
    final cats = source.map((e) => e.category).toSet().toList();
    return ['Semua', ...cats];
  }

  List<StockItem> _filterItems(List<StockItem> source) {
    return source.where((item) {
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.description?.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ==
                  true;
      final matchesCategory =
          _selectedCategory == 'Semua' || item.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildAnimatedSearchBar() {
    bool isFocused = _searchQuery.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isFocused ? 12 : 8),
        border: Border.all(
          color: isFocused ? AppTheme.primaryColor : Colors.grey.shade300,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _refreshList();
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari barang...',
          prefixIcon: Icon(
            Icons.search,
            color: isFocused ? AppTheme.primaryColor : Colors.grey,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _refreshList();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildControllerSearchBar() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _searchQuery.isNotEmpty
                      ? AppTheme.primaryColor
                      : Colors.grey.shade300,
                  width: _searchQuery.isNotEmpty ? 2 : 1,
                ),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _refreshList();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: _searchQuery.isNotEmpty
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _refreshList();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCategoryChip(String category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
            _refreshList();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
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
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSelected ? 14 : 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControllerCategoryChip(String category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _refreshList();
              });
            },
            child: Transform.scale(
              scale: 0.95 + (0.05 * value),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    Colors.grey.shade200,
                    AppTheme.primaryColor,
                    value,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: Color.lerp(
                      AppTheme.textSecondary,
                      Colors.white,
                      value,
                    ),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedStockCard(StockItem item, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: () => _showStockDetail(item),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: _getStatusColor(item),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.category} • ${item.location}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getStatusText(item),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(item),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(item),
                      ),
                    ),
                    Text(
                      item.unit,
                      style: const TextStyle(
                        fontSize: 12,
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

  Widget _buildControllerStockCard(StockItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: InkWell(
                  onTap: () => _showStockDetail(item),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: _getStatusColor(item),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.category} • ${item.location}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(item),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(item),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(item),
                              ),
                            ),
                            Text(
                              item.unit,
                              style: const TextStyle(
                                fontSize: 12,
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
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Tidak ada barang ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StockItem item) {
    if (item.isOutOfStock) return AppTheme.dangerColor;
    if (item.isLowStock) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  String _getStatusText(StockItem item) {
    if (item.isOutOfStock) return 'Habis';
    if (item.isLowStock) return 'Menipis';
    return 'Tersedia';
  }

  void _showStockDetail(StockItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                            color: _getStatusColor(item).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.inventory_2,
                            color: _getStatusColor(item),
                            size: 48,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(item).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getStatusText(item),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusColor(item),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Kategori', item.category),
                    _buildDetailRow('Lokasi', item.location),
                    _buildDetailRow(
                      'Kuantitas',
                      '${item.quantity} ${item.unit}',
                    ),
                    _buildDetailRow(
                      'Stok Minimum',
                      '${item.minStock} ${item.unit}',
                    ),
                    _buildDetailRow(
                      'Terakhir Update',
                      _formatDate(item.lastUpdated),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Deskripsi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Stock Adjustment Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAdjustmentDialog(context, item, TransactionType.incoming);
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Stok Masuk'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showAdjustmentDialog(context, item, TransactionType.outgoing);
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            label: const Text('Stok Keluar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.warningColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Edit and Delete Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: EditItemModal(item: item),
                                ),
                              ).then((updated) {
                                if (updated == true) {
                                  // Refresh the list
                                  _inventoryController.loadStockItems(force: true);
                                }
                              });
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.textSecondary),
                              foregroundColor: AppTheme.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Barang'),
                                  content: Text(
                                    'Apakah Anda yakin ingin menghapus "${item.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                try {
                                  await _inventoryController.deleteStockItem(item.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Barang berhasil dihapus'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gagal menghapus barang: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.red.shade300),
                              foregroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdjustmentDialog(
    BuildContext context,
    StockItem item,
    TransactionType type,
  ) {
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    final isIncoming = type == TransactionType.incoming;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIncoming ? 'Stok Masuk' : 'Stok Keluar'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update stok untuk "${item.name}"',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Jumlah (${item.unit})',
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  final qty = int.tryParse(value);
                  if (qty == null || qty <= 0) {
                    return 'Jumlah harus > 0';
                  }
                  if (!isIncoming && qty > item.quantity) {
                    return 'Stok tidak mencukupi (Max: ${item.quantity})';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final qty = int.parse(quantityController.text);
                final note = noteController.text.trim();
                
                Navigator.pop(context); // Close dialog

                try {
                  await _inventoryController.adjustStock(
                    itemId: item.id,
                    quantityChange: qty,
                    type: type,
                    note: note.isNotEmpty ? note : null,
                  );
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Berhasil ${isIncoming ? "menambah" : "mengurangi"} stok',
                        ),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                    _inventoryController.loadStockItems(force: true); // Refresh list
                  }
                } catch (e) {
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal update stok: $e'),
                        backgroundColor: AppTheme.dangerColor,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isIncoming ? AppTheme.successColor : AppTheme.warningColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
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
        return '${difference.inMinutes} menit yang lalu';
      }
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
