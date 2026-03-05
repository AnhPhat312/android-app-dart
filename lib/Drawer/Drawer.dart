import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2025/features/auth/login_screen.dart';
import 'setting_screen.dart';
import 'package:test2025/features/menu/khach_hang/order_history_screen.dart';
import 'package:test2025/features/menu/khach_hang/customer_menu_screen.dart';
import 'package:test2025/features/menu/khach_hang/profile_screen.dart';

class MyDrawer extends StatefulWidget {
  final Function(int) onTap;

  const MyDrawer({super.key, required this.onTap});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _userRole = 'user';
  String _userEmail = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "";
        _userName = user.userMetadata?['name'] ?? "Người dùng";
        _userRole = user.userMetadata?['role'] ?? 'user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(), // Header mới
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                if (_userRole == 'manager' || _userRole == 'manager') ..._buildAdminMenu(),
                if (_userRole == 'staff') ..._buildStaffMenu(),
                if (_userRole == 'user') ..._buildUserMenu(),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(),
                ),

                _buildCommonItems(),
              ],
            ),
          ),
          // Footer version
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "Phiên bản 1.0.0",
              style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              backgroundImage: const NetworkImage(""), // Ảnh giả lập
              child: _userName.isNotEmpty
                  ? Text(_userName[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                  : null,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            _userName,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _userEmail,
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userRole.toUpperCase(),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // Sử dụng hàm này để tạo Item đẹp hơn
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey[700], size: 22),
      title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      dense: true,
    );
  }

  List<Widget> _buildAdminMenu() {
    return [
      _buildDrawerItem(Icons.dashboard_outlined, "Tổng quan", () => widget.onTap(0)),
      _buildDrawerItem(Icons.restaurant_menu, "Quản lý Menu", () => widget.onTap(1)),
      _buildDrawerItem(Icons.bar_chart, "Báo cáo doanh thu", () => widget.onTap(2)),
      _buildDrawerItem(Icons.people_alt_outlined, "Quản lý nhân viên", () => widget.onTap(3)),
    ];
  }

  List<Widget> _buildStaffMenu() {
    return [
      _buildDrawerItem(Icons.receipt_long, "Gọi món (Order)", () => widget.onTap(0)),
      _buildDrawerItem(Icons.table_restaurant, "Sơ đồ bàn", () => widget.onTap(1)),
      _buildDrawerItem(Icons.inventory_2_outlined, "Kiểm tra kho", () => widget.onTap(2)),
    ];
  }

  List<Widget> _buildUserMenu() {
    return [
      _buildDrawerItem(Icons.home_outlined, "Trang Chủ", () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerMenuScreen()));
      }),
      _buildDrawerItem(Icons.history, "Lịch sử mua hàng", () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
      }),
      _buildDrawerItem(Icons.person_outline, "Thông tin cá nhân", () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
      }),
    ];
  }

  Widget _buildCommonItems() {
    return Column(
      children: [
        _buildDrawerItem(Icons.settings_outlined, "Cài đặt", () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        }),
        _buildDrawerItem(Icons.logout, "Đăng xuất", () async {
          //Đóng lại cho gọn
          Navigator.pop(context);
          // Xóa phiên đăng nhập
          await Supabase.instance.client.auth.signOut();
          // kiểm tra tránh crash
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          }
        }, color: Colors.redAccent),
      ],
    );
  }
}