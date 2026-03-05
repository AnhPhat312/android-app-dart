# ☕ Smart Store Management System - Flutter Project

Ứng dụng quản lý cửa hàng (Coffee/Bakery) toàn diện với hệ thống phân quyền thông minh, hỗ trợ tối ưu quy trình bán hàng, kiểm kho và báo cáo tài chính. Dự án được phát triển trong kỳ thực tập nhằm áp dụng các kiến trúc lập trình hiện đại vào thực tế.

---

## Tổng quan bài toán (Problem Statement)
Dự án được xây dựng để giải quyết 3 vấn đề cốt lõi của các cửa hàng bán lẻ:
1. **Thất thoát dữ liệu:** Số hóa toàn bộ giao dịch và lịch sử nhập xuất kho.
2. **Khó khăn trong giám sát:** Cung cấp biểu đồ thống kê trực quan cho người quản lý từ xa.
3. **Phân quyền phức tạp:** Phân tách rõ ràng giao diện và chức năng giữa Admin, Nhân viên và Khách hàng.

---

## Tính năng nổi bật (Core Features)

### Phân quyền người dùng (Role-based Access Control)

* **Admin:** Quản lý nhân sự (CRUD), theo dõi báo cáo doanh thu/lợi nhuận, quản lý kho tổng, sao lưu dữ liệu.
* **Staff:** Quản lý thực đơn, xử lý đơn hàng tại bàn, cập nhật tình trạng nguyên liệu sắp hết hạn.
* **Guest:** Xem Menu điện tử (E-Menu) với hình ảnh trực quan và chi tiết sản phẩm.

###  Thống kê & Báo cáo (Data Visualization)
* **Biểu đồ đường (Line Chart):** Theo dõi xu hướng doanh thu và lợi nhuận theo các tháng trong năm.
* **Biểu đồ tròn (Pie Chart):** Phân tích hiệu suất bán hàng dựa trên từng danh mục sản phẩm.
* **Báo cáo chi tiết:** Truy xuất dữ liệu chi tiết cho từng chỉ số kinh doanh.

###  Quản lý vận hành
* Cảnh báo hàng hóa sắp hết hạn hoặc bị hỏng (Expired Items Alert).
* Hệ thống thông báo lỗi đồng bộ hóa dữ liệu thời gian thực.

---

## 🛠 Kỹ thuật & Kiến trúc (Technical Highlights)

* **Architecture:** Áp dụng kiến trúc **Feature-based** giúp chia nhỏ dự án thành các Module độc lập (Auth, Statistics, Staff, Inventory...), giúp dễ dàng bảo trì và làm việc nhóm.
* **UI/UX:** * Sử dụng `Google Fonts` (Poppins) và `FontAwesome` icons để tạo giao diện hiện đại.
    * Tích hợp các Widget tùy chỉnh để tối ưu hóa khả năng tái sử dụng code.
* **Performance Optimization:**
    * Sử dụng `GridView.builder` và `ListView.builder` với `shrinkWrap` phù hợp để tối ưu bộ nhớ.
    * Tận dụng tối đa từ khóa `const` để giảm thiểu gánh nặng cho CPU khi re-build widget.

---

##  Cấu trúc thư mục (Project Structure)
```text
lib/
├── core/           # Widgets dùng chung, constants, theme
├── data/           # Models, Services (API), Providers
├── features/       # Chia theo tính năng (auth, statistics, staff, menu, inventory)
└── main.dart       # Điểm khởi chạy ứng dụng
