import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../../../features/savings/presentation/pages/savings_planner_page.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FinanceBloc>(context).add(FetchTransactionsEvent());
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

  void _showMonthPicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      helpText: 'Chọn tháng để lọc',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onBackground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
      if (mounted) {
        context.read<FinanceBloc>().add(FilterByMonthEvent(_selectedMonth));
      }
    }
  }

  void _clearMonthFilter() {
    setState(() => _selectedMonth = null);
    context.read<FinanceBloc>().add(const FilterByMonthEvent(null));
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Đăng xuất'),
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
              style: TextStyle(color: AppColors.error),
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

  String _getMascotAdvice(double balance, double expenseRatio) {
    if (balance < 0) {
      return "Ôi không! Số dư của bạn đang âm rồi. Hãy dùng ngay tính năng 'Lập kế hoạch tiết kiệm' ở nút bên dưới để cắt giảm chi phí không cần thiết nhé! 🍀";
    } else if (expenseRatio > 0.8) {
      return "Tỷ lệ chi tiêu của bạn khá cao (>80% thu nhập). Tớ khuyên bạn nên xem xét lại các khoản ăn uống hoặc mua sắm giải trí để tích lũy thêm vàng nha! 💰";
    } else if (balance > 10000000) {
      return "Tuyệt vời! Bạn đang quản lý tài chính rất tốt, hũ vàng đang đầy dần lên. Hãy đặt mục tiêu tiết kiệm lớn hơn để mua những thứ giá trị nhé! 🏆";
    } else {
      return "Chào bạn! Hôm nay bạn đã ghi chép chi tiêu chưa? Hãy tích lũy từng đồng xu nhỏ để tạo nên hũ vàng lớn cùng tớ nhé! 🐝";
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'BeeSaving',
                style: GoogleFonts.quicksand(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          actions: [
            // ── Month filter chip ──
            if (_selectedMonth != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: InputChip(
                  label: Text(
                    DateFormat('MM/yyyy').format(_selectedMonth!),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  avatar: const Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  onPressed: _clearMonthFilter,
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onDeleted: _clearMonthFilter,
                  backgroundColor: AppColors.primaryContainer.withOpacity(0.2),
                ),
              ),
            // ── Filter button ──
            IconButton(
              icon: Icon(
                Icons.filter_list_rounded,
                color: _selectedMonth != null
                    ? AppColors.primary
                    : Colors.grey[600],
              ),
              tooltip: 'Lọc theo tháng',
              onPressed: _showMonthPicker,
            ),
            // ── Refresh ──
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              tooltip: 'Làm mới',
              onPressed: () {
                context.read<FinanceBloc>().add(FetchTransactionsEvent());
              },
            ),
            // ── Sign out ──
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  color: Colors.grey[600],
                  tooltip: 'Đăng xuất',
                  onPressed: () => _showSignOutDialog(context),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is FinanceError) {
              return Center(child: Text(state.message));
            } else if (state is FinanceLoaded) {
              final double expenseRatio = state.totalIncome > 0
                  ? (state.totalExpense / state.totalIncome)
                  : 0.0;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<FinanceBloc>().add(FetchTransactionsEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Tiêu đề tháng đang xem ──
                      if (state.selectedMonth != null)
                        _buildMonthHeader(state.selectedMonth!),

                      // ── Mascot Speech Bubble ──
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer
                                      .withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '🍀',
                                  style: TextStyle(fontSize: 32),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Yêu Tinh Lucky khuyên bạn:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getMascotAdvice(
                                        state.balance,
                                        expenseRatio,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Card Số dư ──
                      _buildBalanceCard(state),
                      const SizedBox(height: 16),

                      // ── Smart Planner CTA ──
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 1,
                        ),
                        icon: const Icon(Icons.psychology, size: 24),
                        label: const Text(
                          'LẬP KẾ HOẠCH TIẾT KIỆM THÔNG MINH (AI)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SavingsPlannerPage(
                                expenses: state.transactions
                                    .where((t) => t.isExpense)
                                    .toList(),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Phân tích chi tiêu (PieChart) ──
                      if (state.categoryExpenses.isNotEmpty) ...[
                        Text(
                          'Phân Tích Chi Tiêu',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.onBackground),
                        ),
                        const SizedBox(height: 12),
                        _buildPieChartCard(state),
                        const SizedBox(height: 20),
                      ],

                      // ── Danh sách giao dịch ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Giao Dịch Gần Đây',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppColors.onBackground),
                          ),
                          Text(
                            '${state.transactions.length} giao dịch',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (state.transactions.isEmpty)
                        _buildEmptyTransactions()
                      else
                        _buildTransactionList(state),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('Lỗi không xác định'));
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
          onPressed: () => _showAddTransactionDialog(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildMonthHeader(DateTime month) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Xem tháng ${DateFormat('MM/yyyy').format(month)}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearMonthFilter,
            child: const Text(
              'Xem tất cả',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(FinanceLoaded state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số dư hiện tại',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currencyFormat.format(state.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
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
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _currencyFormat.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChartCard(FinanceLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  sections: state.categoryExpenses.entries.map((entry) {
                    final percentage = state.totalExpense > 0
                        ? (entry.value / state.totalExpense) * 100
                        : 0.0;
                    return PieChartSectionData(
                      color: _getCategoryColor(entry.key),
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 45,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: state.categoryExpenses.keys.map((cat) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(cat),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cat,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              _selectedMonth != null
                  ? 'Không có giao dịch nào trong tháng này.'
                  : 'Chưa có giao dịch nào được ghi lại.\nHãy nhấn nút dấu (+) phía dưới để bắt đầu nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(FinanceLoaded state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = state.transactions[index];
        final isExpense = transaction.isExpense;
        final color = _getCategoryColor(transaction.category);

        return Dismissible(
          key: Key(transaction.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận xóa'),
                content: const Text(
                  'Bạn có chắc chắn muốn xóa giao dịch này không?',
                ),
                actions: [
                  TextButton(
                    child: const Text('Hủy'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  TextButton(
                    child: const Text(
                      'Xóa',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            context.read<FinanceBloc>().add(
              DeleteTransactionEvent(transaction.id),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Đã xóa giao dịch thành công'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: () => _showAddTransactionDialog(context, transaction),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getCategoryIcon(transaction.category),
                  color: color,
                ),
              ),
              title: Text(
                transaction.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Row(
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy').format(transaction.date),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  if (isExpense) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'QT: ${transaction.importanceScore}/5',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Text(
                '${isExpense ? '-' : '+'}${_currencyFormat.format(transaction.amount)}',
                style: TextStyle(
                  color: isExpense ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
