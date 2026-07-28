import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../widgets/add_transaction_dialog.dart';
import 'home_page.dart';
import 'wallet_page.dart';
import 'ranking_page.dart';
import '../../../../features/auth/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  DateTime? _selectedMonth;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách các trang
    _pages = [
      HomePage(onTabChange: _onTabChange),
      const WalletPage(),
      const RankingPage(),
      const ProfilePage(),
    ];
    // Tải dữ liệu ban đầu
    context.read<FinanceBloc>().add(FetchTransactionsEvent());
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
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

  @override
  Widget build(BuildContext context) {
    // Chỉ hiển thị bộ lọc tháng ở tab Home (0) và Ranking (2)
    final bool showFilterActions = _currentIndex == 0 || _currentIndex == 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.savings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'BeeSaving',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          if (showFilterActions) ...[
            // Nút xóa bộ lọc tháng
            if (_selectedMonth != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: InputChip(
                  label: Text(
                    DateFormat('MM/yyyy').format(_selectedMonth!),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  avatar: const Icon(
                    Icons.calendar_month,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onPressed: _clearMonthFilter,
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  onDeleted: _clearMonthFilter,
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.15),
                ),
              ),
            // Nút mở chọn tháng
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
            // Nút làm mới
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: AppColors.primary,
                size: 22,
              ),
              tooltip: 'Làm mới',
              onPressed: () {
                context.read<FinanceBloc>().add(FetchTransactionsEvent());
              },
            ),
          ],
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.quicksand(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Ví',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Xếp hạng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
      // Ẩn nút FAB ở tab Profile (3)
      floatingActionButton: _currentIndex != 3
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => _showAddTransactionDialog(context),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }
}
