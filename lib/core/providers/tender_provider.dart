import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final tendersProvider = FutureProvider<List<Tender>>((ref) async {
  final repository = ref.watch(tenderRepositoryProvider);
  return repository.getTenders();
});

/// Tenders that match the user's business profile sectors
final sectorMatchedTendersProvider = FutureProvider<List<Tender>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  
  final repo = ref.watch(tenderRepositoryProvider);
  
  // Get business profile to find sectors
  final profileResponse = await Supabase.instance.client
      .from('business_profiles')
      .select('sectors')
      .eq('id', user.id)
      .maybeSingle();
  
  if (profileResponse != null && profileResponse['sectors'] != null) {
    final sectors = List<String>.from(profileResponse['sectors']);
    return await repo.getTendersBySectors(sectors);
  }

  return [];
});

/// Tenders explicitly saved by the user
final savedTendersProvider = FutureProvider<List<Tender>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  
  final repo = ref.watch(tenderRepositoryProvider);
  return await repo.getSavedTenders(user.id);
});

// Keep this for backward compatibility if needed, or remove later
final myTendersProvider = FutureProvider<List<Tender>>((ref) async {
  final sectorMatches = await ref.watch(sectorMatchedTendersProvider.future);
  final saved = await ref.watch(savedTendersProvider.future);

  // Merge and deduplicate by ID
  final combined = [...saved, ...sectorMatches];
  final ids = <String>{};
  return combined.where((t) => ids.add(t.id)).toList();
});