import 'package:supabase_flutter/supabase_flutter.dart';

// Khởi tạo client toàn cục (hoặc bạn có thể import từ main.dart nếu đã khai báo)
final supabase = Supabase.instance.client;

class MenuService {
  final String _tableName = 'menu_items';

  // 1. READ: Lấy tất cả món ăn
  Future<List<Map<String, dynamic>>> fetchItems() async {
    try {
      final response = await supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false); // Mới nhất lên đầu

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Lỗi tải menu: $e');
      return []; // Trả về rỗng nếu lỗi để app không crash
    }
  }

  // 2. CREATE: Thêm món ăn mới
  Future<void> createItem(Map<String, dynamic> newItem) async {
    try {
      await supabase.from(_tableName).insert(newItem);
    } catch (e) {
      print('Lỗi thêm món: $e');
      throw Exception('Không thể thêm món ăn: $e');
    }
  }

  // 3. UPDATE: Cập nhật món ăn
  Future<void> updateItem(dynamic id, Map<String, dynamic> updatedData) async {
    try {
      await supabase.from(_tableName).update(updatedData).eq('id', id);
    } catch (e) {
      print('Lỗi cập nhật món: $e');
      throw Exception('Không thể cập nhật món ăn: $e');
    }
  }

  // 4. DELETE: Xóa món ăn (MỚI THÊM)
  Future<void> deleteItem(dynamic id) async {
    try {
      await supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      print('Lỗi xóa món: $e');
      throw Exception('Không thể xóa món ăn');
    }
  }
}