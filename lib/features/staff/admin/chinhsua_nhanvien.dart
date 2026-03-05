import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test2025/data/Serve/staff_service.dart';

class ChinhSuaNhanVienScreen extends StatefulWidget {
  final Map<String, dynamic> staff;

  const ChinhSuaNhanVienScreen({super.key, required this.staff});

  @override
  State<ChinhSuaNhanVienScreen> createState() => _ChinhSuaNhanVienScreenState();
}

class _ChinhSuaNhanVienScreenState extends State<ChinhSuaNhanVienScreen> {
  final _formKey = GlobalKey<FormState>();
  final StaffService _staffService = StaffService();

  // Khai báo Late nhưng khởi tạo ngay trong initState
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isSubmitting = false;
  String _selectedRole = 'Nhân viên';
  final List<String> _roleOptions = ['Quản lý', 'Nhân viên', 'Pha chế', 'Thu ngân', 'Đầu bếp'];

  @override
  void initState() {
    super.initState();
    // Kiểm tra dữ liệu đầu vào cực kỳ cẩn thận
    _nameController = TextEditingController(text: widget.staff['name']?.toString() ?? '');
    _emailController = TextEditingController(text: widget.staff['email']?.toString() ?? '');
    _phoneController = TextEditingController(text: widget.staff['phone']?.toString() ?? '');
    _selectedRole = _convertRoleToDisplay(widget.staff['role']?.toString());
  }

  String _convertRoleToDisplay(String? code) {
    if (code == null) return 'Nhân viên';
    switch (code.toLowerCase()) {
      case 'manager': case 'admin': return 'Quản lý';
      case 'barista': return 'Pha chế';
      case 'cashier': return 'Thu ngân';
      case 'chef': return 'Đầu bếp';
      default: return 'Nhân viên';
    }
  }

  String _convertRoleToCode(String vnRole) {
    switch (vnRole) {
      case 'Quản lý': return 'manager';
      case 'Pha chế': return 'barista';
      case 'Thu ngân': return 'cashier';
      case 'Đầu bếp': return 'chef';
      default: return 'staff';
    }
  }

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      // Quan trọng: Kiểm tra ID có tồn tại không
      final String? staffId = widget.staff['id']?.toString();
      if (staffId == null) throw "Không tìm thấy ID nhân viên";

      await _staffService.updateStaff(widget.staff['id'], {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _convertRoleToCode(_selectedRole),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chỉnh Sửa", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(_nameController, "Họ tên", Icons.person),
              const SizedBox(height: 15),
              _buildInput(_emailController, "Email", Icons.email),
              const SizedBox(height: 15),
              _buildInput(_phoneController, "SĐT", Icons.phone, isNumber: true),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: "Chức vụ", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _updateStaff,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
      validator: (v) => v!.isEmpty ? "Không được để trống" : null,
    );
  }
}