import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';
import '../widgets/add_transaction_dialog.dart';
import '../../domain/entities/transaction.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  void _showAddTransactionDialog(BuildContext context, [Transaction? transaction]) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(initialTransaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.white,
            child: TabBar(
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Chi Tiêu'),
                Tab(text: 'Độ Quan Trọng'),
                Tab(text: 'Nguồn Thu'),
              ],
            ),
          ),
        ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is FinanceError) {
              return Center(child: Text(state.message));
            } else if (state is FinanceLoaded) {
              final expenses = state.transactions.where((t) => t.isExpense).toList();
              final incomes = state.transactions.where((t) => t.isIncome).toList();

              return TabBarView(
                children: [
                  _buildExpensesRanking(context, expenses, state.totalExpense),
                  _buildImportanceRanking(context, expenses),
                  _buildIncomesRanking(context, incomes, state.totalIncome),
                ],
              );
            }
            return const Center(child: Text('Lỗi không xác định'));
          },
        ),
      ),
    );
  }

  // ── 1. Tab Xếp hạng chi tiêu theo danh mục ──
  Widget _buildExpensesRanking(BuildContext context, List<dynamic> expenses, double totalExpense) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    if (expenses.isEmpty) {
      return _buildEmptyState('Không có dữ liệu chi tiêu để thống kê.');
    }

    // Nhóm chi tiêu theo danh mục
    final Map<String, double> categorySums = {};
    for (var e in expenses) {
      categorySums[e.category] = (categorySums[e.category] ?? 0.0) + e.amount;
    }

    // Sắp xếp giảm dần theo số tiền
    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCategories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              color: AppColors.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng chi tiêu tháng này:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      currencyFormat.format(totalExpense),
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final entry = sortedCategories[index - 1];
        final category = entry.key;
        final amount = entry.value;
        final percentage = totalExpense > 0 ? amount / totalExpense : 0.0;
        final color = _getCategoryColor(category);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getCategoryIcon(category), color: color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── 2. Tab Xếp hạng theo độ quan trọng ──
  Widget _buildImportanceRanking(BuildContext context, List<dynamic> expenses) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    if (expenses.isEmpty) {
      return _buildEmptyState('Không có dữ liệu chi tiêu để phân tích.');
    }

    // Phân loại các giao dịch theo tầm quan trọng
    final unessentialExpenses = expenses.where((e) => e.importanceScore <= 2).toList();
    final essentialExpenses = expenses.where((e) => e.importanceScore >= 3).toList();

    // Sắp xếp các khoản không thiết yếu từ lớn nhất đến nhỏ nhất
    unessentialExpenses.sort((a, b) => b.amount.compareTo(a.amount));
    // Tính tổng số tiền không thiết yếu
    final double totalUnessentialSum = unessentialExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final double totalExpensesSum = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final double unessentialRatio = totalExpensesSum > 0 ? totalUnessentialSum / totalExpensesSum : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card Tóm tắt
        Card(
          color: totalUnessentialSum > 2000000 ? AppColors.errorContainer.withOpacity(0.4) : AppColors.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chi tiêu không thiết yếu (1-2★):',
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onBackground),
                    ),
                    Text(
                      currencyFormat.format(totalUnessentialSum),
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Chiếm ${(unessentialRatio * 100).toStringAsFixed(1)}% trên tổng số chi tiêu của bạn.',
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Lời khuyên Ong tư vấn
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    totalUnessentialSum > 0
                        ? "Ong Lucky nhận thấy bạn chi ${currencyFormat.format(totalUnessentialSum)} vào các khoản không thiết yếu như trà sữa, xem phim, mua sắm. Cắt giảm 50% các khoản này sẽ giúp bạn bỏ túi thêm ${currencyFormat.format(totalUnessentialSum / 2)} đấy!"
                        : "Tuyệt vời! Bạn không có khoản chi tiêu lãng phí nào tháng này. Hãy tiếp tục giữ vững phong độ nhé! 🐝",
                    style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Chi tiết danh sách không thiết yếu (Sắp xếp theo số tiền chi từ cao xuống thấp)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách cần cắt giảm trước',
              style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onBackground),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
              child: Text(
                '${unessentialExpenses.length} khoản chi',
                style: TextStyle(color: Colors.red[800], fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (unessentialExpenses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Không có khoản chi độ quan trọng thấp nào.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...unessentialExpenses.map((e) => _buildTransactionRankingCard(context, e, currencyFormat)),

        const SizedBox(height: 16),
        // Danh sách các khoản thiết yếu
        Text(
          'Các khoản chi thiết yếu (3-5★)',
          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.onBackground),
        ),
        const SizedBox(height: 8),

        if (essentialExpenses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Không có khoản chi thiết yếu.', style: TextStyle(color: Colors.grey))),
          )
        else
          ...essentialExpenses.map((e) => _buildTransactionRankingCard(context, e, currencyFormat)),
          
        const SizedBox(height: 80),
      ],
    );
  }

  // ── 3. Tab Xếp hạng nguồn thu ──
  Widget _buildIncomesRanking(BuildContext context, List<dynamic> incomes, double totalIncome) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    if (incomes.isEmpty) {
      return _buildEmptyState('Không có dữ liệu thu nhập để thống kê.');
    }

    // Nhóm thu nhập theo danh mục
    final Map<String, double> categorySums = {};
    for (var e in incomes) {
      categorySums[e.category] = (categorySums[e.category] ?? 0.0) + e.amount;
    }

    // Sắp xếp giảm dần theo số tiền
    final sortedCategories = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedCategories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              color: AppColors.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thu nhập tháng này:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(
                      currencyFormat.format(totalIncome),
                      style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final entry = sortedCategories[index - 1];
        final category = entry.key;
        final amount = entry.value;
        final percentage = totalIncome > 0 ? amount / totalIncome : 0.0;
        final color = _getCategoryColor(category);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(_getCategoryIcon(category), color: color, size: 18),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: GoogleFonts.quicksand(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormat.format(amount),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          '${(percentage * 100).toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTransactionRankingCard(BuildContext context, dynamic transaction, NumberFormat format) {
    final isExpense = transaction.isExpense;
    final color = _getCategoryColor(transaction.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _showAddTransactionDialog(context, transaction),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(_getCategoryIcon(transaction.category), color: color, size: 18),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: transaction.importanceScore <= 2 ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Độ quan trọng: ${transaction.importanceScore}/5',
                style: TextStyle(
                  color: transaction.importanceScore <= 2 ? Colors.green[800] : Colors.orange[800],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          '${isExpense ? '-' : '+'}${format.format(transaction.amount)}',
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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

}
