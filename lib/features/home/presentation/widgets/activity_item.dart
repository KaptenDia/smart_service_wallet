import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_service_wallet/features/wallet/data/models/transaction_model.dart';
import 'package:smart_service_wallet/features/wallet/presentation/pages/transaction_detail_page.dart';

class ActivityItem extends StatelessWidget {
  final dynamic transaction;
  const ActivityItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: transaction.type == TransactionType.debit
                    ? Colors.red.withAlpha(20)
                    : const Color(0xFF10B981).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.type == TransactionType.debit
                    ? Icons.arrow_outward
                    : Icons.arrow_downward,
                color: transaction.type == TransactionType.debit
                    ? Colors.red
                    : const Color(0xFF10B981),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM, hh:mm a').format(transaction.date),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Text(
              '${transaction.type == TransactionType.debit ? '-' : '+'}${transaction.currency} ${transaction.amount}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: transaction.type == TransactionType.debit
                    ? Colors.red
                    : const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
