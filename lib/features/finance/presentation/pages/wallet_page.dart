import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with TickerProviderStateMixin {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  // Biến kiểm soát số dư cục bộ để hỗ trợ tính năng chuyển khoản giả lập
  double? _mainWallet;
  double? _savingsWallet;
  double? _piggyBank;
  double _lastBaseBalance = 0.0;

  String _sourceWallet = 'Ví chính';
  String _targetWallet = 'Heo đất';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Đồng bộ số dư cục bộ dựa trên số dư từ FinanceBloc
  void _syncBalances(double baseBalance) {
    if (_mainWallet == null || baseBalance != _lastBaseBalance) {
      _mainWallet = baseBalance * 0.6;
      _savingsWallet = baseBalance * 0.3;
      _piggyBank = baseBalance * 0.1;
      _lastBaseBalance = baseBalance;
    }
  }

  void _showTransferBottomSheet(BuildContext context) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chuyển tiền giữa các ví',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ví nguồn
                    DropdownButtonFormField<String>(
                      initialValue: _sourceWallet,
                      decoration: const InputDecoration(
                        labelText: 'Ví nguồn (Từ)',
                        prefixIcon: Icon(
                          Icons.outbox_rounded,
                          color: Colors.red,
                        ),
                      ),
                      items: ['Ví chính', 'Ví tiết kiệm', 'Heo đất'].map((
                        wallet,
                      ) {
                        return DropdownMenuItem(
                          value: wallet,
                          child: Text(wallet),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _sourceWallet = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ví đích
                    DropdownButtonFormField<String>(
                      initialValue: _targetWallet,
                      decoration: const InputDecoration(
                        labelText: 'Ví đích (Đến)',
                        prefixIcon: Icon(
                          Icons.inbox_rounded,
                          color: Colors.green,
                        ),
                      ),
                      items: ['Ví chính', 'Ví tiết kiệm', 'Heo đất'].map((
                        wallet,
                      ) {
                        return DropdownMenuItem(
                          value: wallet,
                          child: Text(wallet),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => _targetWallet = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Số tiền chuyển
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số tiền chuyển (VND)',
                        prefixIcon: Icon(
                          Icons.monetization_on,
                          color: Colors.orange,
                        ),
                        hintText: 'Nhập số tiền...',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số tiền';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Số tiền phải lớn hơn 0';
                        }
                        if (_sourceWallet == _targetWallet) {
                          return 'Ví nguồn và ví đích phải khác nhau';
                        }

                        // Kiểm tra số dư ví nguồn
                        double sourceBalance = 0.0;
                        if (_sourceWallet == 'Ví chính') {
                          sourceBalance = _mainWallet ?? 0;
                        }
                        if (_sourceWallet == 'Ví tiết kiệm') {
                          sourceBalance = _savingsWallet ?? 0;
                        }
                        if (_sourceWallet == 'Heo đất') {
                          sourceBalance = _piggyBank ?? 0;
                        }

                        if (amount > sourceBalance) {
                          return 'Số dư ${_sourceWallet.toLowerCase()} không đủ (${_currencyFormat.format(sourceBalance)})';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Nút chuyển tiền
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final double amount = double.parse(
                            _amountController.text,
                          );

                          // Thực hiện chuyển khoản cục bộ
                          setState(() {
                            // Trừ ví nguồn
                            if (_sourceWallet == 'Ví chính') {
                              _mainWallet = (_mainWallet ?? 0) - amount;
                            }
                            if (_sourceWallet == 'Ví tiết kiệm') {
                              _savingsWallet = (_savingsWallet ?? 0) - amount;
                            }
                            if (_sourceWallet == 'Heo đất') {
                              _piggyBank = (_piggyBank ?? 0) - amount;
                            }

                            // Cộng ví đích
                            if (_targetWallet == 'Ví chính') {
                              _mainWallet = (_mainWallet ?? 0) + amount;
                            }
                            if (_targetWallet == 'Ví tiết kiệm') {
                              _savingsWallet = (_savingsWallet ?? 0) + amount;
                            }
                            if (_targetWallet == 'Heo đất') {
                              _piggyBank = (_piggyBank ?? 0) + amount;
                            }
                          });

                          Navigator.pop(ctx);
                          _showSuccessDialog(
                            context,
                            _sourceWallet,
                            _targetWallet,
                            amount,
                          );
                        }
                      },
                      child: const Text(
                        'Xác nhận chuyển',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    String from,
    String to,
    double amount,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                Text(
                  'Chuyển tiền thành công! 🎉',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn đã chuyển thành công ${_currencyFormat.format(amount)} từ $from sang $to để tiết kiệm.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tuyệt vời'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        if (state is FinanceLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (state is FinanceError) {
          return Center(child: Text(state.message));
        } else if (state is FinanceLoaded) {
          _syncBalances(state.balance);

          final totalAsset =
              (_mainWallet ?? 0) + (_savingsWallet ?? 0) + (_piggyBank ?? 0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card Tổng tài sản ──
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Tổng tài sản thực tế',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currencyFormat.format(totalAsset),
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Biểu đồ Phân bổ tài sản ──
                if (totalAsset > 0) ...[
                  Text(
                    'Phân bổ tài sản',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 180,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.green[600]!,
                                    value: _mainWallet ?? 0,
                                    title:
                                        '${((_mainWallet ?? 0) / totalAsset * 100).toStringAsFixed(0)}%',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.blue[600]!,
                                    value: _savingsWallet ?? 0,
                                    title:
                                        '${((_savingsWallet ?? 0) / totalAsset * 100).toStringAsFixed(0)}%',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange[600]!,
                                    value: _piggyBank ?? 0,
                                    title:
                                        '${((_piggyBank ?? 0) / totalAsset * 100).toStringAsFixed(0)}%',
                                    radius: 50,
                                    titleStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildLegendItem('Ví chính', Colors.green[600]!),
                              _buildLegendItem(
                                'Ví tiết kiệm',
                                Colors.blue[600]!,
                              ),
                              _buildLegendItem('Heo đất', Colors.orange[600]!),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Danh sách các ví ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tài khoản của bạn',
                      style: GoogleFonts.quicksand(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.08,
                        ),
                        foregroundColor: AppColors.primary,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text(
                        'Chuyển tiền',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => _showTransferBottomSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ví 1: Ví chính
                _buildWalletCard(
                  title: 'Ví chính',
                  subtitle: 'Giao dịch hàng ngày, ăn uống, hóa đơn',
                  balance: _mainWallet ?? 0,
                  colors: [Colors.green[600]!, Colors.green[800]!],
                  icon: Icons.wallet_rounded,
                ),
                const SizedBox(height: 12),

                // Ví 2: Ví tiết kiệm
                _buildWalletCard(
                  title: 'Ví tiết kiệm',
                  subtitle: 'Tích lũy mua nhà, mua xe, học tập',
                  balance: _savingsWallet ?? 0,
                  colors: [Colors.blue[600]!, Colors.blue[800]!],
                  icon: Icons.account_balance_rounded,
                ),
                const SizedBox(height: 12),

                // Ví 3: Heo đất tiết kiệm
                _buildWalletCard(
                  title: 'Heo đất tiết kiệm',
                  subtitle: 'Tiết kiệm mục tiêu ngắn hạn, mua đồ lưu niệm',
                  balance: _piggyBank ?? 0,
                  colors: [Colors.orange[600]!, Colors.orange[800]!],
                  icon: Icons.savings_rounded,
                ),
                const SizedBox(height: 80), // Cách FAB
              ],
            ),
          );
        }
        return const Center(child: Text('Lỗi không xác định'));
      },
    );
  }

  Widget _buildLegendItem(String name, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWalletCard({
    required String title,
    required String subtitle,
    required double balance,
    required List<Color> colors,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.quicksand(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
