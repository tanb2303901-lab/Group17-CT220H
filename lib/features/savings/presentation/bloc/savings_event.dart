import 'package:equatable/equatable.dart';
import '../../../finance/domain/entities/transaction.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object?> get props => [];
}

class CalculatePlanEvent extends SavingsEvent {
  final List<Transaction> expenses;
  final double targetSavings;

  const CalculatePlanEvent({
    required this.expenses,
    required this.targetSavings,
  });

  @override
  List<Object?> get props => [expenses, targetSavings];
}

class ResetPlannerEvent extends SavingsEvent {}
