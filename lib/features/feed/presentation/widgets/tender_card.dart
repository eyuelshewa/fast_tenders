import 'package:flutter/material.dart';
import '../../domain/tender_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class TenderCard extends StatelessWidget {
  final Tender tender;

  const TenderCard({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    final daysLeft = tender.deadline.difference(DateTime.now()).inDays;
    final hoursLeft = tender.deadline.difference(DateTime.now()).inHours;
    
    Color urgencyColor = AppColors.success;
    String urgencyText = '$daysLeft Days Left';

    if (daysLeft < 5) {
      urgencyColor = AppColors.warning;
    }
    if (hoursLeft < 24) {
      urgencyColor = AppColors.error;
      urgencyText = 'Ends in ${hoursLeft}h';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tender.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  tender.location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tender.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              tender.organization,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (tender.cpoAmount != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CPO REQUIRED',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                      Text(
                        CurrencyFormatter.formatETB(tender.cpoAmount!),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  )
                else
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CPO REQUIRED',
                        style: TextStyle(color: Colors.grey[500], fontSize: 10),
                      ),
                      const Text(
                        '1% - 2%',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: urgencyColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: urgencyColor.withValues(alpha:0.5)),
                  ),
                  child: Text(
                    urgencyText,
                    style: TextStyle(
                      color: urgencyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {}, 
                  icon: const Icon(Icons.share, size: 18), 
                  label: const Text('Share Card'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('View Details'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
