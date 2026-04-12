import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordCard extends StatelessWidget {
  final double amount;
  final String category;
  final String? description;
  final DateTime date;
  final Color cardColor;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const RecordCard({
    super.key,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.cardColor,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('${date.millisecondsSinceEpoch}_${amount}_$category'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        onDelete();
      },
      child: Card(
        color: cardColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Colors.white.withAlpha(150),
            child: Text(
              category.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description != null && description!.isNotEmpty)
                Text(description!),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          trailing: Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
