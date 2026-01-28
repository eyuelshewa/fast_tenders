import 'package:fast_tenders/core/providers/locale_provider.dart';
import 'package:fast_tenders/core/providers/tender_provider.dart';
import 'package:fast_tenders/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:core/core.dart';
import 'package:fast_tenders/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class TenderScreen extends ConsumerStatefulWidget {
  const TenderScreen({super.key});

  @override
  ConsumerState<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends ConsumerState<TenderScreen> {
  int selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final categories = [
    'All',
    'Construction',
    'IT & Telecom',
    'Health',
    'Energy',
    'Supply',
  ];

  List<Tender> _filterTenders(List<Tender> allTenders) {
    final currentLocale = ref.read(localeProvider);
    final langCode = currentLocale.languageCode;

    return allTenders.where((tender) {
      // Category filter
      bool matchesCategory = true;
      if (selectedCategory != 0) {
        final cat = categories[selectedCategory].toLowerCase();
        final tenderCat = tender.category.toLowerCase();

        if (cat.contains('construction')) {
          matchesCategory =
              tenderCat.contains('construction') ||
              tenderCat.contains('material');
        } else if (cat.contains('it')) {
          matchesCategory =
              tenderCat.contains('it') ||
              tenderCat.contains('software') ||
              tenderCat.contains('equipment');
        } else if (cat.contains('supply')) {
          matchesCategory =
              tenderCat.contains('furniture') ||
              tenderCat.contains('supply') ||
              tenderCat.contains('equipment');
        } else if (cat.contains('health')) {
          matchesCategory =
              tenderCat.contains('health') || tenderCat.contains('medical');
        } else if (cat.contains('energy')) {
          matchesCategory =
              tenderCat.contains('energy') ||
              tenderCat.contains('power') ||
              tenderCat.contains('solar');
        } else {
          matchesCategory = tenderCat.contains(cat);
        }
      }

      if (!matchesCategory) return false;

      // Search filter
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      final title = tender.getTitle(langCode).toLowerCase();
      final org = tender.getOrganization(langCode).toLowerCase();
      final location = tender.getLocation(langCode).toLowerCase();

      return title.contains(query) ||
          org.contains(query) ||
          location.contains(query);
    }).toList();
  }

  String _getCategoryLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'All':
        return l10n.catAll;
      case 'Construction':
        return l10n.catConstruction;
      case 'IT & Telecom':
        return l10n.catIT;
      case 'Health':
        return l10n.catHealth;
      case 'Energy':
        return l10n.catEnergy;
      case 'Supply':
        return l10n.catSupply;
      default:
        return key;
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter by Category",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => selectedCategory = 0);
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("Reset"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(categories.length, (index) {
                      final isSelected = selectedCategory == index;
                      return ChoiceChip(
                        label: Text(
                          _getCategoryLabel(context, categories[index]),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = index;
                          });
                          setSheetState(() {});
                          Navigator.pop(context);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final tendersAsync = ref.watch(tendersProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.tendersTitle),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            child: Text(
              currentLocale.languageCode == 'am' ? 'EN' : 'አማ',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    Icons.list_alt,
                    l10n.drawerAllTenders,
                    () => context.go('/feed'),
                  ),
                  _buildDrawerItem(
                    Icons.person_outline,
                    l10n.drawerMyTenders,
                    () => context.push('/my-tenders'),
                  ),
                  _buildDrawerItem(
                    Icons.money_off,
                    l10n.drawerFreeTenders,
                    () => context.push('/free-tenders'),
                  ),
                  _buildDrawerItem(
                    Icons.bookmark_border,
                    l10n.drawerSavedTenders,
                    () => context.push('/saved-tenders'),
                  ),
                  _buildDrawerItem(
                    Icons.mark_email_unread_outlined,
                    l10n.drawerUnread,
                    () => context.push('/unread-tenders'),
                  ),
                  _buildDrawerItem(
                    Icons.delete_outline,
                    l10n.drawerTrashed,
                    () => context.push('/trashed-tenders'),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    Icons.settings_outlined,
                    l10n.drawerSettings,
                    () {
                      context.push('/profile');
                    },
                  ),
                  _buildDrawerItem(Icons.info_outline, l10n.drawerAbout, () {}),
                  _buildDrawerItem(Icons.help_outline, l10n.drawerHelp, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search + Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: selectedCategory != 0
                            ? AppColors.accent
                            : Colors.grey,
                      ),
                      onPressed: () => _showFilterSheet(context),
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Dynamic Tender cards list from mock data
          Expanded(
            child: tendersAsync.when(
              data: (tenders) {
                final filteredTenders = _filterTenders(tenders);

                if (filteredTenders.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noTendersFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.adjustFilters,
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedCategory = 0;
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Clear All Filters'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    return ref.refresh(tendersProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredTenders.length,
                    itemBuilder: (context, index) {
                      final tender = filteredTenders[index];
                      final diff = tender.deadline.difference(DateTime.now());
                      final isUrgent = diff.inHours < 24 && diff.inHours > 0;
                      final daysLeft = isUrgent
                          ? l10n.hoursLeft(diff.inHours)
                          : l10n.daysLeft(diff.inDays);

                      // Calculate posted time ago
                      final postedDiff = DateTime.now().difference(
                        tender.postedDate,
                      );
                      String postedLabel;
                      if (postedDiff.inDays == 0) {
                        postedLabel = l10n.postedAgo(l10n.today);
                      } else if (postedDiff.inDays == 1) {
                        postedLabel = l10n.postedAgo(l10n.yesterday);
                      } else {
                        postedLabel = l10n.postedAgo(
                            l10n.daysAgo(postedDiff.inDays));
                      }

                      // Format dates
                      final dateFormat = DateFormat('MMM dd, yyyy');
                      final openingDate = l10n.openingDate(
                        dateFormat.format(tender.postedDate),
                      );
                      final closingDate = l10n.closingDate(
                        dateFormat.format(tender.deadline),
                      );

                      // Color based on urgency (days left)
                      Color color;
                      if (diff.inDays < 5) {
                        color = Colors.red;
                      } else if (diff.inDays < 10) {
                        color = Colors.orange;
                      } else {
                        color = Colors.green;
                      }

                      final isPro = tender.cpoAmount == null ||
                          (tender.cpoAmount ?? 0) > 100000;

                      return GestureDetector(
                        onTap: () => context.push(
                          '/tender-details',
                          extra: {
                            'tenders': filteredTenders,
                            'initialIndex': index,
                          },
                        ),
                        child: TenderCard(
                          title: tender.getOrganization(
                            currentLocale.languageCode,
                          ),
                          subtitle: tender.getTitle(
                            currentLocale.languageCode,
                          ),
                          daysLeft: daysLeft,
                          location: tender.getLocation(
                            currentLocale.languageCode,
                          ),
                          postedAgo: postedLabel,
                          openingDate: openingDate,
                          closingDate: closingDate,
                          color: color,
                          isPro: isPro,
                          urgent: isUrgent,
                        ),
                      );
                    },
                  ),
                );
              },
              error: (error, stack) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load tenders',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.refresh(tendersProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TenderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String daysLeft;
  final String location;
  final String postedAgo;
  final String openingDate;
  final String closingDate;
  final Color color;
  final bool isPro;
  final bool urgent;

  const TenderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.daysLeft,
    required this.location,
    required this.postedAgo,
    required this.openingDate,
    required this.closingDate,
    required this.color,
    this.isPro = false,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 6)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.proLabel,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          openingDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          closingDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    postedAgo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(daysLeft, urgent ? Colors.red : Colors.orange),
                  const SizedBox(width: 8),
                  _buildChip(location, Colors.blueGrey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: bgColor is MaterialColor ? (bgColor).shade800 : bgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}