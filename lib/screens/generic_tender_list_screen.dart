import 'package:fast_tenders/core/providers/tender_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'feed_screen.dart';

enum TenderListType { myTenders, freeTenders, unread, trashed }

class GenericTenderListScreen extends ConsumerWidget {
  final TenderListType type;
  final String title;

  const GenericTenderListScreen({
    super.key,
    required this.type,
    required this.title,
  });

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final l10n = AppLocalizations.of(context)!;
      final locale = ref.watch(localeProvider);
  
      final tendersAsync = type == TenderListType.myTenders 
          ? ref.watch(sectorMatchedTendersProvider)
          : ref.watch(tendersProvider);
  
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: tendersAsync.when(
          data: (allTenders) {
            // Filter based on type (My Tenders is already filtered by its provider)
            final filtered = type == TenderListType.myTenders 
                ? allTenders 
                : allTenders.where((t) {
              switch (type) {
                case TenderListType.freeTenders:
                  return t.cpoAmount == null || t.cpoAmount == 0;
                case TenderListType.unread:
                  return DateTime.now().difference(t.postedDate).inDays < 2;
                case TenderListType.trashed:
                  return false; 
                default:
                  return true;
              }
            }).toList();
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No items in $title',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final tender = filtered[index];
              final diff = tender.deadline.difference(DateTime.now());
              final isUrgent = diff.inHours < 24 && diff.inHours > 0;
              final daysLeft = isUrgent
                  ? l10n.hoursLeft(diff.inHours)
                  : l10n.daysLeft(diff.inDays);
              final postedDiff = DateTime.now().difference(tender.postedDate);
              final dateFormat = DateFormat('MMM dd, yyyy');

              return GestureDetector(
                onTap: () => context.push(
                  '/tender-details',
                  extra: {'tenders': filtered, 'initialIndex': index},
                ),
                child: TenderCard(
                  title: tender.getOrganization(locale.languageCode),
                  subtitle: tender.getTitle(locale.languageCode),
                  daysLeft: daysLeft,
                  location: tender.getLocation(locale.languageCode),
                  postedAgo: l10n.postedAgo(
                    postedDiff.inDays == 0
                        ? l10n.today
                        : l10n.daysAgo(postedDiff.inDays),
                  ),
                  openingDate: l10n.openingDate(
                    dateFormat.format(tender.postedDate),
                  ),
                  closingDate: l10n.closingDate(
                    dateFormat.format(tender.deadline),
                  ),
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
