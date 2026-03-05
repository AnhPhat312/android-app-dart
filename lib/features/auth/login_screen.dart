import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test2025/data/Serve/auth_service.dart';

// Import các màn hình điều hướng (Đảm bảo đường dẫn đúng)
import 'package:test2025/features/dashboard/main_screen.dart';
import 'package:test2025/features/staff/staff_dashboard.dart';
import 'package:test2025/features/menu/khach_hang/customer_menu_screen.dart';
import 'register_screens.dart';

class LoginScreen extends StatefulWidget {
  final String? preFilledEmail;

  const LoginScreen({super.key, this.preFilledEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.preFilledEmail != null) {
      _emailController.text = widget.preFilledEmail!;
    }
  }

  // --- LOGIC ĐĂNG NHẬP
  void _handleLogin() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      // GỌI HÀM: signInWithEmailPassword (theo đúng file Auth của bạn)
      final response = await _authService.signInWithEmailPassword(email, password);

      if (response.user != null) {
        if (!mounted) return;

        // Lấy role từ metadata (giống logic file auth cũ của bạn)
        final role = response.user!.userMetadata?['role'] ?? 'user';

        // Điều hướng
        if (role == 'manager') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
        } else if (role == 'staff') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CustomerMenuScreen()));
        }
      }
    } on AuthException catch (e) {
      String friendlyMessage = "Đã xảy ra lỗi!";

      if (e.message.contains("Invalid login credentials")) {
        friendlyMessage = "Email hoặc mật khẩu không chính xác.";
      } else if (e.message.contains("Email not confirmed")) {
        friendlyMessage = "Vui lòng xác nhận email trước khi đăng nhập.";
      } else if (e.message.contains("Network")) {
        friendlyMessage = "Lỗi kết nối mạng. Vui lòng thử lại.";
      } else {
        // Nếu là các lỗi khác, có thể giữ nguyên hoặc đặt một câu chung chung
        friendlyMessage = "Lỗi: ${e.message}";
      }

      // 🔹 BƯỚC 2: Hiển thị thông báo đã dịch lên UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyMessage),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior
                .floating, // Hiển thị nổi cho chuyên nghiệp
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi đăng nhập: Vui lòng kiểm tra lại'), backgroundColor: Colors.red),
      );
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
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
            ),
          ),

          // 2. NỘI DUNG
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.coffee, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "4 MAN",
                    style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 40),

                  // CARD FORM
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.deepPurple),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Mật khẩu",
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.deepPurple),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? ", style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Register())),
                        child: const Text("Đăng ký ngay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}