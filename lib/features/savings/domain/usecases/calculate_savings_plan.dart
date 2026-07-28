import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/knapsack_solver.dart';
import '../../../finance/domain/entities/transaction.dart';
import '../entities/savings_plan.dart';

class CalculateSavingsPlanParams {
  final List<Transaction> expenses;
  final double targetSavings;

  CalculateSavingsPlanParams({
    required this.expenses,
    required this.targetSavings,
  });
}

class CalculateSavingsPlan
    implements UseCase<SavingsPlan, CalculateSavingsPlanParams> {
  @override
  Future<SavingsPlan> call(CalculateSavingsPlanParams params) async {
    final knapsackItems = params.expenses.map((expense) {
      return KnapsackItem(
        id: expense.id,
        title: expense.title,
        amount: expense.amount,
        importanceScore: expense.importanceScore,
        originalObject: expense,
      );
    }).toList();

    final result = KnapsackSolver.solve(
      items: knapsackItems,
      targetSavings: params.targetSavings,
    );

    final List<Transaction> itemsToCut = result.itemsToCut.map((kItem) {
      return kItem.originalObject as Transaction;
    }).toList();

    return SavingsPlan(
      itemsToCut: itemsToCut,
      totalSavings: result.totalSavings,
      impactLevel: result.impactLevel,
    );
  }
}
