import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('transactions');

  @override
  Future<List<Transaction>> getTransactions() async {
    final querySnapshot = await _collection.orderBy('date', descending: true).get();
    return querySnapshot.docs.map((doc) {
      return TransactionModel.fromJson(doc.data(), doc.id);
    }).toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    if (transaction.id.isEmpty) {
      await _collection.add(model.toJson());
    } else {
      await _collection.doc(transaction.id).set(model.toJson());
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _collection.doc(transaction.id).update(model.toJson());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }
}
