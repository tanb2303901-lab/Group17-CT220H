import 'package:equatable/equatable.dart';
import '../../domain/entities/savings_plan.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsCalculated extends SavingsState {
  final SavingsPlan plan;
  final double targetSavings;

  const SavingsCalculated({required this.plan, required this.targetSavings});

  @override
  List<Object?> get props => [plan, targetSavings];
}

class SavingsError extends SavingsState {
  final String message;

  const SavingsError(this.message);

  @override
  List<Object?> get props => [message];
}
