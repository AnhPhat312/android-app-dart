// lib/simple_line_chart.dart (ĐÃ SỬA LỖI)

import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart'; // Giữ lại nếu bạn định dùng sau này

class SimpleLineChart extends StatelessWidget {
  // 1. Định nghĩa các tham số BẮT BUỘC
  final Color color;
  final String title;

  // 2. Thêm các tham số này vào constructor
  const SimpleLineChart({
    super.key,
    required this.color, // Bắt buộc
    required this.title, // Bắt buộc
  });

  @override
  Widget build(BuildContext context) {
    // SỬ DỤNG THAM SỐ color VÀ title TRONG PLACEHOLDER
    return Center(
      child: Text(
        "BIỂU ĐỒ ĐƯỜNG: ${title} (Màu: ${color})",
        style: TextStyle(
          color: color.withOpacity(0.6), // Dùng màu truyền vào
          fontSize: 16,
        ),
      ),
    );
  }
}
