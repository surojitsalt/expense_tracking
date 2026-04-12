import 'package:equatable/equatable.dart';

class ExpenseModel extends Equatable {
  final int? id;
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  const ExpenseModel({
    this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
  });

  ExpenseModel copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      category: map['category'] as String,
      description: map['description'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  List<Object?> get props => [id, amount, category, description, date, createdAt];
}
