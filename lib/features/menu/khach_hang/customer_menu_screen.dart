import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Đảm bảo đường dẫn này đúng với project của bạn
import 'package:test2025/Drawer/Drawer.dart';

class CustomerMenuScreen extends StatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  // Biến giỏ hàng: {ID_Món : Số_Lượng}
  final Map<int, int> _cart = {};

  // Format tiền tệ Việt Nam
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  // --- 1. CÁC HÀM XỬ LÝ GIỎ HÀNG ---
  void _addToCart(int id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(int id) {
    setState(() {
      if (_cart.containsKey(id) && _cart[id]! > 0) {
        _cart[id] = _cart[id]! - 1;
        if (_cart[id] == 0) {
          _cart.remove(id);
        }
      }
    });
  }

  // Tính tổng tiền
  int _calculateTotal(List<Map<String, dynamic>> menuItems) {
    int total = 0;
    for (var item in menuItems) {
      int id = item['id'];
      // Xử lý giá an toàn (tránh lỗi null hoặc double)
      int price = (item['price'] is int) ? item['price'] : int.tryParse(item['price'].toString()) ?? 0;

      if (_cart.containsKey(id)) {
        total += price * _cart[id]!;
      }
    }
    return total;
  }

  // --- 2. HÀM HIỂN THỊ HỘP THOẠI NHẬP SỐ BÀN ---
  void _showTableDialog(List<Map<String, dynamic>> menuItems) {
    final TextEditingController tableController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vui lòng chọn bàn"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Để bếp biết mang món đến đâu, hãy nhập số bàn bạn đang ngồi:"),
            const SizedBox(height: 10),
            TextField(
              controller: tableController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Số bàn (Ví dụ: 5)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.table_restaurant),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (tableController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Vui lòng nhập số bàn!")),
                );
                return;
              }
              Navigator.pop(context); // Đóng hộp thoại
              // Gọi hàm đặt món chính thức
              _placeOrder(menuItems, tableController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            child: const Text("Xác nhận & Đặt món"),
          ),
        ],
      ),
    );
  }

  // --- 3. HÀM GỬI ĐƠN HÀNG LÊN SUPABASE ---
  Future<void> _placeOrder(List<Map<String, dynamic>> menuItems, String tableNumber) async {
    if (_cart.isEmpty) return;

    try {
      // Hiển thị Loading
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => const Center(child: CircularProgressIndicator())
      );

      // A. Tạo đơn hàng trong bảng 'orders'
      final int total = _calculateTotal(menuItems);
      final user = Supabase.instance.client.auth.currentUser;
      final orderResponse = await Supabase.instance.client
          .from('orders')
          .insert({
        'user_id': user?.id,
        'table_number': tableNumber, // Lưu số bàn
        'total_price': total,
        'status': 'pending', // Trạng thái: Chờ bếp nhận
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final int orderId = orderResponse['id'];

      // B. Tạo chi tiết món trong bảng 'order_items'
      List<Map<String, dynamic>> orderItemsData = [];

      _cart.forEach((menuId, quantity) {
        // Tìm món trong list để lấy giá hiện tại
        final item = menuItems.firstWhere((element) => element['id'] == menuId);

        orderItemsData.add({
          'order_id': orderId,
          'menu_item_id': menuId, // QUAN TRỌNG: Kiểm tra tên cột này trong DB (menu_id hay menu_item_id?)
          'quantity': quantity,
          'price': item['price']
        });
      });

      // Gửi list món ăn lên
      await Supabase.instance.client
          .from('order_items')
          .insert(orderItemsData);

      // C. Hoàn tất
      if (mounted) {
        Navigator.pop(context); // Tắt loading
        setState(() {
          _cart.clear(); // Xóa giỏ hàng
        });

        // Hiện thông báo thành công đẹp mắt
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            title: const Text("Đặt món thành công!"),
            content: Text("Bếp đã nhận đơn cho Bàn $tableNumber.\nVui lòng đợi trong giây lát."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("Đóng"))
            ],
          ),
        );
      }

    } catch (e) {
      if (mounted) Navigator.pop(context); // Tắt loading nếu lỗi

      // Hiện thông báo lỗi chi tiết
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          icon: const Icon(Icons.error, color: Colors.red),
          title: const Text("Lỗi gửi đơn"),
          content: SingleChildScrollView(child: Text("Chi tiết: $e")),
          actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Đóng"))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: MyDrawer(
        onTap: (index) {
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thực Đơn", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Chạm vào món để chọn", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),

      // --- STREAM LẤY DỮ LIỆU TỪ BẢNG 'menu_items' ---
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('menu_items')
            .stream(primaryKey: ['id'])
            .order('name', ascending: true),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi tải menu: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final menuItems = snapshot.data!;
          if (menuItems.isEmpty) {
            return const Center(child: Text("Menu đang trống!"));
          }

          return Stack(
            children: [
              // DANH SÁCH MÓN ĂN
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 80),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Tỷ lệ khung hình chữ nhật đứng
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(menuItems[index]);
                  },
                ),
              ),

              // THANH GIỎ HÀNG & THANH TOÁN
              if (_cart.isNotEmpty)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: _buildBottomCartBar(menuItems),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET THẺ MÓN ĂN ---
  Widget _buildFoodCard(Map<String, dynamic> item) {
    final int id = item['id'];
    final String name = item['name'] ?? 'Món chưa tên';
    final int price = (item['price'] is int) ? item['price'] : int.tryParse(item['price'].toString()) ?? 0;
    final String? imageUrl = item['image_url'];
    final int quantity = _cart[id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Ảnh món (Xử lý lỗi 404)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: (imageUrl != null && imageUrl.isNotEmpty)
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // Nếu ảnh lỗi (404) thì hiện icon
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              )
                  : Container(
                color: Colors.deepPurple.withOpacity(0.1),
                child: const Icon(Icons.fastfood, size: 40, color: Colors.deepPurple),
              ),
            ),
          ),

          // 2. Thông tin & Nút bấm
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  currencyFormat.format(price),
                  style: GoogleFonts.poppins(color: Colors.deepPurple, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),

                quantity == 0
                    ? SizedBox(
                  height: 30,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple,
                      side: const BorderSide(color: Colors.deepPurple),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text("Thêm", style: TextStyle(fontSize: 12)),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _removeFromCart(id),
                      child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 26),
                    ),
                    Text("$quantity", style: const TextStyle(fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _addToCart(id),
                      child: const Icon(Icons.add_circle, color: Colors.green, size: 26),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET THANH THANH TOÁN ---
  Widget _buildBottomCartBar(List<Map<String, dynamic>> menuItems) {
    int total = _calculateTotal(menuItems);
    int count = _cart.values.fold(0, (sum, qty) => sum + qty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("$count món đã chọn", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(currencyFormat.format(total), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            // Bấm nút này sẽ hiện hộp thoại hỏi số bàn
            onPressed: () => _showTableDialog(menuItems),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Row(
              children: [
                Text("ĐẶT NGAY"),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          )
        ],
      ),
    );
  }
}