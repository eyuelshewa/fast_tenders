import 'package:fast_tenders/core/providers/tender_provider.dart';
import 'package:fast_tenders/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../core/providers/locale_provider.dart';
import 'package:fast_tenders/core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class TenderDetailScreen extends ConsumerStatefulWidget {
  final List<Tender> tenders;
  final int initialIndex;

  const TenderDetailScreen({
    super.key,
    required this.tenders,
    required this.initialIndex,
  });

  @override
  ConsumerState<TenderDetailScreen> createState() => _TenderDetailScreenState();
}

class _TenderDetailScreenState extends ConsumerState<TenderDetailScreen> {
  late int currentIndex;
  bool isSaving = false;
  // Track alert status per tender ID
  final Map<String, bool> _alertStates = {};

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  Tender get tender => widget.tenders[currentIndex];
  bool get isAlertSet => _alertStates[tender.id] ?? false;

  Future<void> _toggleSave() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() => isSaving = true);
    try {
      await ref
          .read(tenderRepositoryProvider)
          .toggleSaveTender(user.id, tender.id);

      // Refresh the saved tenders list
      ref.invalidate(savedTendersProvider);

      // We need a way to refresh the UI state.
      // For simplicity in this demo, we'll just force a rebuild.
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tender bookmark updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? theme.scaffoldBackgroundColor
            : AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.tendersTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              final text =
                  "${tender.getOrganization(langCode)}\n${tender.getTitle(langCode)}\nDeadline: ${DateFormat('MMM dd, yyyy').format(tender.deadline)}";
              Share.share(text);
            },
          ),
          const SizedBox(width: 8),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description Section
            _buildDescriptionSection(context, tender, langCode),

            // Locked Bidding Documents
            _buildBiddingDocuments(context),

            // Historical Winning Prices (PRO)
            _buildHistoricalPrices(context),

            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context, l10n),
    );
  }

  Widget _buildDescriptionSection(
    BuildContext context,
    Tender tender,
    String langCode,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Description",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOCRLine(
                  context,
                  "Organization",
                  tender.getOrganization(langCode),
                ),
                _buildOCRLine(context, "Project", tender.getTitle(langCode)),
                _buildOCRLine(
                  context,
                  "Deadline",
                  DateFormat('MMM dd, yyyy (hh:mm a)').format(tender.deadline),
                ),
                _buildOCRLine(
                  context,
                  "Bid Bond",
                  tender.cpoAmount != null
                      ? "${NumberFormat.decimalPattern().format(tender.cpoAmount)} ETB (CPO or Bank Guarantee)"
                      : "Not specified",
                ),
                _buildOCRLine(
                  context,
                  "Eligibility",
                  tender.minGrade ?? "Unknown",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOCRLine(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiddingDocuments(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bidding Documents",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildLockedDocItem(context, "Document 1"),
                const SizedBox(height: 12),
                _buildLockedDocItem(context, "Document 2"),
              ],
            ),
          ),
          // Locked Overlay
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_bag,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Access Documents",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Get the full BOQ and technical specifications instantly.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments_outlined),
                              SizedBox(width: 8),
                              Text(
                                "Buy for 500 ETB with Telebirr",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedDocItem(BuildContext context, String name) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.2)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.description,
            color: theme.hintColor.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
                  width: 100,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 6,
                  width: 60,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock, color: theme.hintColor, size: 18),
        ],
      ),
    );
  }

  Widget _buildHistoricalPrices(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Historical Winning Prices",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBar(context, 0.4),
                          _buildBar(context, 0.7),
                          _buildBar(context, 0.3),
                          _buildBar(context, 0.9),
                          _buildBar(context, 0.6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "2020",
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          "2021",
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          "2022",
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.hintColor,
                          ),
                        ),
                        Text(
                          "2023",
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Blurred Overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.1),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF101922,
                            ).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Unlock market insights for\nsimilar tenders",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: const StadiumBorder(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 8,
                                  ),
                                ),
                                child: const Text(
                                  "Upgrade to Pro",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, double heightFactor) {
    final theme = Theme.of(context);
    return Container(
      width: 30,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: currentIndex > 0
                  ? () => setState(() => currentIndex--)
                  : null,
              icon: Icon(
                Icons.arrow_back_ios,
                color: currentIndex > 0
                    ? theme.colorScheme.onSurface
                    : theme.disabledColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FutureBuilder<bool>(
                future: () async {
                  final user = ref.read(currentUserProvider).value;
                  if (user == null) return false;
                  return ref
                      .read(tenderRepositoryProvider)
                      .isTenderSaved(user.id, tender.id);
                }(),
                builder: (context, snapshot) {
                  final isSaved = snapshot.data ?? false;
                  return OutlinedButton.icon(
                    onPressed: isSaving ? null : _toggleSave,
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    ),
                    label: Text(isSaved ? "Saved" : "Save"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _alertStates[tender.id] = !isAlertSet;
                });
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isAlertSet
                          ? 'Alerts set for this tender'
                          : 'Alerts disabled',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAlertSet
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 1,
                  ),
                  boxShadow: isAlertSet
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isAlertSet
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: isAlertSet ? Colors.white : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: currentIndex < widget.tenders.length - 1
                  ? () => setState(() => currentIndex++)
                  : null,
              icon: Icon(
                Icons.arrow_forward_ios,
                color: currentIndex < widget.tenders.length - 1
                    ? theme.colorScheme.onSurface
                    : theme.disabledColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
