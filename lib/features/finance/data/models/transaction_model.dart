import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    super.importanceScore,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json, String id) {
    return TransactionModel(
      id: id,
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      type: json['type'] as String? ?? 'expense',
      category: json['category'] as String? ?? 'Khác',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      importanceScore: json['importanceScore'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'importanceScore': importanceScore,
    };
  }

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      date: transaction.date,
      importanceScore: transaction.importanceScore,
    );
  }
}
