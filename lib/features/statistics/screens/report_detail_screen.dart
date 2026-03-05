import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'report_list_screen.dart'; // Import màn hình danh sách

class ReportDetailScreen extends StatelessWidget {
  final String title;
  final String metricValue;
  final Color color;

  const ReportDetailScreen({
    super.key,
    required this.title,
    required this.metricValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thẻ tổng quan lớn
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.chartLine, size: 40, color: color),
                  const SizedBox(height: 10),
                  Text(metricValue, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
                  Text("Tổng $title hôm nay", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Các chỉ số phụ
            _buildStatRow("So với hôm qua", "+12%", Colors.green),
            _buildStatRow("Trung bình/giờ", "1.5tr", Colors.blue),
            const Divider(height: 40),

            // Nút xem danh sách chi tiết
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Điều hướng sang màn hình danh sách cụ thể
                  Navigator.push(context, MaterialPageRoute(builder: (c) => ReportListScreen(
                      title: title,
                      metricValue: metricValue,
                      color: color
                  )));
                },
                icon: const Icon(Icons.list),
                label: Text("Xem danh sách $title chi tiết"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}