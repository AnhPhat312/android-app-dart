import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test2025/core/widgets/simple_line_chart.dart';

class QualityReportScreen extends StatelessWidget {
  const QualityReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color successColor = Colors.green;
    const Color failColor = Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Báo Cáo Chất Lượng Dịch Vụ"),
        backgroundColor: successColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Tổng quan chỉ số chính ---
            _buildMetricCard("Tỷ lệ Hoàn thành Đơn hàng", "98.5%", successColor,
                FontAwesomeIcons.circleCheck),
            const SizedBox(height: 10),
            _buildMetricCard("Tỷ lệ Đơn Hàng Thất Bại", "1.5%", failColor,
                FontAwesomeIcons.circleXmark),

            const Divider(height: 30),

            // --- Biểu đồ xu hướng ---
            const Text(
              "Xu Hướng Tỷ Lệ Hoàn Thành (7 Ngày Qua)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const SimpleLineChart(
                  color: successColor, title: "Tỷ lệ Hoàn thành"),
            ),

            const Divider(height: 30),

            // --- Phân tích chi tiết ---
            _buildDetailList(successColor, failColor),
          ],
        ),
      ),
    );
  }
  Widget _buildMetricCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade700)),
                Text(value,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailList(Color successColor, Color failColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Các yếu tố ảnh hưởng",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Divider(),
        _buildDetailRow(
            "Đơn hàng đã giao thành công", "985/1000", successColor),
        _buildDetailRow("Đơn hàng bị hủy", "10", failColor),
        _buildDetailRow("Đơn hàng không giao được", "5", failColor),
        _buildDetailRow(
            "Thời gian giao hàng trung bình", "35 phút", Colors.blue),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
