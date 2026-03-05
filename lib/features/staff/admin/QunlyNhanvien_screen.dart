import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:test2025/data/Serve/staff_service.dart';
import 'them_nhanvien.dart';
import 'nhanvien_deatil_screen.dart';
import 'chinhsua_nhanvien.dart';

class QuanLyNhanVienScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const QuanLyNhanVienScreen({super.key, required this.onNavigate});

  @override
  State<QuanLyNhanVienScreen> createState() => _QuanLyNhanVienScreenState();
}

class _QuanLyNhanVienScreenState extends State<QuanLyNhanVienScreen> {
  final StaffService _staffService = StaffService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allStaff = []; // Dữ liệu gốc
  List<Map<String, dynamic>> _displayStaff = []; // Dữ liệu hiển thị
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStaff();
  }

  // Lấy dữ liệu từ Service
  Future<void> _fetchStaff() async {
    setState(() => _isLoading = true);
    try {
      final data = await _staffService.getAllStaff();
      if (mounted) {
        setState(() {
          _allStaff = data;
          _applyFilters(); // Lọc dữ liệu ngay khi tải xong
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm lọc tìm kiếm
  void _applyFilters() {
    setState(() {
      _displayStaff = _allStaff.where((staff) {
        return staff['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  // Chuyển trang Thêm nhân viên
  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ThemNhanVienScreen()),
    );
    if (result == true) {
      _fetchStaff(); // Refresh lại danh sách nếu có thêm mới
    }
  }

  // Xóa nhân viên (Logic ví dụ)
  Future<void> _deleteStaff(String id, String name) async {
    // 1. Hiện hộp thoại xác nhận trước khi xóa
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận xóa", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: "Bạn có chắc chắn muốn xóa nhân viên "),
              TextSpan(
                text: name,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const TextSpan(text: " không?\nHành động này không thể hoàn tác."),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          // Nút Hủy
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy bỏ", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          // Nút Xóa
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Xóa ngay", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    // 2. Nếu người dùng chọn "Hủy" hoặc bấm ra ngoài thì dừng lại
    if (confirm != true) return;

    // 3. Thực hiện xóa trong Database
    try {
      await _staffService.deleteStaff(int.parse(id));

      if (mounted) {
        // Hiện thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text("Đã xóa nhân viên $name", style: GoogleFonts.poppins()),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Load lại danh sách nhân viên
        _fetchStaff();
      }
    } catch (e) {
      if (mounted) {
        // Hiện thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi khi xóa: $e", style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper: Chọn màu theo chức vụ
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
      case 'admin':
        return Colors.redAccent;
      case 'barista':
        return Colors.brown;
      case 'chef':
        return Colors.orange;
      case 'cashier':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  // Helper: Tên hiển thị tiếng Việt
  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
      case 'admin':
        return 'Quản Lý';
      case 'barista':
        return 'Pha Chế';
      case 'chef':
        return 'Đầu Bếp';
      case 'cashier':
        return 'Thu Ngân';
      default:
        return 'Nhân Viên';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // Bỏ FloatingActionButton ở dưới
      body: Column(
        children: [
          // 1. HEADER (Giống Menu Screen)
          _buildTopHeader(),

          // 2. DANH SÁCH NHÂN VIÊN
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayStaff.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Không tìm thấy nhân viên",
                      style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 80, left: 16, right: 16),
              itemCount: _displayStaff.length,
              itemBuilder: (context, index) {
                final staff = _displayStaff[index];
                return _buildStaffCard(staff);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER ---
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng 1: Tiêu đề + Nút Thêm
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Nhân Sự",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2575FC),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.person_add, size: 20),
                label: Text(
                  "Thêm NV",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hàng 2: Ô Tìm kiếm
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Tìm tên hoặc email...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET THẺ NHÂN VIÊN ---
  Widget _buildStaffCard(Map<String, dynamic> staff) {
    final String name = staff['name'] ?? 'Unknown';
    final String email = staff['email'] ?? '';
    final String role = staff['role'] ?? 'staff';
    final Color roleColor = _getRoleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // SỰ KIỆN 1: Bấm vào thẻ để xem chi tiết
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StaffDetailScreen(staff: staff),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 1. Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: roleColor.withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Thông tin chính
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: roleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getRoleDisplayName(role).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Menu Thao tác (3 chấm)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) async {
                    // SỰ KIỆN 2: Xử lý menu 3 chấm
                    if (value == 'view') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StaffDetailScreen(staff: staff),
                        ),
                      );
                    }
                    if (value == 'edit') {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChinhSuaNhanVienScreen(staff: staff),),
                      );
                    }
                    if (value == 'delete') {
                      _deleteStaff(staff['id'].toString(), name);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text("Xem hồ sơ")),
                    const PopupMenuItem(
                        value: 'edit', child: Text("Chỉnh sửa")),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text("Xóa", style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}