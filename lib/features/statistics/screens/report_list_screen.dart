import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReportListScreen extends StatelessWidget {
  final String title;
  final String metricValue;
  final Color color;

  const ReportListScreen({
    super.key,
    required this.title,
    required this.metricValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập: Danh sách đơn hàng cà phê
    final List<Map<String, dynamic>> listItems = [
      {"id": "DH001", "name": "Bàn 5 - 2 Cà phê sữa", "time": "14:20", "value": "55.000đ"},
      {"id": "DH002", "name": "Mang về - 1 Trà đào", "time": "14:15", "value": "35.000đ"},
      {"id": "DH003", "name": "Bàn 2 - Combo Bánh nước", "time": "14:00", "value": "85.000đ"},
      {"id": "DH004", "name": "Bàn 1 - 4 Bạc xỉu", "time": "13:45", "value": "120.000đ"},
      {"id": "DH005", "name": "Mang về - 1 Trà sữa", "time": "13:30", "value": "40.000đ"},
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Chi tiết $title"), backgroundColor: color, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: color.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tổng cộng: $metricValue", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                Text("${listItems.length} giao dịch", style: TextStyle(color: color)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: listItems.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = listItems[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade100,
                    child: Icon(FontAwesomeIcons.receipt, size: 16, color: color),
                  ),
                  title: Text(item['name']),
                  subtitle: Text("${item['id']} • ${item['time']}"),
                  trailing: Text(item['value'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chức năng xem chi tiết hóa đơn đang phát triển")));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}