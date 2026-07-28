import 'package:uuid/uuid.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class LocalTransactionRepository implements TransactionRepository {
  final List<Transaction> _transactions = [];
  final _uuid = const Uuid();

  LocalTransactionRepository() {
    _seedData();
  }

  void _seedData() {
    final now = DateTime.now();
    // Tiền thu nhập (Incomes)
    _transactions.addAll([
      Transaction(
        id: _uuid.v4(),
        title: 'Lương tháng nhận từ công ty',
        amount: 18000000.0,
        type: 'income',
        category: 'Lương',
        date: DateTime(now.year, now.month, 5),
        importanceScore: 5,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Làm thêm freelance thiết kế UI',
        amount: 3500000.0,
        type: 'income',
        category: 'Thu nhập thêm',
        date: DateTime(now.year, now.month, 12),
        importanceScore: 4,
      ),
    ]);

    // Tiền chi tiêu (Expenses)
    _transactions.addAll([
      Transaction(
        id: _uuid.v4(),
        title: 'Tiền thuê nhà & dịch vụ',
        amount: 5000000.0,
        type: 'expense',
        category: 'Nhà cửa',
        date: DateTime(now.year, now.month, 1),
        importanceScore: 5,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Đi siêu thị mua thức ăn cả tuần',
        amount: 2800000.0,
        type: 'expense',
        category: 'Ăn uống',
        date: DateTime(now.year, now.month, 3),
        importanceScore: 4,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Đóng tiền điện & nước',
        amount: 950000.0,
        type: 'expense',
        category: 'Hóa đơn',
        date: DateTime(now.year, now.month, 6),
        importanceScore: 5,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Học phí khóa học tiếng Anh',
        amount: 1500000.0,
        type: 'expense',
        category: 'Giáo dục',
        date: DateTime(now.year, now.month, 8),
        importanceScore: 5,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Đi uống trà sữa với đồng nghiệp',
        amount: 450000.0,
        type: 'expense',
        category: 'Ăn uống',
        date: DateTime(now.year, now.month, 9),
        importanceScore: 1,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Gia hạn gói Netflix Premium',
        amount: 260000.0,
        type: 'expense',
        category: 'Giải trí',
        date: DateTime(now.year, now.month, 10),
        importanceScore: 2,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Mua giày thể thao mới',
        amount: 1600000.0,
        type: 'expense',
        category: 'Mua sắm',
        date: DateTime(now.year, now.month, 11),
        importanceScore: 2,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Đổ xăng và bảo dưỡng xe máy',
        amount: 500000.0,
        type: 'expense',
        category: 'Di chuyển',
        date: DateTime(now.year, now.month, 14),
        importanceScore: 4,
      ),
      Transaction(
        id: _uuid.v4(),
        title: 'Vé xem phim & bỏng ngô ở rạp',
        amount: 320000.0,
        type: 'expense',
        category: 'Giải trí',
        date: DateTime(now.year, now.month, 15),
        importanceScore: 1,
      ),
    ]);
  }

  @override
  Future<List<Transaction>> getTransactions() async {
    // Trả về bản sao để tránh chỉnh sửa trực tiếp danh sách trong bộ nhớ
    return List.from(_transactions);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final transToAdd = Transaction(
      id: transaction.id.isEmpty ? _uuid.v4() : transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      date: transaction.date,
      importanceScore: transaction.importanceScore,
    );
    _transactions.add(transToAdd);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((element) => element.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((element) => element.id == id);
  }
}
