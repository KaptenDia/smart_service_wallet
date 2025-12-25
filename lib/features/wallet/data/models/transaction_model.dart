import 'package:equatable/equatable.dart';

enum TransactionType { debit, credit }

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String currency; // RM or GP
  final DateTime date;
  final TransactionType type;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.currency,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'currency': currency,
    'date': date.toIso8601String(),
    'type': type.name,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'],
        date: DateTime.parse(json['date']),
        type: TransactionType.values.byName(json['type']),
      );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    amount,
    currency,
    date,
    type,
  ];
}
