import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StaffDetailScreen extends StatelessWidget {
  final Map<String, dynamic> staff;

  const StaffDetailScreen({super.key, required this.staff});

  // 1. Hàm an toàn để lấy màu sắc
  Color _getSafeColor(String? role) {
    final r = role?.toLowerCase() ?? '';
    if (r.contains('manager') || r.contains('admin')) return Colors.redAccent;
    if (r.contains('barista')) return Colors.brown;
    if (r.contains('chef')) return Colors.orange;
    if (r.contains('cashier')) return Colors.green;
    return Colors.blue;
  }

  // 2. Hàm an toàn để format ngày tháng
  String _getSafeDate(dynamic date) {
    if (date == null) return "Chưa cập nhật";
    try {
      final parsedDate = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trích xuất dữ liệu an toàn (Chống lỗi Null hoàn toàn)
    final String name = staff['name']?.toString() ?? 'N/A';
    final String email = staff['email']?.toString() ?? 'Chưa có email';
    final String role = staff['role']?.toString() ?? 'Nhân viên';
    final String phone = staff['phone']?.toString() ?? 'Chưa có SĐT';
    final String staffId = staff['id']?.toString() ?? 'ID-???';
    final Color themeColor = _getSafeColor(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            ),
          ),
        ),
        title: Text("Chi tiết nhân sự", style: GoogleFonts.poppins(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: themeColor),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(role.toUpperCase(), style: GoogleFonts.poppins(color: Colors.white70, letterSpacing: 1.2)),
                ],
              ),
            ),

            // Danh sách thông tin
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _infoTile(Icons.email, "Email", email),
                  _infoTile(Icons.phone, "Số điện thoại", phone),
                  _infoTile(Icons.calendar_month, "Ngày gia nhập", _getSafeDate(staff['created_at'])),
                  _infoTile(Icons.fingerprint, "Mã ID", staffId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}