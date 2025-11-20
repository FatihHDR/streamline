import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/stock_item.dart';
import '../modules/inventory/controllers/inventory_controller.dart';
import '../utils/app_theme.dart';

class EditItemModal extends StatefulWidget {
  final StockItem item;

  const EditItemModal({super.key, required this.item});

  @override
  State<EditItemModal> createState() => _EditItemModalState();
}

class _EditItemModalState extends State<EditItemModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _locationController;
  late final TextEditingController _minStockController;
  late final TextEditingController _descriptionController;
  late final InventoryController _inventoryController;

  bool _submitting = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.find<InventoryController>();
    
    // Initialize with current item values
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _quantityController = TextEditingController(text: widget.item.quantity.toString());
    _unitController = TextEditingController(text: widget.item.unit);
    _locationController = TextEditingController(text: widget.item.location);
    _minStockController = TextEditingController(text: widget.item.minStock.toString());
    _descriptionController = TextEditingController(text: widget.item.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    _minStockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final unit = _unitController.text.trim();
    final location = _locationController.text.trim();
    final minStock = int.tryParse(_minStockController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();

    final updatedItem = widget.item.copyWith(
      name: name,
      category: category.isNotEmpty ? category : 'Umum',
      quantity: quantity,
      unit: unit.isNotEmpty ? unit : 'Unit',
      location: location.isNotEmpty ? location : '-',
      minStock: minStock,
      description: description.isNotEmpty ? description : null,
      lastUpdated: DateTime.now(),
    );

    try {
      await _inventoryController.updateStockItem(widget.item.id, updatedItem);

      if (!mounted) return;
      setState(() => _submitting = false);
      Navigator.of(context).pop(true); // indicate success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui barang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _delete() async {
    // Confirm delete
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Apakah Anda yakin ingin menghapus "${widget.item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _deleting = true);

    try {
      await _inventoryController.deleteStockItem(widget.item.id);

      if (!mounted) return;
      Navigator.of(context).pop(true); // close modal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus barang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Barang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _deleting ? null : _delete,
                  tooltip: 'Hapus barang',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Barang'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Masukkan nama barang'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _unitController,
                          decoration: const InputDecoration(
                            labelText: 'Satuan',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minStockController,
                          decoration: const InputDecoration(
                            labelText: 'Min. Stok',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Lokasi',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan (opsional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      onPressed: (_submitting || _deleting) ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan Perubahan'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
