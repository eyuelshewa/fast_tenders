import 'package:fast_tenders/features/feed/data/mock_tenders.dart';
import 'package:flutter/material.dart';
import 'widgets/tender_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tenders = MockTenders.list;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TenderWin Ethiopia'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tenders.length,
        itemBuilder: (context, index) {
          return TenderCard(tender: tenders[index]);
        },
      ),
    );
  }
}
