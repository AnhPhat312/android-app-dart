import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  // Getter để truy cập client từ bên ngoài
  SupabaseClient get supabaseClient => _supabase;
  // ==================================================
  // 🔹 1. ĐĂNG KÝ (Sign Up)
  // ==================================================
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name, String role) async {
    try {
      // CHỈ CẦN GỌI HÀM NÀY, DATABASE SẼ TỰ ĐỘNG LƯU PROFILE
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role,
        },
      );


    } catch (e) {
      print('Lỗi đăng ký: $e');
      rethrow;
    }
  }

  // ==================================================
  // 🔹 2. ĐĂNG NHẬP (Sign In)
  // ==================================================
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _ensureProfileExists(response.user!);
      }

      return response;
    } catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  // ==================================================
  // 🔹 3. ĐĂNG XUẤT
  // ==================================================
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ==================================================
  // 🔹 4. LẤY QUYỀN (Get Role)
  // ==================================================
  Future<String> getUserRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'guest'; //khách

    try {
      // ƯU TIÊN 1: Lấy từ bảng 'users_profiles' (Dữ liệu chuẩn)
      final data = await _supabase
          .from('users_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && data['role'] != null) {
        return data['role'].toString();
      }

      // ƯU TIÊN 2: Nếu bảng chưa kịp tạo, lấy tạm từ Metadata của User
      return user.userMetadata?['role'] ?? 'user';

    } catch (e) {
      print('⚠️ Lỗi lấy role: $e. Dùng Metadata thay thế.');
      return user.userMetadata?['role'] ?? 'user';
    }
  }

  // ==================================================
  // 🔹 5. HÀM TẠO PROFILE
  // ==================================================
  Future<void> _ensureProfileExists(User user) async {
    try {
      // 1. Kiểm tra xem đã có profile chưa
      final data = await _supabase
          .from('users_profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // 2. Nếu chưa có thì Insert
      if (data == null) {
        print('🛠 Đang tạo profile cho user: ${user.email}');

        await _supabase.from('users_profiles').insert({
          'id': user.id,      // ID từ auth.users
          'email': user.email,
          // Lấy name từ metadata, nếu không có thì lấy phần đầu email
          'name': user.userMetadata?['name'] ?? user.email?.split('@')[0],
          'role': user.userMetadata?['role'] ?? 'user',
          'created_at': DateTime.now().toIso8601String(),
        });

        print('✅ Đã tạo profile thành công!');
      }
    } catch (e) {
      // Lỗi 42501 (Permission denied) sẽ xảy ra nếu RLS chưa cấu hình đúng
      // Nhưng ít nhất code này sẽ không làm crash app.
      print('⚠️ Không thể tạo profile (Lỗi DB hoặc Quyền): $e');
    }
  }
}