// lib/backup_screen.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color backupColor = Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sao Lưu Dữ Liệu Đám Mây"),
        backgroundColor: backupColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Trạng thái hiện tại ---
            _buildStatusCard(backupColor),

            const SizedBox(height: 20),

            // --- Nút Sao lưu thủ công ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Đang khởi tạo Sao lưu thủ công...")),
                  );
                },
                icon: const Icon(FontAwesomeIcons.cloudArrowUp),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Text("SAO LƯU NGAY BÂY GIỜ",
                      style: TextStyle(fontSize: 16)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: backupColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // --- Lịch sử Sao lưu (Đã truyền context) ---
            _buildHistorySection(backupColor, context),
          ],
        ),
      ),
    );
  }

  // 👇 HÀM NÀY PHẢI NẰM TRONG CLASS BackupScreen
  Widget _buildStatusCard(Color color) {
    return Card(
      color: color.withOpacity(0.05),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Trạng Thái Sao Lưu",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Icon(FontAwesomeIcons.circleCheck,
                    color: Colors.green, size: 28),
              ],
            ),
            const Divider(height: 20),
            _buildDetailRow(
                "Lần cuối sao lưu", "07/12/2025 - 02:00 AM", Colors.black),
            _buildDetailRow(
                "Loại sao lưu", "Tự động (Hàng ngày)", Colors.black),
            _buildDetailRow("Kích thước dữ liệu", "5.2 GB", Colors.black),
            _buildDetailRow("Trạng thái", "Thành công", Colors.green),
          ],
        ),
      ),
    );
  }

  // 👇 HÀM NÀY PHẢI NẰM TRONG CLASS BackupScreen
  Widget _buildHistorySection(Color color, BuildContext context) {
    final List<Map<String, dynamic>> history = const [
      {
        "date": "07/12/2025",
        "time": "02:00 AM",
        "status": "Thành công",
        "color": Colors.green
      },
      {
        "date": "06/12/2025",
        "time": "02:00 AM",
        "status": "Thành công",
        "color": Colors.green
      },
      {
        "date": "05/12/2025",
        "time": "02:00 AM",
        "status": "Thành công",
        "color": Colors.green
      },
      {
        "date": "04/12/2025",
        "time": "02:00 AM",
        "status": "Thất bại",
        "color": Colors.red
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lịch Sử Sao Lưu Gần Đây",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        ...history
            .map((e) => ListTile(
                  leading: Icon(FontAwesomeIcons.database, color: color),
                  title: Text("Sao lưu ngày ${e['date']}"),
                  subtitle: Text("Thời gian: ${e['time']}"),
                  trailing: Text(e['status'],
                      style: TextStyle(
                          color: e['color'], fontWeight: FontWeight.bold)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text("Xem chi tiết sao lưu ngày ${e['date']}")),
                    );
                  },
                ))
            .toList(),
      ],
    );
  }

  // 👇 HÀM NÀY PHẢI NẰM TRONG CLASS BackupScreen
  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
