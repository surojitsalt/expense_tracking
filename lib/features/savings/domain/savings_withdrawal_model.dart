import 'package:equatable/equatable.dart';

class SavingsWithdrawalModel extends Equatable {
  final int? id;
  final double amount;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  const SavingsWithdrawalModel({
    this.id,
    required this.amount,
    this.description,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SavingsWithdrawalModel.fromMap(Map<String, dynamic> map) {
    return SavingsWithdrawalModel(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, amount, description, date, createdAt];
}
