import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/finance/domain/entities/transaction.dart';
import '../bloc/savings_bloc.dart';
import '../bloc/savings_event.dart';
import '../bloc/savings_state.dart';

class SavingsPlannerPage extends StatefulWidget {
  final List<Transaction> expenses;

  const SavingsPlannerPage({super.key, required this.expenses});

  @override
  State<SavingsPlannerPage> createState() => _SavingsPlannerPageState();
}

class _SavingsPlannerPageState extends State<SavingsPlannerPage> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _calculatePlan() {
    if (_formKey.currentState?.validate() ?? false) {
      final double target = double.parse(_targetController.text);
      BlocProvider.of<SavingsBloc>(context).add(
        CalculatePlanEvent(expenses: widget.expenses, targetSavings: target),
      );
    }
  }

  Color _getImpactColor(String level) {
    switch (level) {
      case 'Thấp':
        return Colors.green;
      case 'Trung bình':
        return Colors.orange;
      case 'Cao':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getMascotAdviceForImpact(
    String level,
    double target,
    double savings,
  ) {
    if (savings < target) {
      return "Tớ đã tính toán hết sức rồi! Kế hoạch này giúp bạn cắt giảm tối đa ${_currencyFormat.format(savings)}, chưa đạt mục tiêu ${_currencyFormat.format(target)} của bạn đâu. Hãy cân nhắc gia tăng nguồn thu nhập thêm nhé! 🐝";
    }

    switch (level) {
      case 'Thấp':
        return "Tuyệt vời! Kế hoạch cắt giảm này chỉ ảnh hưởng rất nhỏ đến cuộc sống của bạn (hầu hết là trà sữa, xem phim...). Hãy thực hiện ngay để bỏ túi ${_currencyFormat.format(savings)} nhé! 🍀";
      case 'Trung bình':
        return "Cố lên bạn ơi! Kế hoạch này cắt giảm một số khoản mua sắm và giải trí trung bình. Bạn sẽ thấy hơi gò bó một chút nhưng sẽ tiết kiệm được hũ vàng kha khá đấy! 💰";
      case 'Cao':
        return "⚠️ Cảnh báo! Để đạt mục tiêu, tớ phải đề xuất cắt giảm cả những khoản rất quan trọng của bạn. Việc này sẽ ảnh hưởng khá nhiều đến đời sống sinh hoạt. Bạn có muốn hạ thấp mục tiêu tiết kiệm xuống một chút không?";
      default:
        return "Hãy nhập số tiền bạn muốn tiết kiệm để tớ lập kế hoạch tối ưu nhất nhé!";
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalExpensesSum = widget.expenses.fold(
      0.0,
      (sum, e) => sum + e.amount,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Kế Hoạch Tiết Kiệm',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            BlocProvider.of<SavingsBloc>(context).add(ResetPlannerEvent());
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông tin tổng quan chi tiêu tháng
            Card(
              color: AppColors.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Tổng chi tiêu tháng hiện tại có thể tối ưu:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currencyFormat.format(totalExpensesSum),
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Từ ${widget.expenses.length} khoản chi khác nhau',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Form nhập mục tiêu tiết kiệm
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Bạn muốn tiết kiệm bao nhiêu?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số tiền tiết kiệm mong muốn (VND)',
                          prefixIcon: Icon(Icons.stars, color: Colors.orange),
                          hintText: 'Ví dụ: 1000000',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mục tiêu tiết kiệm';
                          }
                          final target = double.tryParse(value);
                          if (target == null || target <= 0) {
                            return 'Mục tiêu phải lớn hơn 0';
                          }
                          if (target > totalExpensesSum) {
                            return 'Mục tiêu không thể lớn hơn tổng chi tiêu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _calculatePlan,
                        child: const Text('Lập Kế Hoạch Tối Ưu (DP)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kết quả từ BLoC
            BlocBuilder<SavingsBloc, SavingsState>(
              builder: (context, state) {
                if (state is SavingsLoading) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                } else if (state is SavingsError) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                } else if (state is SavingsCalculated) {
                  final plan = state.plan;
                  final impactColor = _getImpactColor(plan.impactLevel);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Mascot Speech Bubble based on impact level
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: impactColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '🍀',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Yêu Tinh Lucky khuyên bạn:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getMascotAdviceForImpact(
                                        plan.impactLevel,
                                        state.targetSavings,
                                        plan.totalSavings,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tóm tắt kết quả
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tóm Tắt Kế Hoạch',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontSize: 18,
                                      color: AppColors.primary,
                                    ),
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Mục tiêu đặt ra:'),
                                  Text(
                                    _currencyFormat.format(state.targetSavings),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Tiết kiệm tối ưu đề xuất:'),
                                  Text(
                                    _currencyFormat.format(plan.totalSavings),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          plan.totalSavings >=
                                              state.targetSavings
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Mức độ ảnh hưởng cuộc sống:'),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: impactColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      plan.impactLevel,
                                      style: TextStyle(
                                        color: impactColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Danh sách các khoản nên cắt giảm
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Khoản Chi Nên Cắt Giảm',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppColors.onBackground),
                          ),
                          Text(
                            '${plan.itemsToCut.length} khoản chi',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (plan.itemsToCut.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Không cần cắt giảm khoản nào cả! Bạn đã đạt mục tiêu rồi hoặc không có khoản chi nào để tối ưu.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: plan.itemsToCut.length,
                          itemBuilder: (context, index) {
                            final item = plan.itemsToCut[index];
                            final easyToCut = item.importanceScore <= 2;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: easyToCut
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    easyToCut
                                        ? Icons.check_circle_outline
                                        : Icons.warning_amber_outlined,
                                    color: easyToCut
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      'Độ quan trọng: ${item.importanceScore}/5',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: easyToCut
                                            ? Colors.green[50]
                                            : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        easyToCut
                                            ? 'Dễ cắt giảm'
                                            : 'Nên cân nhắc',
                                        style: TextStyle(
                                          color: easyToCut
                                              ? Colors.green
                                              : Colors.orange[800],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  '-${_currencyFormat.format(item.amount)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                }
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Hãy nhập số tiền mục tiêu và nhấn nút để tớ phân tích chi tiêu tối ưu cho bạn nhé!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, height: 1.4),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
