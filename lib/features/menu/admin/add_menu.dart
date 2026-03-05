import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test2025/data/Serve/menu_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMenuItemForm extends StatefulWidget {
  final Map<String, dynamic>? existingItem; // Nếu null là Thêm, có dữ liệu là Sửa
  final bool isEditMode;

  const AddMenuItemForm({
    super.key,
    this.existingItem,
    this.isEditMode = false,
  });

  @override
  State<AddMenuItemForm> createState() => _AddMenuItemFormState();
}

class _AddMenuItemFormState extends State<AddMenuItemForm> {
  final _formKey = GlobalKey<FormState>();
  final MenuService _menuService = MenuService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Biến dữ liệu
  String _selectedCategory = 'Trà Sữa';
  String _selectedStatus = 'Còn hàng';
  bool _isSubmitting = false;

  // Danh mục cứng (Sau này có thể lấy từ DB)
  final List<String> _categories = [
    'Trà Sữa', 'Cà Phê', 'Sinh Tố', 'Nước Ép', 'Trà Trái Cây', 'Đồ Ăn Nhẹ', 'Khác'
  ];

  @override
  void initState() {
    super.initState();
    // Nếu là chế độ sửa, điền dữ liệu cũ vào form
    if (widget.isEditMode && widget.existingItem != null) {
      _nameController.text = widget.existingItem!['name'] ?? '';
      _priceController.text = (widget.existingItem!['price'] ?? 0).toString();
      _descriptionController.text = widget.existingItem!['description'] ?? '';

      // Kiểm tra xem category cũ có trong list không, nếu không thì về mặc định
      String oldCat = widget.existingItem!['category'] ?? 'Trà Sữa';
      _selectedCategory = _categories.contains(oldCat) ? oldCat : 'Khác';

      _selectedStatus = widget.existingItem!['status'] ?? 'Còn hàng';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // --- HÀM XỬ LÝ LƯU ---
  Future<void> _submitForm() async {
    final user = Supabase.instance.client.auth.currentUser;
    print("🔍 KIỂM TRA USER: $user");

    if (user == null) {
      print("❌ LỖI: User đang là NULL (Chưa đăng nhập)");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Bạn chưa đăng nhập! Hãy đăng xuất và vào lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // 🛑 Dừng lại ngay, không cho chạy tiếp xuống dưới
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // Chuẩn bị dữ liệu
      final itemData = {
        'name': _nameController.text.trim(),
        'price': int.parse(_priceController.text),
        'category': _selectedCategory,
        'status': _selectedStatus,
        'description': _descriptionController.text.trim(),
        // 'image_url': ... (Xử lý ảnh nếu có sau này)
      };

      if (widget.isEditMode) {
        // GỌI UPDATE
        await _menuService.updateItem(widget.existingItem!['id'], itemData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cập nhật thành công!')));
        }
      } else {
        // GỌI CREATE

        await _menuService.createItem(itemData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thêm món mới thành công!')));

        }
      }

      // Đóng màn hình và trả về true để màn hình danh sách biết cần reload
      if (mounted) Navigator.pop(context, true);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? "Chỉnh Sửa Món" : "Thêm Món Mới"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Tên món
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Tên món (*)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.coffee),
                ),
                validator: (v) => v!.isEmpty ? "Vui lòng nhập tên món" : null,
              ),
              const SizedBox(height: 16),

              // 2. Giá & Danh mục (Row)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Giá (VNĐ) (*)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) => v!.isEmpty ? "Nhập giá tiền" : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: "Danh mục",
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Trạng thái
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: "Trạng thái",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'Còn hàng', child: Text('Còn hàng', style: TextStyle(color: Colors.green))),
                  DropdownMenuItem(value: 'Hết hàng', child: Text('Hết hàng', style: TextStyle(color: Colors.red))),
                  DropdownMenuItem(value: 'Ngừng kinh doanh', child: Text('Ngừng kinh doanh', style: TextStyle(color: Colors.grey))),
                ],
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),
              const SizedBox(height: 16),

              // 4. Mô tả
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Mô tả chi tiết",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 30),

              // 5. Nút Lưu

              SizedBox(

                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),

                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    widget.isEditMode ? "LƯU THAY ĐỔI" : "THÊM MÓN NGAY",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),

                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}