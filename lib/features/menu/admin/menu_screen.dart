import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test2025/data/Serve/menu_service.dart';
import './add_menu.dart';
import './item_detail_screen.dart';
import 'package:intl/intl.dart';

class MenuScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const MenuScreen({super.key, required this.onNavigate});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuService _menuService = MenuService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allMenuItems = [];
  List<Map<String, dynamic>> _displayItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = [
    'Tất cả',
    'Trà Sữa',
    'Cà Phê',
    'Sinh Tố',
    'Nước Ép',
    'Trà Trái Cây',
    'Đồ Ăn Nhẹ',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() => _isLoading = true);
    final data = await _menuService.fetchItems();
    if (mounted) {
      setState(() {
        _allMenuItems = data;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _displayItems = _allMenuItems.where((item) {
        final matchSearch = item['name']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
        final matchCategory = _selectedCategory == 'Tất cả' ||
            item['category'] == _selectedCategory;
        return matchSearch && matchCategory;
      }).toList();
    });
  }

  void _navigateToAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMenuItemForm()),
    );
    if (result == true) _fetchMenu();
  }

  void _navigateToEditItem(Map<String, dynamic> item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddMenuItemForm(existingItem: item)),
    );
    if (result == true) _fetchMenu();
  }

  void _deleteItem(Map<String, dynamic> item) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa món '${item['name']}' không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm) {
      await _menuService.deleteItem(item['id']);
      _fetchMenu();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Đã xóa món ăn")));
      }
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return "0 đ";
    final formatter = NumberFormat('#,###', 'vi_VN');
    return "${formatter.format(price)} đ";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // Xóa FloatingActionButton ở dưới để dời lên trên
      body: Column(
        children: [
          // 1. HEADER MỚI (Chứa nút Thêm món)
          _buildTopHeader(),

          // 2. DANH SÁCH MÓN ĂN
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off,
                      size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Không tìm thấy món nào",
                      style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 80, left: 16, right: 16),
              itemCount: _displayItems.length,
              itemBuilder: (context, index) {
                final item = _displayItems[index];
                return _buildMenuItemCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER TÙY CHỈNH ---
  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
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
          // Hàng 1: Tiêu đề + Nút Thêm Món (Ở ĐÂY)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thực Đơn",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToAddItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2575FC),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: Text(
                  "Thêm Món",
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
                hintText: "Tìm tên món ăn...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Hàng 3: Danh mục (Category Chips)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _applyFilters();
                    });
                  },
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color:
                    isSelected ? const Color(0xFF2575FC) :  Colors.deepPurple,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET THẺ MÓN ĂN ---
  Widget _buildMenuItemCard(Map<String, dynamic> item) {
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
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => ItemDetailScreen(itemData: item)));
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 1. Hình ảnh
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade100,
                    child: (item['image_url'] != null &&
                        item['image_url'].toString().isNotEmpty)
                        ? Image.network(item['image_url'], fit: BoxFit.cover,
                        errorBuilder: (c, e, s) =>
                        const Icon(Icons.broken_image))
                        : const Icon(Icons.fastfood,
                        color: Colors.deepPurple, size: 30),
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'],
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(item['category'] ?? 'Khác',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(_formatPrice(item['price']),
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 15)),
                    ],
                  ),
                ),

                // 3. Nút menu 3 chấm
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'view') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => ItemDetailScreen(itemData: item)));
                    }
                    if (value == 'edit') _navigateToEditItem(item);
                    if (value == 'delete') _deleteItem(item);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: 'view', child: Text("Xem chi tiết")),
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