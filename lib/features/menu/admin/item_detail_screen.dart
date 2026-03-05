import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ItemDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;

  const ItemDetailScreen({
    super.key,
    required this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy màu trạng thái
    Color statusColor = Colors.green;
    if (itemData['status'] == 'Hết hàng') statusColor = Colors.red;
    if (itemData['status'] == 'Ngừng kinh doanh') statusColor = Colors.grey;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Chi Tiết Món Ăn"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Ảnh đại diện (Placeholder)
            Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.deepPurple.shade100, width: 2)
                ),
                child: const Icon(FontAwesomeIcons.mugHot, size: 60, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Tên và Giá
            Text(
              itemData['name'],
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "${itemData['price']} VNĐ",
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[700]),
            ),

            const SizedBox(height: 20),

            // 3. Card thông tin chi tiết
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow("Danh mục", itemData['category'] ?? 'Chưa phân loại'),
                    const Divider(),
                    _buildDetailRow("Trạng thái", itemData['status'] ?? 'Còn hàng', color: statusColor),
                    const Divider(),
                    _buildDetailRow("Mô tả", itemData['description'] ?? 'Không có mô tả'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 4. Nút hành động (Ví dụ)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Quay lại danh sách"),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
                label,
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)
            ),
          ),
          Expanded(
            child: Text(
                value,
                style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87, fontSize: 16)
            ),
          ),
        ],
      ),
    );
  }
}