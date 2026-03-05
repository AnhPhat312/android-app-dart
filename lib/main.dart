import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import các màn hình và service
import 'features/auth/login_screen.dart';
import 'features/menu/khach_hang/customer_menu_screen.dart';
import 'features/dashboard/main_screen.dart';
import 'features/staff/staff_dashboard.dart';
import 'data/Serve/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lqdoncavoxhmsveyzbwz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxxZG9uY2F2b3hobXN2ZXl6Ynd6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMjY3MTgsImV4cCI6MjA3ODgwMjcxOH0.LXuhXDrV0YBjGtK0nJhWSLHHT-xk9LDMye9GgdV-MtM',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A5ACD),
          primary: const Color(0xFF6A5ACD),
          secondary: const Color(0xFFFF6B6B),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A5ACD),
          elevation: 0,
          centerTitle: false,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      ),
      // Thay vì gọi LoginScreen trực tiếp, ta gọi AuthGate để kiểm tra luồng
      home: const AuthGate(),
    );
  }
}

// --- WIDGET ĐIỀU PHỐI (Kiểm tra đăng nhập) ---
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  Widget _targetScreen = const LoginScreen();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    // 1. Nếu chưa đăng nhập -> Về trang Login
    if (session == null) {
      setState(() {
        _isLoading = false;
        _targetScreen = const LoginScreen();
      });
      return;
    }

    // 2. Nếu đã đăng nhập -> Kiểm tra Role để đưa về đúng nhà
    try {
      final authService = AuthService();
      final role = await authService.getUserRole();

      setState(() {
        _isLoading = false;
        if (role == 'manager') {
          _targetScreen = const MainScreen();
        } else if (role == 'staff') {
          // _targetScreen = const StaffDashboard();
          _targetScreen = const StaffDashboard(); // Tạm thời để MainScreen nếu chưa tạo file Staff
        } else {
          _targetScreen = const CustomerMenuScreen();
        }
      });
    } catch (e) {
      // Nếu lỗi, an toàn nhất là về trang Login
      setState(() {
        _isLoading = false;
        _targetScreen = const LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trong lúc đang kiểm tra session thì hiện vòng xoay
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _targetScreen;
  }
}