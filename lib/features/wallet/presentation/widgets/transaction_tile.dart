import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_service_wallet/features/wallet/data/models/transaction_model.dart';
import 'package:smart_service_wallet/features/wallet/presentation/pages/transaction_detail_page.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isDebit = transaction.type == TransactionType.debit;
    final color = isDebit ? Colors.red : const Color(0xFF10B981);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionDetailPage(transaction: transaction),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDebit ? Icons.arrow_outward : Icons.arrow_downward,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(transaction.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${isDebit ? '-' : '+'}${transaction.currency} ${transaction.amount}',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
