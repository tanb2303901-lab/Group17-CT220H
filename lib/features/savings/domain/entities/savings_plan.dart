import 'package:equatable/equatable.dart';
import '../../../finance/domain/entities/transaction.dart';

class SavingsPlan extends Equatable {
  final List<Transaction> itemsToCut;
  final double totalSavings;
  final String impactLevel;

  const SavingsPlan({
    required this.itemsToCut,
    required this.totalSavings,
    required this.impactLevel,
  });

  @override
  List<Object?> get props => [itemsToCut, totalSavings, impactLevel];
}
