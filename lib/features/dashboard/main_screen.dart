import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2025/Drawer/Drawer.dart';

// --- IMPORT CÁC MÀN HÌNH ---
import '../../data/Serve/auth_service.dart';
import '../auth/login_screen.dart';
import 'home_screen.dart';
import 'package:test2025/features/menu/admin/menu_screen.dart';
import 'package:test2025/features/statistics/screens/BaoCao_ThongKe.dart'; // Đã đổi thành file mới RevenueScreen
import 'package:test2025/features/staff/admin/QunlyNhanvien_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const MainScreen({super.key, this.onNavigate});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _userEmail = '';
  String _userName = 'Admin';

  String _userRole = '';
  int _selectedIndex = 0;
  bool _isLoading = true; // Biến này kiểm soát màn hình chờ

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Giả lập độ trễ nhỏ để đảm bảo UI không bị giật (opsional)
      // await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _userEmail = user.email ?? "";
          _userName = user.userMetadata?['name'] ?? "Quản trị viên";
          _userRole = user.userMetadata?['role'] ?? "user"; // Fallback là user cho an toàn
          _isLoading = false; // Đã load xong
        });
      }
    } else {
      // Nếu chưa đăng nhập thì đá về Login
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  List<Widget> get _screens => [
    HomeScreen(
      onNavigate: _onItemTapped,
      userRole: _userRole,
      userName: _userName,
    ),
    MenuScreen(onNavigate: widget.onNavigate ?? (_) {}), // Kiểm tra lại tên class trong file menu_screen.dart
    RevenueScreen(onNavigate: widget.onNavigate ?? (_) {}), // Kiểm tra lại tên class trong file BaoCao_ThongKe.dart
    QuanLyNhanVienScreen(onNavigate: widget.onNavigate ?? (_) {}),
  ];

  @override
  Widget build(BuildContext context) {
    // 1. CHẶN HIỂN THỊ NẾU ĐANG LOAD
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurple),
        ),
      );
    }

    // 2. KHI LOAD XONG MỚI HIỆN GIAO DIỆN CHÍNH
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBody: true,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white24,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Xin chào, $_userName",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
                ),
                Text(
                  (_userRole == 'manager' || _userRole == 'admin') ? "Quản Lý" : "Nhân Viên",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined), tooltip: "Thông báo")
        ],
      ),

      drawer: MyDrawer(
        onTap: (index) {
          Navigator.pop(context);
          _onItemTapped(index);
        },
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_rounded, "Trang chủ"),
            _buildNavItem(1, Icons.restaurant_menu_rounded, "Menu"),
            _buildNavItem(2, Icons.bar_chart_rounded, "Thống kê"),
            _buildNavItem(3, Icons.people_alt_rounded, "Nhân sự"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.deepPurple : Colors.grey,
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}