import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PerformanceScreen extends StatelessWidget {
  const PerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> staffList = [
      {"name": "Nguyễn Văn A", "role": "Pha chế", "score": "150 ly", "rank": 1},
      {"name": "Trần Thị B", "role": "Thu ngân", "score": "142 đơn", "rank": 2},
      {"name": "Lê C", "role": "Phục vụ", "score": "5 sao", "rank": 3},
      {"name": "Phạm D", "role": "Pha chế", "score": "90 ly", "rank": 4},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Xếp Hạng Thi Đua"), backgroundColor: Colors.amber, foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: staffList.length,
        itemBuilder: (context, index) {
          final staff = staffList[index];
          final isTop3 = index < 3;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: isTop3 ? 4 : 1,
            color: isTop3 ? Colors.white : Colors.grey[50],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isTop3 ? const BorderSide(color: Colors.amber, width: 1) : BorderSide.none
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isTop3 ? Colors.amber : Colors.grey,
                foregroundColor: Colors.white,
                child: Text("#${staff['rank']}"),
              ),
              title: Text(staff['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(staff['role']),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(staff['score'], style: TextStyle(fontWeight: FontWeight.bold, color: isTop3 ? Colors.amber[800] : Colors.black)),
                  if(isTop3) const Icon(FontAwesomeIcons.crown, size: 12, color: Colors.amber),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}