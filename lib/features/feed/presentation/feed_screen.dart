import 'package:fast_tenders/features/feed/data/mock_tenders.dart';
import 'package:fast_tenders/features/feed/domain/tender_model.dart';
import 'package:flutter/material.dart'; 

class TenderScreen extends StatefulWidget {
  const TenderScreen({super.key});

  @override
  State<TenderScreen> createState() => _TenderScreenState();
}

class _TenderScreenState extends State<TenderScreen> {
  int selectedCategory = 0;

  final categories = [
    'All',
    'Construction',
    'IT & Telecom',
    'Health',
    'Energy',
    'Supply',
  ];

  List<Tender> get filteredTenders {
    final allTenders = MockTenders.list;
    if (selectedCategory == 0) return allTenders; // 'All'

    final cat = categories[selectedCategory].toLowerCase();
    return allTenders.where((tender) {
      final tenderCat = tender.category.toLowerCase();
      if (cat.contains('construction') && (tenderCat.contains('construction') || tenderCat.contains('material'))) return true;
      if (cat.contains('it') && (tenderCat.contains('it') || tenderCat.contains('software') || tenderCat.contains('equipment'))) return true;
      // Add mappings for Health, Energy, Supply as needed (e.g., Furniture -> Supply)
      if (cat.contains('supply') && tenderCat.contains('furniture')) return true;
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenders'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        actions: const [
          Icon(Icons.notifications_outlined),
          SizedBox(width: 16),
        ],
      ),

      body: Column(
        children: [
          // Search + Filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tenders / scanned text...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: const Icon(Icons.mic),
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

          // Horizontal category chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, i) {
                final selected = i == selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(categories[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => selectedCategory = i),
                    backgroundColor: Colors.grey.shade300,
                    selectedColor: Colors.blue.shade700,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: StadiumBorder(side: BorderSide.none),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Dynamic Tender cards list from mock data
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredTenders.length,
              itemBuilder: (context, index) {
                final tender = filteredTenders[index];
                final diff = tender.deadline.difference(DateTime.now());
                final isUrgent = diff.inHours < 24 && diff.inHours > 0;
                final daysLeft = isUrgent 
                    ? '${diff.inHours} Hours Left' 
                    : '${diff.inDays} Days Left';

                // Color based on category (simple mapping)
                Color color;
                switch (tender.category.toLowerCase()) {
                  case 'construction':
                  case 'construction material':
                    color = Colors.orange;
                    break;
                  case 'it equipment':
                  case 'software':
                    color = Colors.blue;
                    break;
                  case 'furniture':
                    color = Colors.green;
                    break;
                  default:
                    color = Colors.grey;
                }

                // isPro: for example, if cpoAmount > 100000 or null (custom logic)
                final isPro = tender.cpoAmount == null || (tender.cpoAmount ?? 0) > 100000;

                return TenderCard(
                  title: tender.organization,
                  subtitle: tender.title,
                  daysLeft: daysLeft,
                  location: tender.location,
                  color: color,
                  isPro: isPro,
                  urgent: isUrgent,
                );
              },
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
  final Color color;
  final bool isPro;
  final bool urgent;

  const TenderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.daysLeft,
    required this.location,
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
          border: Border(
            left: BorderSide(color: color, width: 6),
          ),
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
                    ),
                  ),
                  if (isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.purple.shade800,
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
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(daysLeft, urgent ? Colors.red : Colors.orange),
                  const SizedBox(width: 12),
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
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: bgColor is MaterialColor ? (bgColor).shade800 : bgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

