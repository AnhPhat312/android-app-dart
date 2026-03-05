import 'package:flutter/material.dart';
import 'package:test2025/data/Serve/inventory_service.dart';

class InventoryAddEditScreen extends StatefulWidget {
  final Map<String, dynamic>? existingItem; // Nếu null là thêm mới, có dữ liệu là sửa

  const InventoryAddEditScreen({super.key, this.existingItem});

  @override
  State<InventoryAddEditScreen> createState() => _InventoryAddEditScreenState();
}

class _InventoryAddEditScreenState extends State<InventoryAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = InventoryService();

  late TextEditingController _nameCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _minCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameCtrl = TextEditingController(text: item?['name'] ?? '');
    _unitCtrl = TextEditingController(text: item?['unit'] ?? '');
    _stockCtrl = TextEditingController(text: item != null ? item['stock'].toString() : '0');
    _minCtrl = TextEditingController(text: item != null ? item['min_threshold'].toString() : '5');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameCtrl.text.trim(),
        'unit': _unitCtrl.text.trim(),
        'stock': double.tryParse(_stockCtrl.text) ?? 0,
        'min_threshold': double.tryParse(_minCtrl.text) ?? 5,
      };

      if (widget.existingItem == null) {
        // Thêm mới
        await _service.addItem(data);
      } else {
        // Cập nhật
        await _service.updateItem(widget.existingItem!['id'], data);
      }

      if (mounted) Navigator.pop(context, true); // Trả về true để màn hình trước reload
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Hàm xóa
  Future<void> _delete() async {
    final confirm = await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Xóa nguyên liệu?"),
          content: const Text("Hành động này không thể hoàn tác."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Hủy")),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Xóa", style: TextStyle(color: Colors.red))),
          ],
        )
    );

    if (confirm == true && widget.existingItem != null) {
      await _service.deleteItem(widget.existingItem!['id']);
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Cập Nhật Kho" : "Nhập Nguyên Liệu Mới"),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _delete)
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: "Tên nguyên liệu", border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? "Không được để trống" : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Số lượng tồn", border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: "Đơn vị (kg, lít...)", border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Mức báo động tối thiểu",
                  helperText: "Sẽ báo đỏ nếu tồn kho thấp hơn mức này",
                  border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("LƯU THÔNG TIN", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}