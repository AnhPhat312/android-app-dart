import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryService {
  final _supabase = Supabase.instance.client;

  // ---------------------------------------------------------------------------
  // PHẦN 1: QUẢN LÝ KHO
  // ---------------------------------------------------------------------------

  // 1. Lấy toàn bộ danh sách kho
  Future<List<Map<String, dynamic>>> getInventory() async {
    try {
      final response = await _supabase
          .from('inventory')
          .select()
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Lỗi lấy dữ liệu kho: $e");
      return []; // Trả về danh sách rỗng nếu lỗi
    }
  }

  // 2. Thêm món mới vào kho
  Future<void> addItem(Map<String, dynamic> itemData) async {
    await _supabase.from('inventory').insert(itemData);
  }

  // 3. Cập nhật kho (Sửa tên, số lượng, hoặc nhập hàng thêm)
  Future<void> updateItem(int id, Map<String, dynamic> updates) async {
    await _supabase.from('inventory').update(updates).eq('id', id);
  }

  // 4. Xóa món khỏi kho
  Future<void> deleteItem(int id) async {
    await _supabase.from('inventory').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------------
  // PHẦN 2: LOGIC TỰ ĐỘNG TRỪ KHO (NÂNG CAO)
  // ---------------------------------------------------------------------------

  // Hàm này được gọi khi nhân viên bấm "Thu tiền/Hoàn thành"
  Future<void> deductStockFromOrder(int orderId) async {
    try {
      print("--- Bắt đầu trừ kho cho đơn hàng $orderId ---");

      // B1: Lấy danh sách các món khách đã gọi trong đơn đó
      final orderItemsResponse = await _supabase
          .from('order_items')
          .select('menu_item_id, quantity')
          .eq('order_id', orderId);

      final List<dynamic> orderItems = orderItemsResponse;

      // B2: Duyệt qua từng món khách gọi
      for (var item in orderItems) {
        final int menuId = item['menu_item_id'];
        final int qtyOrdered = item['quantity']; // Khách gọi mấy ly?

        // B3: Tìm công thức pha chế của món đó (1 ly cần bao nhiêu nguyên liệu?)
        final recipesResponse = await _supabase
            .from('recipes')
            .select('inventory_item_id, amount_needed')
            .eq('menu_item_id', menuId);

        final List<dynamic> recipes = recipesResponse;

        if (recipes.isEmpty) {
          print("Món ID $menuId chưa có công thức, bỏ qua.");
          continue;
        }

        // B4: Trừ từng nguyên liệu trong kho
        for (var recipe in recipes) {
          final int inventoryId = recipe['inventory_item_id'];
          final double amountPerUnit = double.parse(recipe['amount_needed'].toString());

          // Tổng lượng cần trừ = Định lượng 1 ly * Số ly khách gọi
          final double totalDeduct = amountPerUnit * qtyOrdered;
          // tổng trừ = định lượng 1 ly * số ly khách gọi

          // Lấy tồn kho hiện tại
          final currentStockRes = await _supabase
              .from('inventory')
              .select('stock')
              .eq('id', inventoryId)
              .single();

          double currentStock = double.parse(currentStockRes['stock'].toString());
          // tính tồn mới
          double newStock = currentStock - totalDeduct;

          // Cập nhật số tồn mới
          await _supabase.from('inventory').update({
            'stock': newStock
          }).eq('id', inventoryId);

          print(">> Đã trừ nguyên liệu ID $inventoryId: $currentStock - $totalDeduct = $newStock");
        }
      }
      print("--- Hoàn tất trừ kho ---");

    } catch (e) {
      print("Lỗi nghiêm trọng khi trừ kho: $e");
      // Ở đây có thể thêm logic ghi log lỗi vào database để admin kiểm tra
    }
  }
}