import 'package:supabase_flutter/supabase_flutter.dart';

class StaffService {
  final _supabase = Supabase.instance.client;

  // 1. Lấy danh sách nhân viên
  Future<List<Map<String, dynamic>>> getAllStaff() async {
    try {
      print("⏳ Đang gọi lên Supabase lấy danh sách...");

      // Select * from staffs (Lấy cả cột id để dùng cho sửa/xóa)
      final response = await _supabase
          .from('staffs')
          .select()
          .order('created_at', ascending: false);

      final dataList = List<Map<String, dynamic>>.from(response);
      return dataList;

    } catch (e) {
      print("❌ LỖI LẤY LIST: $e");
      throw Exception("Không tải được dữ liệu: $e");
    }
  }

  // 2. Thêm nhân viên
  Future<void> addStaff(Map<String, dynamic> staffData) async {
    try {
      await _supabase.from('staffs').insert(staffData);
    } catch (e) {
      print("❌ Lỗi thêm: $e");
      rethrow;
    }
  }

  // 3. Cập nhật nhân viên (MỚI BỔ SUNG)
  // id: ID của nhân viên cần sửa (Lấy từ Supabase)
  // updatedData: Map chứa thông tin mới
  Future<void> updateStaff(int id, Map<String, dynamic> updatedData) async {
    try {
      // Xóa các trường không cần thiết trước khi update (ví dụ created_at, id) nếu có dính vào
      final dataToUpdate = Map<String, dynamic>.from(updatedData);
      dataToUpdate.remove('id');
      dataToUpdate.remove('created_at');

      await _supabase
          .from('staffs')
          .update(dataToUpdate)
          .eq('id', id); // Điều kiện: Update dòng nào có id bằng id truyền vào

      print("✅ Đã cập nhật thành công ID: $id");
    } catch (e) {
      print("❌ Lỗi cập nhật: $e");
      rethrow;
    }
  }

  // 4. Xóa nhân viên (MỚI BỔ SUNG)
  Future<void> deleteStaff(int id) async {
    try {
      await _supabase
          .from('staffs')
          .delete()
          .eq('id', id); // Điều kiện: Xóa dòng có id này

      print("✅ Đã xóa thành công ID: $id");
    } catch (e) {
      print("❌ Lỗi xóa: $e");
      rethrow;
    }
  }
}