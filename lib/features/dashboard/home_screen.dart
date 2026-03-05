import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Import màn hình kho
import 'package:test2025/features/inventory/Quanlykho_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final String userRole;
  final String userName;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.userRole,
    required this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _todayRevenue = 0.0;
  bool _isLoadingRevenue = true;

  bool get isManager => widget.userRole == 'manager' || widget.userRole == 'manager';

  @override
  void initState() {
    super.initState();
    _fetchTodayRevenue();
  }

  Future<void> _fetchTodayRevenue() async {
    if (!isManager) {
      // Nếu là nhân viên thường hoặc khách, không cần load doanh thu
      setState(() => _isLoadingRevenue = false);
      return;
    }

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

      final response = await Supabase.instance.client
          .from('orders')
          .select('total_price')
          .gte('created_at', startOfDay)
          .eq('status', 'completed');

      double total = 0;
      if (response != null && response is List) {
        for (var order in response) {
          total += (order['total_price'] as num).toDouble();
        }
      }

      if (mounted) {
        setState(() {
          _todayRevenue = total;
          _isLoadingRevenue = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingRevenue = false);
    }
  }

  String _formatCurrency(double amount) {
    final currencyFormatter = NumberFormat('#,###', 'vi_VN');
    return "${currencyFormatter.format(amount)} đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. DASHBOARD (Chỉ hiện nếu là Quản lý/Admin)
            if (isManager)
              _buildDashboardSummary()
            else
              _buildStaffWelcome(), // Nếu là Staff thì hiện lời chào đơn giản

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Chức năng quản lý",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 15),

            // 2. GRID MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.1,
                    children: [
                      _buildFeatureCard(
                        "Quản lý Menu", "Chỉnh sửa món ăn",
                        FontAwesomeIcons.burger, const Color(0xFFFF9800),
                            () => widget.onNavigate(1),
                      ),
                      _buildFeatureCard(
                        "Quản lý Kho", "Nhập/Xuất nguyên liệu",
                        FontAwesomeIcons.boxesStacked, const Color(0xFF4CAF50),
                            () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => QuanLyKhoScreen(onNavigate: widget.onNavigate)));
                        },
                      ),
                      _buildFeatureCard(
                        "Báo cáo", "Doanh thu & Đơn hàng",
                        FontAwesomeIcons.chartPie, const Color(0xFF9C27B0),
                            () => widget.onNavigate(2),
                      ),
                      _buildFeatureCard(
                        "Nhân sự", "Chấm công & Lương",
                        FontAwesomeIcons.users, const Color(0xFF2196F3),
                            () => widget.onNavigate(3),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị lời chào cho nhân viên (không hiện tiền)
  Widget _buildStaffWelcome() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Xin chào,", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16)),
          Text(widget.userName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Chúc bạn một ngày làm việc hiệu quả!", style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDashboardSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Doanh thu hôm nay", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
              const Icon(Icons.trending_up, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          _isLoadingRevenue
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
            _formatCurrency(_todayRevenue),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Text("Cập nhật real-time", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Center(child: FaIcon(icon, color: color, size: 24)),
              ),
              const Spacer(),
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}