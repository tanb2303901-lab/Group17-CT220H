import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../features/finance/domain/repositories/transaction_repository.dart';
import '../../features/finance/data/repositories/local_transaction_repository.dart';
import '../../features/finance/data/repositories/firebase_transaction_repository.dart';
import '../../features/finance/domain/usecases/get_transactions.dart';
import '../../features/finance/domain/usecases/add_transaction.dart';
import '../../features/finance/domain/usecases/update_transaction.dart';
import '../../features/finance/domain/usecases/delete_transaction.dart';
import '../../features/finance/presentation/bloc/finance_bloc.dart';
import '../../features/savings/domain/usecases/calculate_savings_plan.dart';
import '../../features/savings/presentation/bloc/savings_bloc.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/firebase_auth_repository.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  bool useFirebase = false;
  try {
    // Attempt Firebase initialization (graceful fallback if firebase credentials are not configured)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    useFirebase = true;
    print("BeeSaving DI: Tích hợp Firebase thành công.");
  } catch (e) {
    print(
        "BeeSaving DI: Không thể khởi tạo Firebase (Có thể chưa cấu hình google-services.json). Sử dụng cơ sở dữ liệu giả lập (Local Mock DB). Chi tiết: $e");
  }

  // ── Auth Repository ──
  if (useFirebase) {
    sl.registerLazySingleton<AuthRepository>(() => FirebaseAuthRepository());
    sl.registerLazySingleton<TransactionRepository>(
        () => FirebaseTransactionRepository());
  } else {
    sl.registerLazySingleton<AuthRepository>(
        () => MockAuthRepository());
    sl.registerLazySingleton<TransactionRepository>(
        () => LocalTransactionRepository());
  }

  // ── Finance Use Cases ──
  sl.registerLazySingleton(() => GetTransactions(sl()));
  sl.registerLazySingleton(() => AddTransaction(sl()));
  sl.registerLazySingleton(() => UpdateTransaction(sl()));
  sl.registerLazySingleton(() => DeleteTransaction(sl()));

  // ── Savings Use Case ──
  sl.registerLazySingleton(() => CalculateSavingsPlan());

  // ── BLoCs ──
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => FinanceBloc(
        getTransactions: sl(),
        addTransaction: sl(),
        updateTransaction: sl(),
        deleteTransaction: sl(),
      ));
  sl.registerFactory(() => SavingsBloc(
        calculateSavingsPlan: sl(),
      ));
}
