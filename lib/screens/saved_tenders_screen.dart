import 'package:fast_tenders/core/providers/tender_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'feed_screen.dart';

class SavedTendersScreen extends ConsumerWidget {
  const SavedTendersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.drawerSavedTenders)),
        body: const Center(child: Text('Please login to see saved tenders')),
      );
    }

    final tenders = ref.watch(savedTendersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.drawerSavedTenders),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: tenders.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No saved tenders yet', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final tender = list[index];
              final diff = tender.deadline.difference(DateTime.now());
              final isUrgent = diff.inHours < 24 && diff.inHours > 0;
              final daysLeft = isUrgent
                  ? l10n.hoursLeft(diff.inHours)
                  : l10n.daysLeft(diff.inDays);
              
              final postedDiff = DateTime.now().difference(tender.postedDate);
              String postedLabel = postedDiff.inDays == 0 ? l10n.today : l10n.daysAgo(postedDiff.inDays);

              final dateFormat = DateFormat('MMM dd, yyyy');

              return GestureDetector(
                onTap: () => context.push('/tender-details', extra: {
                  'tenders': list,
                  'initialIndex': index,
                }),
                child: TenderCard(
                  title: tender.getOrganization(locale.languageCode),
                  subtitle: tender.getTitle(locale.languageCode),
                  daysLeft: daysLeft,
                  location: tender.getLocation(locale.languageCode),
                  postedAgo: l10n.postedAgo(postedLabel),
                  openingDate: l10n.openingDate(dateFormat.format(tender.postedDate)),
                  closingDate: l10n.closingDate(dateFormat.format(tender.deadline)),
                  color: diff.inDays < 5 ? Colors.red : Colors.green,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}