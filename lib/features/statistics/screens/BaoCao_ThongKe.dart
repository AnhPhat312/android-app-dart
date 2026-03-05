import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RevenueScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const RevenueScreen({super.key, required this.onNavigate});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  double _totalRevenue = 0;
  int _orderCount = 0;
  double _averageOrderValue = 0;
  List<Map<String, dynamic>> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final now = DateTime.now();
    // Tạo mốc thời gian bắt đầu ngày (00:00:00 hôm nay)
    final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();

    try {
      print("⏳ Đang tải dữ liệu từ Supabase...");

      // 1. LẤY TỔNG DOANH THU HÔM NAY
      final revenueResponse = await Supabase.instance.client
          .from('orders')
          .select('total_price')
          .eq('status', 'completed')
          .gte('created_at', startOfDay); // Chỉ lấy đơn hôm nay

      double sum = 0;
      int count = 0;
      if (revenueResponse != null && revenueResponse is List) {
        for (var row in revenueResponse) {
          sum += (row['total_price'] as num).toDouble();
        }
        count = revenueResponse.length;
      }

      // 2. LẤY DANH SÁCH 10 ĐƠN HÀNG GẦN NHẤT (Không lọc theo ngày để test)
      // Lưu ý: Nếu muốn chỉ hiện hôm nay thì thêm .gte('created_at', startOfDay) vào
      final listResponse = await Supabase.instance.client
          .from('orders')
          .select('*')
          .eq('status', 'completed')
          .order('created_at', ascending: false) // Mới nhất lên đầu
          .limit(10); // Chỉ lấy 10 đơn

      List<Map<String, dynamic>> orders = [];
      if (listResponse != null && listResponse is List) {
        orders = List<Map<String, dynamic>>.from(listResponse);
      }

      if (mounted) {
        setState(() {
          _totalRevenue = sum;
          _orderCount = count;
          _averageOrderValue = count > 0 ? sum / count : 0;
          _recentOrders = orders;
          _isLoading = false;
        });
        print("✅ Đã tải xong: $_orderCount đơn hôm nay, ${orders.length} đơn trong lịch sử.");
      }
    } catch (e) {
      print("❌ LỖI SUPABASE: $e"); // Xem lỗi chi tiết ở đây
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // HEADER
              _buildHeaderSection(),

              // THỐNG KÊ NHỎ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard("Đơn hàng (Hôm nay)", "$_orderCount", Icons.receipt_long, Colors.orange)),
                    const SizedBox(width: 15),
                    Expanded(child: _buildStatCard("Trung bình đơn", currencyFormat.format(_averageOrderValue).replaceAll(' ', ''), Icons.analytics, Colors.blue)),
                  ],
                ),
              ),

              // DANH SÁCH LỊCH SỬ
              _buildRecentOrdersList(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Text("Báo Cáo Hôm Nay", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("Tổng Doanh Thu", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          Text(
            currencyFormat.format(_totalRevenue),
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text("Giao dịch gần nhất", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          if (_recentOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(child: Text("Chưa có giao dịch nào", style: GoogleFonts.poppins(color: Colors.grey))),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentOrders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = _recentOrders[index];
                // Xử lý ngày giờ an toàn
                String timeString = "---";
                if (order['created_at'] != null) {
                  final createdAt = DateTime.parse(order['created_at']).toLocal();
                  timeString = DateFormat('dd/MM HH:mm').format(createdAt);
                }

                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.greenAccent, child: Icon(Icons.check, color: Colors.white, size: 16)),
                  title: Text("Đơn hàng #${order['id']}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(timeString, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  trailing: Text(
                    currencyFormat.format(order['total_price'] ?? 0),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}