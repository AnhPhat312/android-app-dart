// lib/order_detail_screen.dart

import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> itemData;
  final String listTitle;
  final Color color;

  const OrderDetailScreen({
    super.key,
    required this.itemData,
    required this.listTitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi Tiết: ${itemData['id']}"),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Mục Báo Cáo: $listTitle",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                "Đơn Hàng: ${itemData['id']}",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Giá trị: ${itemData['value']}",
                style: TextStyle(fontSize: 20, color: color),
              ),
              const SizedBox(height: 10),
              Text(
                "Ngày: ${itemData['date']}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Text(
                  "Đây là trang chi tiết để hiển thị các mặt hàng trong đơn."),
            ],
          ),
        ),
      ),
    );
  }
}
