import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../../../features/savings/presentation/pages/savings_planner_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onTabChange; // Cho phép chuyển tab từ các nút bấm nhanh

  const HomePage({super.key, required this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final double _mockSavingTarget = 15000000.0; // Mục tiêu hũ tiết kiệm giả lập

  String _getMascotAdvice(double balance, double expenseRatio) {
    if (balance < 0) {
      return "Ôi không! Số dư của bạn đang âm rồi. Hãy dùng ngay tính năng 'Lập kế hoạch tiết kiệm' để cắt giảm chi phí không cần thiết nhé! 🍀";
    } else if (expenseRatio > 0.8) {
      return "Tỷ lệ chi tiêu của bạn khá cao (>80% thu nhập). Tớ khuyên bạn nên xem xét lại các khoản ăn uống hoặc mua sắm giải trí để tích lũy thêm vàng nha! 💰";
    } else if (balance > 10000000) {
      return "Tuyệt vời! Bạn đang quản lý tài chính rất tốt, hũ vàng đang đầy dần lên. Hãy đặt mục tiêu tiết kiệm lớn hơn để mua những thứ giá trị nhé! 🏆";
    } else {
      return "Chào bạn! Hôm nay bạn đã ghi chép chi tiêu chưa? Hãy tích lũy từng đồng xu nhỏ để tạo nên hũ vàng lớn cùng tớ nhé! 🐝";
    }
  }

  void _showAddTransactionDialog(
    BuildContext context, [
    Transaction? transaction,
  ]) {
    showDialog(
      context: context,
      builder: (context) =>
          AddTransactionDialog(initialTransaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, financeState) {
        if (financeState is FinanceLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        } else if (financeState is FinanceError) {
          return Center(child: Text(financeState.message));
        } else if (financeState is FinanceLoaded) {
          final double expenseRatio = financeState.totalIncome > 0
              ? (financeState.totalExpense / financeState.totalIncome)
              : 0.0;

          // Lấy thông tin user
          final authState = context.read<AuthBloc>().state;
          String displayName = 'Người dùng';
          if (authState is AuthAuthenticated) {
            displayName =
                authState.user.displayName ??
                authState.user.email.split('@').first;
          }

          // Tính toán tiến độ tiết kiệm
          final double savedAmount = financeState.balance > 0
              ? financeState.balance
              : 0;
          final double savingProgress = (savedAmount / _mockSavingTarget).clamp(
            0.0,
            1.0,
          );

          return RefreshIndicator(
            onRefresh: () async {
              context.read<FinanceBloc>().add(FetchTransactionsEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Chào mừng người dùng ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào,',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$displayName 👋',
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Card Số dư Gradient ──
                  _buildBalanceCard(financeState),
                  const SizedBox(height: 20),

                  // ── Lời khuyên Mascot Ong Lucky ──
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(
                                alpha: 0.2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '🐝',
                              style: TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ong Lucky tư vấn:',
                                  style: GoogleFonts.quicksand(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getMascotAdvice(
                                    financeState.balance,
                                    expenseRatio,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.4,
                                    color: AppColors.onSurfaceVariant,
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

                  // ── Phím tắt hành động nhanh ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionItem(
                        icon: Icons.psychology_outlined,
                        label: 'Kế hoạch AI',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavingsPlannerPage(
                                expenses: financeState.transactions
                                    .where((t) => t.isExpense)
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickActionItem(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Ghi chép nhanh',
                        color: AppColors.primary,
                        onTap: () => _showAddTransactionDialog(context),
                      ),
                      _buildQuickActionItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Quản lý Ví',
                        color: Colors.blue,
                        onTap: () =>
                            widget.onTabChange(1), // Chuyển sang Tab Wallet
                      ),
                      _buildQuickActionItem(
                        icon: Icons.analytics_outlined,
                        label: 'Xếp hạng chi',
                        color: Colors.orange,
                        onTap: () =>
                            widget.onTabChange(2), // Chuyển sang Tab Ranking
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Tiến trình Hũ tiết kiệm ──
                  Card(
                    color: AppColors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.savings,
                                    color: AppColors.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hũ mật tiết kiệm',
                                    style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${(savingProgress * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: savingProgress,
                                  minHeight: 12,
                                  backgroundColor: Colors.grey[200],
                                  color: AppColors.secondaryContainer,
                                ),
                              ),
                              // Con ong nhỏ bay theo tiến trình
                              if (savingProgress > 0.05)
                                Positioned(
                                  left:
                                      (MediaQuery.of(context).size.width - 70) *
                                          savingProgress -
                                      15,
                                  top: -4,
                                  child: const Text(
                                    '🐝',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đã có: ${_currencyFormat.format(savedAmount)}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Mục tiêu: ${_currencyFormat.format(_mockSavingTarget)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Giao dịch gần đây ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Giao Dịch Gần Đây',
                        style: GoogleFonts.quicksand(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                      TextButton(
                        onPressed: () => widget.onTabChange(
                          2,
                        ), // Chuyển sang Tab Ranking để xem chi tiết
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (financeState.transactions.isEmpty)
                    _buildEmptyTransactions()
                  else
                    _buildRecentTransactionsList(financeState.transactions),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
        return const Center(child: Text('Lỗi không xác định'));
      },
    );
  }

  Widget _buildBalanceCard(FinanceLoaded state) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tài sản hiện tại',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'An toàn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _currencyFormat.format(state.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceStat(
                'Thu nhập',
                state.totalIncome,
                Icons.arrow_downward,
                Colors.greenAccent,
              ),
              Container(height: 30, width: 1, color: Colors.white24),
              _buildBalanceStat(
                'Chi tiêu',
                state.totalExpense,
                Icons.arrow_upward,
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceStat(
    String label,
    double amount,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.15)),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 10),
            Text(
              'Chưa có giao dịch nào được ghi lại hôm nay.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsList(dynamic transactions) {
    final recent = transactions.take(3).toList();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recent.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = recent[index];
        final isExpense = transaction.isExpense;
        final color = _getCategoryColor(transaction.category);

        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            onTap: () => _showAddTransactionDialog(context, transaction),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: color,
                size: 20,
              ),
            ),
            title: Text(
              transaction.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              DateFormat('dd/MM/yyyy').format(transaction.date),
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
            trailing: Text(
              '${isExpense ? '-' : '+'}${_currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                color: isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Lương':
        return Icons.monetization_on;
      case 'Thu nhập thêm':
        return Icons.add_home_work;
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Nhà cửa':
        return Icons.home;
      case 'Hóa đơn':
        return Icons.receipt_long;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Mua sắm':
        return Icons.shopping_bag;
      case 'Giáo dục':
        return Icons.school;
      case 'Giải trí':
        return Icons.movie;
      default:
        return Icons.local_offer;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Lương':
        return Colors.green;
      case 'Thu nhập thêm':
        return Colors.teal;
      case 'Ăn uống':
        return Colors.orange;
      case 'Nhà cửa':
        return Colors.indigo;
      case 'Hóa đơn':
        return Colors.red;
      case 'Di chuyển':
        return Colors.blue;
      case 'Mua sắm':
        return Colors.purple;
      case 'Giáo dục':
        return Colors.amber;
      case 'Giải trí':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
