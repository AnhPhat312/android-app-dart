import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test2025/data/Serve/inventory_service.dart';
import 'inventory_add_edit.dart';

class QuanLyKhoScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const QuanLyKhoScreen({super.key, required this.onNavigate});

  @override
  State<QuanLyKhoScreen> createState() => _QuanLyKhoScreenState();
}

class _QuanLyKhoScreenState extends State<QuanLyKhoScreen> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<Map<String, dynamic>>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _refreshInventory();
  }

  void _refreshInventory() {
    setState(() {
      _inventoryFuture = _inventoryService.getInventory();
    });
  }

  void _navigateToAddEdit({Map<String, dynamic>? item}) async {
    // Giữ nguyên logic cũ
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InventoryAddEditScreen(existingItem: item)),
    );
    if (result == true) _refreshInventory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // AppBar đơn giản hơn vì đã có Header bên dưới
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A11CB), // Màu tím
        elevation: 0,
        title: Text("Quản Lý Kho", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _inventoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Kho trống", style: GoogleFonts.poppins()));
          }

          final inventory = snapshot.data!;
          // Tính toán thống kê
          int totalItems = inventory.length;
          int lowStockCount = inventory.where((item) {
            double stock = double.tryParse(item['stock'].toString()) ?? 0;
            double min = double.tryParse(item['min_threshold'].toString()) ?? 0;
            return stock <= min;
          }).length;

          return Column(
            children: [
              // HEADER STATS
              _buildStatsHeader(totalItems, lowStockCount),

              // DANH SÁCH ITEM
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: inventory.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return _buildInventoryItem(item);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        backgroundColor: const Color(0xFF4CAF50), // Màu xanh lá cho Kho
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatsHeader(int total, int lowStock) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard("Tổng mặt hàng", "$total", Icons.inventory_2, Colors.blue),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildStatCard("Cần nhập ngay", "$lowStock", Icons.warning_amber_rounded, Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInventoryItem(Map<String, dynamic> item) {
    double stock = double.tryParse(item['stock'].toString()) ?? 0;
    double min = double.tryParse(item['min_threshold'].toString()) ?? 0;
    bool isLow = stock <= min;

    return InkWell(
      onTap: () => _navigateToAddEdit(item: item),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isLow ? Border.all(color: Colors.red.withOpacity(0.5), width: 1) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLow ? Colors.red[50] : Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLow ? FontAwesomeIcons.circleExclamation : FontAwesomeIcons.boxOpen,
                color: isLow ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${item['unit']}", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$stock",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isLow ? Colors.red : Colors.black87,
                  ),
                ),
                Text("Min: $min", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }
}