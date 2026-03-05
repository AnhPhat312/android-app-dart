import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:test2025/Drawer/Drawer.dart'; // Đảm bảo đúng đường dẫn Drawer của bạn

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  String _selectedFilter = 'pending'; // Mặc định xem đơn chờ
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA), // Màu nền sáng hiện đại
      appBar: AppBar(
        title: Text("BẾP & PHỤC VỤ", style: GoogleFonts.oswald(fontWeight: FontWeight.bold, letterSpacing: 1.5,color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          // Nút reload thủ công phòng khi mạng lag
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState((){}),
          )
        ],
      ),
      drawer: MyDrawer(
        onTap: (index) {

          Navigator.pop(context);

        },
      ),
      // StreamBuilder: Lắng nghe dữ liệu thật từ Supabase
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('orders')
            .stream(primaryKey: ['id'])
            .order('created_at', ascending: false),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Lỗi: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final allOrders = snapshot.data!;

          // Tính toán thống kê
          int total = allOrders.length;
          int completed = allOrders.where((o) => o['status'] == 'completed').length;
          double progress = total > 0 ? completed / total : 0;

          return Column(
            children: [
              // 1. HEADER THỐNG KÊ (Giống mẫu bạn thích)
              _buildModernHeader(total, completed, progress),

              // 2. THANH LỌC (Filter)
              _buildFilterBar(allOrders),

              // 3. DANH SÁCH ĐƠN HÀNG
              Expanded(
                child: _buildOrderList(allOrders),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET HEADER ĐẸP ---
  Widget _buildModernHeader(int total, int done, double percent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _statItem("TỔNG ĐƠN", total.toString(), Icons.receipt_long),
          _statItem("ĐÃ XONG", done.toString(), Icons.check_circle_outline),

          // Vòng tròn tiến độ
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: Colors.white12,
                  color: Colors.greenAccent,
                ),
              ),
              Text("${(percent * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 24),
        const SizedBox(height: 5),
        Text(value, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  // --- THANH LỌC TRẠNG THÁI ---
  Widget _buildFilterBar(List<Map<String, dynamic>> orders) {
    final statusList = ['pending', 'confirmed', 'served', 'completed'];
    final statusNames = {'pending': 'Chờ', 'confirmed': 'Làm', 'served': 'Ra món', 'completed': 'Xong'};

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        children: statusList.map((status) {
          int count = orders.where((o) => o['status'] == status).length;
          bool isSelected = _selectedFilter == status;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text("${statusNames[status]} ($count)"),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = status),
              selectedColor: const Color(0xFF1A237E),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- DANH SÁCH ĐƠN HÀNG ---
  Widget _buildOrderList(List<Map<String, dynamic>> allOrders) {
    final filtered = allOrders.where((o) => o['status'] == _selectedFilter).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee_maker, size: 80, color: Colors.grey[300]),
            Text("Không có đơn hàng nào", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        // SỬA LỖI MÀN HÌNH ĐỎ TẠI ĐÂY: Kiểm tra null an toàn
        final items = order['items'] != null ? List<dynamic>.from(order['items']) : [];

        final created = DateTime.parse(order['created_at']).toLocal();
        final timeString = DateFormat('HH:mm').format(created);

        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(10),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: _getStatusColor(order['status']).withOpacity(0.1),
              child: Text("${order['table_number']}",
                  style: TextStyle(color: _getStatusColor(order['status']), fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            title: Text("Bàn ${order['table_number']} • ${_currencyFormat.format(order['total_price'])}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text("Đặt lúc: $timeString", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            children: [
              const Divider(height: 1),
              // Danh sách món ăn
              ...items.map((item) => ListTile(
                dense: true,
                title: Text(item['name'] ?? "Không tên", style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(5)),
                  child: Text("x${item['quantity']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),

              // Nút hành động
              Padding(
                padding: const EdgeInsets.all(15),
                child: _buildActionButton(order),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(Map<String, dynamic> order) {
    String status = order['status'];
    String nextStatus = '';
    String label = '';
    Color color = Colors.blue;

    if (status == 'pending') { nextStatus = 'confirmed'; label = 'NHẬN ĐƠN'; color = Colors.orange; }
    else if (status == 'confirmed') { nextStatus = 'served'; label = 'RA MÓN'; color = Colors.blue; }
    else if (status == 'served') { nextStatus = 'completed'; label = 'HOÀN TẤT & TRỪ KHO'; color = Colors.green; }

    if (nextStatus == '') return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
        ),
        onPressed: () async {
          // Cập nhật trạng thái
          await Supabase.instance.client
              .from('orders')
              .update({'status': nextStatus})
              .eq('id', order['id']);
        },
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }
}