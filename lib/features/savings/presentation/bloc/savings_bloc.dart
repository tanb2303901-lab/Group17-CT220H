import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/calculate_savings_plan.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final CalculateSavingsPlan calculateSavingsPlan;

  SavingsBloc({required this.calculateSavingsPlan}) : super(SavingsInitial()) {
    on<CalculatePlanEvent>(_onCalculatePlan);
    on<ResetPlannerEvent>(_onResetPlanner);
  }

  Future<void> _onCalculatePlan(
    CalculatePlanEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      final plan = await calculateSavingsPlan(
        CalculateSavingsPlanParams(
          expenses: event.expenses,
          targetSavings: event.targetSavings,
        ),
      );
      emit(SavingsCalculated(plan: plan, targetSavings: event.targetSavings));
    } catch (e) {
      emit(SavingsError('Lỗi tính toán kế hoạch tiết kiệm: ${e.toString()}'));
    }
  }

  void _onResetPlanner(ResetPlannerEvent event, Emitter<SavingsState> emit) {
    emit(SavingsInitial());
  }
}
