import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}
// -----------------------------------------------------------------------------
//                            2. MÀN HÌNH CHÍNH (SETTINGS)
// -----------------------------------------------------------------------------
class _SettingsScreen extends State<SettingsScreen> {
  // Biến trạng thái
  bool _notificationEnabled = true;
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    // Lấy màu chính từ theme (Màu tím/DeepPurple)
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          "Cài đặt",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          // Cài đặt chung
          _buildSectionHeader('Cài Đặt Chung'),
          _buildSettingsSwitch(
            icon: Icons.notifications,
            iconColor: const Color(0xFF6A5ACD),
            title: 'Thông báo đẩy',
            subtitle: 'Nhận thông báo về đơn hàng mới',
            value: _notificationEnabled,
            onChanged: (value) {
              setState(() {
                _notificationEnabled = value;
              });
            },
          ),
          _buildSettingsSwitch(
            icon: Icons.volume_up,
            iconColor: const Color(0xFF6A5ACD),
            title: 'Âm thanh thông báo',
            subtitle: 'Phát âm thanh khi có đơn hàng',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),

          // Cài đặt in ấn
          _buildSectionHeader('Cài Đặt In Ấn'),
          _buildSettingsItem(
            icon: Icons.print,
            title: 'Máy in nhiệt',
            subtitle: 'Cấu hình kết nối máy in',
            onTap: () {
              // Điều hướng đến ThermalPrinterScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ThermalPrinterScreen()),
              );
            },
          ),

          // Bảo mật
          _buildSectionHeader('Bảo Mật'),
          _buildSettingsItem(
            icon: Icons.lock,
            title: 'Đổi mật khẩu',
            onTap: () {
              // Điều hướng đến ChangePasswordScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.fingerprint,
            title: 'Đăng nhập vân tay',
            subtitle: 'Bật/Tắt đăng nhập bằng vân tay',
            onTap: () {
              // Điều hướng đến BiometricAuthScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BiometricAuthScreen()),
              );
            },
          ),

          // Hệ thống
          _buildSectionHeader('Hệ Thống'),
          _buildSettingsItem(
            icon: Icons.backup,
            title: 'Sao lưu dữ liệu',
            onTap: () {
              // Điều hướng tới BackupScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupScreen()),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.restore,
            title: 'Khôi phục dữ liệu',
            onTap: () {
              // --- CẬP NHẬT ĐIỀU HƯỚNG TỚI RESTORESCREEN ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RestoreScreen()),
              );
            },
          ),
          _buildSettingsItem(
            icon: Icons.delete,
            title: 'Xóa dữ liệu',
            subtitle: 'Xóa toàn bộ dữ liệu cửa hàng',
            onTap: () {
              _showDeleteConfirmDialog(context);
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  // --- Các Widget Tiện Ích (Methods) ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A5ACD),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color textColor = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6A5ACD)),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF6A5ACD)),
      onTap: onTap,
    );
  }

  Widget _buildSettingsSwitch({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      thumbColor:
      MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return iconColor;
        }
        return Colors.white;
      }),
      trackColor:
      MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return iconColor.withOpacity(0.5);
        }
        return Colors.grey.shade300;
      }),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận Xóa dữ liệu'),
        content: const Text(
            'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu cửa hàng? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Dữ liệu đã được xóa (mô phỏng).')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//                            3. MÀN HÌNH CẤU HÌNH MÁY IN
// -----------------------------------------------------------------------------

class ThermalPrinterScreen extends StatefulWidget {
  const ThermalPrinterScreen({super.key});

  @override
  State<ThermalPrinterScreen> createState() => _ThermalPrinterScreenState();
}

class _ThermalPrinterScreenState extends State<ThermalPrinterScreen> {
  // --- Biến trạng thái giả lập ---
  bool _isScanning = false;
  String _paperSize = '58mm'; // Mặc định 58mm
  String? _connectedDeviceName; // Thiết bị đang kết nối

  // Danh sách thiết bị tìm thấy (Giả lập)
  List<Map<String, String>> _devices = [];

  @override
  void initState() {
    super.initState();
    // Tự động quét khi vào màn hình
    _startScan();
  }

  // Hàm giả lập quét thiết bị Bluetooth
  void _startScan() async {
    setState(() {
      _isScanning = true;
      _devices = []; // Reset danh sách
    });

    // Giả vờ đợi 2 giây để quét
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isScanning = false;
        // Thêm dữ liệu giả
        _devices = [
          {'name': 'Xprinter XP-N160II', 'mac': '00:11:22:33:44:55'},
          {'name': 'Printer-58 Thermal', 'mac': 'AA:BB:CC:DD:EE:FF'},
          {'name': 'POS-80 Generic', 'mac': '12:34:56:78:90:AB'},
        ];
      });
    }
  }

  // Hàm xử lý kết nối
  void _connectDevice(String name) {
    setState(() {
      _connectedDeviceName = name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã kết nối với $name thành công!')),
    );
  }

  // Hàm in thử
  void _testPrint() {
    if (_connectedDeviceName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng kết nối máy in trước!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Đang gửi lệnh in mẫu tới $_connectedDeviceName...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền nhẹ
      appBar: AppBar(
        title: Text(
          "Cấu hình Máy in nhiệt",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _isScanning
                ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _isScanning ? null : _startScan,
            tooltip: "Quét lại",
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Phần 1: Cấu hình khổ giấy ---
            Text("Cấu hình chung",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.grey[700])),
            const SizedBox(height: 10),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Khổ giấy 58mm (Nhỏ)"),
                      subtitle: const Text("Phù hợp máy in cầm tay"),
                      value: '58mm',
                      groupValue: _paperSize,
                      activeColor: primaryColor,
                      onChanged: (value) => setState(() => _paperSize = value!),
                    ),
                    Divider(height: 1, color: Colors.grey[200]),
                    RadioListTile<String>(
                      title: const Text("Khổ giấy 80mm (Lớn)"),
                      subtitle: const Text("Phù hợp máy in để bàn"),
                      value: '80mm',
                      groupValue: _paperSize,
                      activeColor: primaryColor,
                      onChanged: (value) => setState(() => _paperSize = value!),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Phần 2: Danh sách thiết bị ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Danh sách thiết bị",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, color: Colors.grey[700])),
                if (_isScanning)
                  Text("Đang quét...",
                      style: TextStyle(color: primaryColor, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            // Hiển thị danh sách hoặc thông báo trống
            _devices.isEmpty && !_isScanning
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                    "Không tìm thấy thiết bị nào.\nHãy đảm bảo Bluetooth đã bật.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500])),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices[index];
                final isConnected =
                    _connectedDeviceName == device['name'];

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(Icons.print,
                        color: isConnected ? Colors.green : Colors.grey),
                    title: Text(device['name']!,
                        style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(device['mac']!),
                    trailing: isConnected
                        ? const Icon(Icons.check_circle,
                        color: Colors.green)
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor.withOpacity(0.1),
                        foregroundColor: primaryColor,
                        elevation: 0,
                      ),
                      onPressed: () =>
                          _connectDevice(device['name']!),
                      child: const Text("Kết nối"),
                    ),
                    onTap: () => _connectDevice(device['name']!),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Nút in thử ở dưới cùng
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _testPrint,
          icon: const Icon(Icons.print),
          label: const Text("IN THỬ (TEST PRINT)"),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//                            4. MÀN HÌNH ĐỔI MẬT KHẨU
// -----------------------------------------------------------------------------

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Key để kiểm tra form (Validation)
  final _formKey = GlobalKey<FormState>();

  // Controller để lấy dữ liệu từ ô nhập
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  // Biến trạng thái ẩn/hiện mật khẩu
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Trạng thái loading
  bool _isLoading = false;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi thoát màn hình
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // Hàm xử lý đổi mật khẩu
  void _handleChangePassword() async {
    // 1. Kiểm tra điều kiện (Validate)
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // 2. Giả lập gọi API (Đợi 2 giây)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // 3. Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đổi mật khẩu thành công! vui lòng đăng nhập lại.'),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Quay lại màn hình trước
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đổi mật khẩu",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tạo mật khẩu mới",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Mật khẩu mới của bạn phải khác với mật khẩu trước đó.",
                style:
                GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 30),

              // --- Ô 1: Mật khẩu hiện tại ---
              _buildPasswordField(
                controller: _currentPassController,
                label: "Mật khẩu hiện tại",
                obscureText: _obscureCurrent,
                onToggleVisibility: () {
                  setState(() => _obscureCurrent = !_obscureCurrent);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu hiện tại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Ô 2: Mật khẩu mới ---
              _buildPasswordField(
                controller: _newPassController,
                label: "Mật khẩu mới",
                obscureText: _obscureNew,
                onToggleVisibility: () {
                  setState(() => _obscureNew = !_obscureNew);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu mới';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Ô 3: Nhập lại mật khẩu mới ---
              _buildPasswordField(
                controller: _confirmPassController,
                label: "Xác nhận mật khẩu mới",
                obscureText: _obscureConfirm,
                onToggleVisibility: () {
                  setState(() => _obscureConfirm = !_obscureConfirm);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != _newPassController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // --- Nút Lưu ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    "LƯU THAY ĐỔI",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget con để vẽ ô nhập mật khẩu (Tránh lặp code)
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode:
      AutovalidateMode.onUserInteraction, // Kiểm tra ngay khi gõ
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//                            5. MÀN HÌNH CẤU HÌNH VÂN TAY (SINH TRẮC HỌC - MÔ PHỎNG UI)
// -----------------------------------------------------------------------------

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  // --- Biến trạng thái mô phỏng ---
  bool _biometricsEnabled = false;
  // Luôn đặt là true để mô phỏng rằng thiết bị hỗ trợ vân tay/Face ID
  bool _canCheckBiometrics = true;

  @override
  void initState() {
    super.initState();
    // Mô phỏng kiểm tra khả năng hỗ trợ (giả lập luôn thành công)
    _checkBiometricsSupport();
  }

  // Hàm mô phỏng kiểm tra khả năng hỗ trợ
  Future<void> _checkBiometricsSupport() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _canCheckBiometrics = true;
      });
    }
  }

  // Hàm xử lý Bật/Tắt đăng nhập vân tay
  void _toggleBiometrics(bool newValue) async {
    if (!_canCheckBiometrics) {
      // Trường hợp này sẽ không bao giờ xảy ra vì _canCheckBiometrics = true (mô phỏng)
      return;
    }

    if (newValue) {
      // *Bước 1: Giả lập xác thực người dùng thành công sau 1 giây*
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đang mô phỏng xác thực...'),
            backgroundColor: Colors.blue),
      );
      await Future.delayed(const Duration(seconds: 1));

      bool authenticated = true; // GIẢ LẬP XÁC THỰC THÀNH CÔNG

      if (authenticated) {
        setState(() {
          _biometricsEnabled = newValue;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng nhập vân tay đã được BẬT (Mô phỏng).'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Phần này giữ lại cho logic UI thật, nhưng trong mô phỏng luôn là true
      }
    } else {
      // Tắt chỉ cần cập nhật trạng thái
      setState(() {
        _biometricsEnabled = newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng nhập vân tay đã được TẮT.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Cấu hình Sinh trắc học",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              secondary: Icon(
                Icons.fingerprint,
                color: _canCheckBiometrics ? primaryColor : Colors.grey,
              ),
              title: const Text('Bật Đăng nhập bằng vân tay/Face ID'),
              subtitle: Text(
                _canCheckBiometrics
                    ? (_biometricsEnabled
                    ? 'Đang bật. Mô phỏng xác thực khi mở ứng dụng.'
                    : 'Bấm để kích hoạt mô phỏng.')
                    : 'Thiết bị không hỗ trợ tính năng này.',
              ),
              value: _biometricsEnabled,
              onChanged: _canCheckBiometrics ? _toggleBiometrics : null,
              activeColor: primaryColor,
              // Giống như Switch trong SettingsScreen
              thumbColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return primaryColor;
                    }
                    return Colors.white;
                  }),
              trackColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return primaryColor.withOpacity(0.5);
                    }
                    return Colors.grey.shade300;
                  }),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '* Lưu ý: Đây là chế độ mô phỏng UI. Trong ứng dụng thực tế, cần thêm thư viện local_auth và cấu hình hệ điều hành.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//                            6. MÀN HÌNH SAO LƯU DỮ LIỆU
// -----------------------------------------------------------------------------

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  // --- Biến trạng thái mô phỏng ---
  String _backupLocation = 'Google Drive';
  String _lastBackupTime = '2025-12-07 23:59:00';
  bool _autoBackupEnabled = true;
  bool _isBackingUp = false;

  // Hàm mô phỏng quá trình sao lưu
  void _startManualBackup() async {
    setState(() {
      _isBackingUp = true;
    });

    // Giả lập quá trình sao lưu diễn ra trong 3 giây
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isBackingUp = false;
        // Cập nhật thời gian sao lưu gần nhất
        _lastBackupTime =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sao lưu hoàn tất vào $_backupLocation.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Hàm hiển thị hộp thoại chọn nơi lưu trữ
  void _showLocationSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chọn nơi lưu trữ',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  RadioListTile<String>(
                    title: const Text('Google Drive'),
                    value: 'Google Drive',
                    groupValue: _backupLocation,
                    onChanged: (value) {
                      setModalState(() => _backupLocation = value!);
                      setState(() => _backupLocation = value!);
                      Navigator.pop(context);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  RadioListTile<String>(
                    title: const Text('Bộ nhớ cục bộ (Local Storage)'),
                    value: 'Local Storage',
                    groupValue: _backupLocation,
                    onChanged: (value) {
                      setModalState(() => _backupLocation = value!);
                      setState(() => _backupLocation = value!);
                      Navigator.pop(context);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Sao lưu dữ liệu",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Phần 1: Trạng thái sao lưu ---
            _buildSectionHeader('Trạng thái'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Lần sao lưu gần nhất:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(_lastBackupTime,
                            style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nơi lưu trữ:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(_backupLocation,
                            style: TextStyle(color: primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // --- Phần 2: Cấu hình Tự động/Nơi lưu trữ ---
            _buildSectionHeader('Cấu hình'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.location_on, color: primaryColor),
                    title: const Text('Chọn nơi lưu trữ'),
                    subtitle: Text('Hiện tại: $_backupLocation'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showLocationSelection,
                  ),
                  Divider(height: 1, color: Colors.grey[200]),
                  SwitchListTile(
                    secondary: Icon(Icons.schedule, color: primaryColor),
                    title: const Text('Tự động sao lưu'),
                    subtitle: Text(_autoBackupEnabled
                        ? 'Dữ liệu sẽ được sao lưu tự động hàng ngày.'
                        : 'Sao lưu thủ công khi cần thiết.'),
                    value: _autoBackupEnabled,
                    onChanged: (value) {
                      setState(() => _autoBackupEnabled = value);
                    },
                    activeColor: primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- Phần 3: Nút Sao lưu thủ công ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _isBackingUp ? null : _startManualBackup,
                icon: _isBackingUp
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isBackingUp ? "Đang sao lưu..." : "SAO LƯU NGAY BÂY GIỜ",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Quá trình sao lưu có thể mất vài phút tùy theo kích thước dữ liệu.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6A5ACD),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//                            7. MÀN HÌNH KHÔI PHỤC DỮ LIỆU (MỚI TRIỂN KHAI)
// -----------------------------------------------------------------------------

class RestoreScreen extends StatefulWidget {
  const RestoreScreen({super.key});

  @override
  State<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends State<RestoreScreen> {
  // Giả lập danh sách các file sao lưu tìm thấy
  final List<Map<String, String>> _backupFiles = [
    {
      'name': '2025-12-07_Backup_GD.zip',
      'size': '5.2 MB',
      'date': '07/12/2025 23:59',
      'location': 'Google Drive'
    },
    {
      'name': '2025-12-06_Backup_GD.zip',
      'size': '4.8 MB',
      'date': '06/12/2025 23:58',
      'location': 'Google Drive'
    },
    {
      'name': '2025-12-01_Backup_Local.zip',
      'size': '4.1 MB',
      'date': '01/12/2025 10:30',
      'location': 'Local Storage'
    },
  ];

  Map<String, String>? _selectedFile;
  bool _isRestoring = false;

  // Hàm mô phỏng quá trình Khôi phục
  void _startRestore() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn một file để khôi phục.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isRestoring = true;
    });

    // Giả lập quá trình khôi phục mất 4 giây
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() {
        _isRestoring = false;
        _selectedFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Khôi phục dữ liệu từ ${_backupFiles[0]['date']} thành công! Ứng dụng sẽ khởi động lại (Mô phỏng).'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        ),
      );
      // Giả lập quay lại màn hình chính sau khi khôi phục
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Khôi phục dữ liệu",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Mô tả và Cảnh báo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Chọn file sao lưu bạn muốn khôi phục. Dữ liệu hiện tại sẽ bị ghi đè.',
              style: TextStyle(
                  color: Colors.red[700], fontWeight: FontWeight.w500),
            ),
          ),

          // Danh sách File Sao lưu
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _backupFiles.length,
              itemBuilder: (context, index) {
                final file = _backupFiles[index];
                final isSelected = _selectedFile == file;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                        color: isSelected ? primaryColor : Colors.transparent,
                        width: 2),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.cloud_download,
                        color: isSelected ? primaryColor : Colors.grey),
                    title: Text(file['name']!,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        'Kích thước: ${file['size']} | Nơi lưu: ${file['location']}'),
                    trailing: Text(file['date']!,
                        style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      setState(() {
                        _selectedFile = file;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Nút Khôi phục ở dưới cùng
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: ElevatedButton.icon(
          onPressed:
          _isRestoring || _selectedFile == null ? null : _startRestore,
          icon: _isRestoring
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.restore_page),
          label: Text(
            _isRestoring ? "Đang khôi phục dữ liệu..." : "KHÔI PHỤC DỮ LIỆU",
            style:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Dùng màu cảnh báo (Restore)
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
//                            8. MÀN HÌNH MẪU ĐIỀU HƯỚNG (DUMMY SCREEN)
// -----------------------------------------------------------------------------

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins()),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Đây là $title',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}

