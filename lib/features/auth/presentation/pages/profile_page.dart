import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../finance/presentation/bloc/finance_bloc.dart';
import '../../../finance/presentation/bloc/finance_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  // Các biến cấu hình cài đặt giả lập
  bool _darkMode = false;
  bool _dailyReminder = true;
  bool _pinLock = false;

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Đăng xuất',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi BeeSaving không?',
        ),
        actions: [
          TextButton(
            child: const Text('Hủy'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text(
              'Đăng xuất',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // Hàm tính toán danh hiệu Ong
  Map<String, String> _getBeeBadge(double balance, double totalIncome) {
    double savingRate = totalIncome > 0 ? (balance / totalIncome) : 0.0;
    if (savingRate > 0.5) {
      return {
        'title': 'Ong Chúa (Queen Bee) 👑',
        'desc': 'Tiết kiệm xuất sắc trên 50% thu nhập!',
        'color': '0xFFFCD400',
      };
    } else if (savingRate >= 0.3) {
      return {
        'title': 'Ong Trưởng Thành (Pro Bee) 🐝',
        'desc': 'Tích lũy tốt từ 30% - 50% thu nhập!',
        'color': '0xFF4CAF50',
      };
    } else if (savingRate >= 0.1) {
      return {
        'title': 'Ong Chăm Chỉ (Worker Bee) 🍀',
        'desc': 'Đang cố gắng tích lũy từ 10% - 30%!',
        'color': '0xFF2196F3',
      };
    } else {
      return {
        'title': 'Ong Non (Baby Bee) 👶',
        'desc': 'Tỷ lệ tích lũy còn thấp (<10%), cố gắng lên nha!',
        'color': '0xFFBA1A1A',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String displayName = 'Người dùng';
        String email = 'user@beesaving.com';
        if (authState is AuthAuthenticated) {
          displayName =
              authState.user.displayName ??
              authState.user.email.split('@').first;
          email = authState.user.email;
        }

        return BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, financeState) {
            double balance = 0.0;
            double income = 0.0;
            int txCount = 0;
            double savingRate = 0.0;

            if (financeState is FinanceLoaded) {
              balance = financeState.balance;
              income = financeState.totalIncome;
              txCount = financeState.transactions.length;
              savingRate = income > 0 ? (balance / income) * 100 : 0.0;
            }

            final badgeInfo = _getBeeBadge(balance, income);
            final badgeColor = Color(int.parse(badgeInfo['color']!));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── THÔNG TIN CÁ NHÂN HEADER ──
                  Center(
                    child: Column(
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.quicksand(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── HUY HIỆU DANH HIỆU ──
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: badgeColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    color: badgeColor.withValues(alpha: 0.06),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.stars,
                              color: badgeColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  badgeInfo['title']!,
                                  style: GoogleFonts.quicksand(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: badgeColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  badgeInfo['desc']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── CHỈ SỐ THỐNG KÊ NHANH ──
                  Row(
                    children: [
                      _buildStatCard(
                        'Số dư tích lũy',
                        _currencyFormat.format(balance),
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Tỷ lệ tích lũy',
                        '${savingRate.toStringAsFixed(0)}%',
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        'Đã ghi chép',
                        '$txCount giao dịch',
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── CÀI ĐẶT ỨNG DỤNG ──
                  Text(
                    'Cài đặt ứng dụng',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Switch 1: Dark Mode
                  _buildSettingSwitch(
                    icon: Icons.dark_mode_outlined,
                    label: 'Chế độ tối',
                    value: _darkMode,
                    onChanged: (val) {
                      setState(() => _darkMode = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Chế độ tối đang được phát triển ở phiên bản kế tiếp! 🌗',
                          ),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),

                  // Switch 2: Nhắc nhở
                  _buildSettingSwitch(
                    icon: Icons.notifications_active_outlined,
                    label: 'Nhắc nhở ghi chép hàng ngày',
                    value: _dailyReminder,
                    onChanged: (val) {
                      setState(() => _dailyReminder = val);
                    },
                  ),
                  const SizedBox(height: 8),

                  // Switch 3: Khóa vân tay
                  _buildSettingSwitch(
                    icon: Icons.fingerprint_rounded,
                    label: 'Khóa bảo mật vân tay / PIN',
                    value: _pinLock,
                    onChanged: (val) {
                      setState(() => _pinLock = val);
                    },
                  ),
                  const SizedBox(height: 8),

                  // ListTile 4: Trợ giúp
                  Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(
                        Icons.help_outline_rounded,
                        color: Colors.blue,
                      ),
                      title: Text(
                        'Trợ giúp & Liên hệ',
                        style: GoogleFonts.quicksand(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'BeeSaving',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              '© 2026 BeeSaving Dev Team. Bản quyền được bảo lưu.',
                          children: [
                            const SizedBox(height: 12),
                            const Text(
                              'BeeSaving là ứng dụng quản lý chi tiêu thông minh, giúp người dùng lập kế hoạch tiết kiệm hiệu quả nhờ thuật toán tối ưu hóa tầm quan trọng.',
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── NÚT ĐĂNG XUẤT ──
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorContainer,
                      foregroundColor: AppColors.error,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      'Đăng xuất tài khoản',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showSignOutDialog(context),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.outline),
        title: Text(
          label,
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
