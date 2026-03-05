import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2025/data/Serve/auth_service.dart';
import 'package:test2025/features/auth/login_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedRole = 'user';
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- HÀM HIỂN THỊ DIALOG KHI TRÙNG EMAIL ---
  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text("Email đã tồn tại", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            children: [
              const TextSpan(text: "Email "),
              TextSpan(
                text: _emailController.text,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              const TextSpan(text: " đã được sử dụng.\nBạn có muốn chuyển sang trang Đăng nhập không?"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Thử lại", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen(preFilledEmail: _emailController.text))
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Đăng nhập"),
          ),
        ],
      ),
    );
  }

  void _handleSignup() async {
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đủ thông tin!'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Thực hiện đăng ký
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': _selectedRole},
      );

      if (!mounted) return;

      // 2. LOGIC BẮT LỖI KHI BỊ CHẾ ĐỘ BẢO MẬT CHẶN:
      // Nếu email đã tồn tại và Enumeration Protection đang BẬT,
      // response.user vẫn có thể có dữ liệu nhưng response.session sẽ NULL
      // và danh sách identities sẽ rỗng (empty).
      if (response.user != null && response.user!.identities != null && response.user!.identities!.isEmpty) {
        _showEmailExistsDialog(); // Hiện bảng thông báo trùng email của bạn
        setState(() => _isLoading = false);
        return;
      }

      // 3. Nếu thành công thực sự
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!'), backgroundColor: Colors.green));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen(preFilledEmail: email)));

    } on AuthException catch (e) {
      String friendlyMessage = "Đăng ký không thành công.";

      if (e.message.toLowerCase().contains("already registered") ||
          e.message.toLowerCase().contains("already exists")) {
        _showEmailExistsDialog(); // Giữ nguyên hàm dialog của bạn
        return;
      } else if (e.message.contains("Unable to validate email address")) {
        friendlyMessage = "Email không đúng định dạng. Vui lòng kiểm tra lại.";
      } else if (e.message.contains("Password should be at least")) {
        friendlyMessage = "Mật khẩu phải có ít nhất 6 ký tự.";
      } else {
        friendlyMessage = "Lỗi: ${e.message}";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi hệ thống: ${e.toString()}"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. NỀN GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
              ),
            ),
          ),

          // 2. NÚT BACK
          Positioned(
            top: 50, left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 3. NỘI DUNG FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.person, size: 60, color: Colors.white),
                  Text("Tạo tài khoản", style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "Họ và tên",
                            prefixIcon: const Icon(Icons.person, color: Colors.deepPurple),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email, color: Colors.deepPurple),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            prefixIcon: const Icon(Icons.lock, color: Colors.deepPurple),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true, fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[50],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.deepPurple),
                              items: const [
                                DropdownMenuItem(value: 'user', child: Text("Khách hàng (User)")),
                                DropdownMenuItem(value: 'staff', child: Text("Nhân viên (Staff)")),
                                DropdownMenuItem(value: 'manager', child: Text("Quản lý (Manager)")),
                              ],
                              onChanged: (val) => setState(() => _selectedRole = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("ĐĂNG KÝ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}