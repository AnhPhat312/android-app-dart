import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Import Drawer (đảm bảo đường dẫn đúng với project của bạn)
import 'package:test2025/Drawer/Drawer.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Hàm helper để dịch trạng thái sang tiếng Việt và chọn màu
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {'text': 'Đang chờ xác nhận', 'color': Colors.orange};
      case 'cooking':
        return {'text': 'Đang nấu', 'color': Colors.blue};
      case 'done':
        return {'text': 'Hoàn thành', 'color': Colors.green};
      case 'cancelled':
        return {'text': 'Đã hủy', 'color': Colors.red};
      default:
        return {'text': status, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy user hiện tại
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Lịch sử gọi món"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // Drawer
      drawer: MyDrawer(onTap: (index) {
        Navigator.pop(context);
      }),

      // PHẦN BODY ĐÃ ĐƯỢC SỬA LỖI CẤU TRÚC NGOẶC
      body: user == null
          ? const Center(child: Text("Vui lòng đăng nhập để xem lịch sử."))
          : FutureBuilder<List<Map<String, dynamic>>>(
        // Query lấy dữ liệu 3 lớp: Orders -> OrderItems -> MenuItems
        future: Supabase.instance.client
            .from('orders')
            .select('*, order_items(*, menu_items(name))')
            .eq('user_id', user.id)
            .order('created_at', ascending: false),

        builder: (context, snapshot) {
          // 1. Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Có lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          // 3. Dữ liệu rỗng
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text("Bạn chưa có đơn hàng nào!"),
                ],
              ),
            );
          }

          // 4. Hiển thị danh sách
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(order);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusInfo = _getStatusInfo(order['status'] ?? 'pending');
    // Parse ngày tháng an toàn
    final DateTime createdAt = DateTime.parse(order['created_at']).toLocal();
    final int total = order['total_price'] ?? 0;
    final String table = order['table_number'] ?? '?';

    // Danh sách món ăn kèm theo
    final List<dynamic> items = order['order_items'] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (statusInfo['color'] as Color).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.receipt, color: statusInfo['color']),
        ),
        title: Text(
          "Đơn hàng: #${order['id']} (Bàn $table)",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusInfo['color'],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusInfo['text'],
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: Text(
          currencyFormat.format(total),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple),
        ),

        // Phần mở rộng: Chi tiết món ăn
        children: [
          const Divider(),
          ...items.map((item) {
            // Lấy tên món an toàn (tránh null nếu món đã bị xóa khỏi menu)
            final menuName = item['menu_items'] != null
                ? item['menu_items']['name']
                : 'Món đã xóa';
            final quantity = item['quantity'];
            final price = item['price'];

            return ListTile(
              dense: true,
              title: Text(menuName),
              trailing: Text("${quantity}x  ${currencyFormat.format(price)}"),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}