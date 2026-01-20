import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class CpoResultCard extends StatelessWidget {
  final double amount;

  const CpoResultCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primaryDark,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Required CPO Amount',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.formatETB(amount),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
             const SizedBox(height: 8),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
               decoration: BoxDecoration(
                 color: Colors.white.withValues(alpha: 0.2),
                 borderRadius: BorderRadius.circular(20),
               ),
               child: const Text(
                 'Secure your bid bond early',
                 style: TextStyle(color: Colors.white, fontSize: 12),
               ),
             )
          ],
        ),
      ),
    );
  }
}
