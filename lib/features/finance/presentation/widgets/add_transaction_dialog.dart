import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';

class AddTransactionDialog extends StatefulWidget {
  final Transaction? initialTransaction;
  const AddTransactionDialog({super.key, this.initialTransaction});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _transactionType = 'expense'; // 'income' hoặc 'expense'
  String _category = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();
  int _importanceScore = 3;

  final List<String> _expenseCategories = [
    'Ăn uống',
    'Nhà cửa',
    'Hóa đơn',
    'Di chuyển',
    'Mua sắm',
    'Giáo dục',
    'Giải trí',
    'Khác',
  ];

  final List<String> _incomeCategories = [
    'Lương',
    'Thu nhập thêm',
    'Kinh doanh',
    'Đầu tư',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final t = widget.initialTransaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toInt().toString();
      _transactionType = t.type;
      _category = t.category;
      _selectedDate = t.date;
      _importanceScore = t.importanceScore;
    } else {
      _category = _expenseCategories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getImportanceLabel(int score) {
    switch (score) {
      case 1:
        return 'Rất không cần thiết (Trà sữa, ăn vặt...)';
      case 2:
        return 'Ít cần thiết (Xem phim, quần áo...)';
      case 3:
        return 'Bình thường (Đầu sách, đi xe ôm...)';
      case 4:
        return 'Cần thiết (Đổ xăng, ăn bữa chính...)';
      case 5:
        return 'Rất cần thiết (Thuê nhà, học phí, hóa đơn...)';
      default:
        return 'Bình thường';
    }
  }

  Color _getImportanceColor(int score) {
    switch (score) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _transactionType == 'expense'
        ? _expenseCategories
        : _incomeCategories;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.initialTransaction != null
                          ? 'Cập nhật Giao Dịch'
                          : 'Thêm Giao Dịch Mới',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.outline),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle Loại giao dịch
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _transactionType = 'expense';
                            _category = _expenseCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _transactionType == 'expense'
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Chi Tiêu',
                            style: TextStyle(
                              color: _transactionType == 'expense'
                                  ? Colors.white
                                  : AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _transactionType = 'income';
                            _category = _incomeCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _transactionType == 'income'
                                ? AppColors.primary
                                : AppColors.surfaceContainerHigh,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Thu Nhập',
                            style: TextStyle(
                              color: _transactionType == 'income'
                                  ? Colors.white
                                  : AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tiêu đề
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề giao dịch',
                    prefixIcon: Icon(Icons.title),
                    hintText: 'Nhập tên khoản chi/thu...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tiêu đề giao dịch';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Số tiền
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền (VND)',
                    prefixIcon: Icon(Icons.wallet),
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
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Danh mục & Ngày
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _category = val;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Ngày',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Độ quan trọng (Chỉ hiển thị cho Chi Tiêu)
                if (_transactionType == 'expense') ...[
                  Card(
                    color: AppColors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Độ quan trọng (1-5):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              Text(
                                '$_importanceScore / 5',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getImportanceColor(_importanceScore),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getImportanceLabel(_importanceScore),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Slider(
                            value: _importanceScore.toDouble(),
                            min: 1,
                            max: 5,
                            divisions: 4,
                            activeColor: _getImportanceColor(_importanceScore),
                            inactiveColor: Colors.grey[300],
                            onChanged: (val) {
                              setState(() {
                                _importanceScore = val.round();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Nút hành động
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      child: const Text('Lưu giao dịch'),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final transaction = Transaction(
                            id: widget.initialTransaction?.id ?? '',
                            title: _titleController.text.trim(),
                            amount: double.parse(_amountController.text),
                            type: _transactionType,
                            category: _category,
                            date: _selectedDate,
                            importanceScore: _transactionType == 'expense'
                                ? _importanceScore
                                : 5,
                          );
                          if (widget.initialTransaction != null) {
                            BlocProvider.of<FinanceBloc>(
                              context,
                            ).add(UpdateTransactionEvent(transaction));
                          } else {
                            BlocProvider.of<FinanceBloc>(
                              context,
                            ).add(AddTransactionEvent(transaction));
                          }
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
