import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tender.dart';
import 'package:riverpod/riverpod.dart';

abstract class TenderRepository {
  Future<List<Tender>> getTenders();
  Future<Tender?> getTender(String id);
  Future<void> toggleSaveTender(String userId, String tenderId);
  Future<bool> isTenderSaved(String userId, String tenderId);
  Future<List<Tender>> getSavedTenders(String userId);
  Future<List<Tender>> getTendersBySectors(List<String> sectors);
}

class SupabaseTenderRepository implements TenderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, dynamic> _defensiveMap(Map<String, dynamic> json) {
    final Map<String, dynamic> data = Map<String, dynamic>.from(json);
    data['is_featured'] = data['is_featured'] ?? false;
    data['status'] = data['status'] ?? 'OPEN';
    data['category'] = data['category'] ?? 'General';

    // Ensure titles are strings
    data['title_en'] = data['title_en']?.toString() ?? 'No Title';
    data['title_am'] = data['title_am']?.toString() ?? 'ርዕስ የለም';
    data['organization_en'] =
        data['organization_en']?.toString() ?? 'Organization';
    data['organization_am'] = data['organization_am']?.toString() ?? 'ድርጅት';
    data['location_en'] = data['location_en']?.toString() ?? 'Ethiopia';
    data['location_am'] = data['location_am']?.toString() ?? 'ኢትዮጵያ';

    // Numeric conversion
    if (data['cpo_amount'] != null) {
      final value = data['cpo_amount'];
      if (value is num) {
        data['cpo_amount'] = value.toDouble();
      } else if (value is String) {
        data['cpo_amount'] = double.tryParse(value);
      }
    }

    // Date handling
    data['posted_date'] =
        data['posted_date'] ?? DateTime.now().toIso8601String();
    data['deadline'] =
        data['deadline'] ??
        DateTime.now().add(const Duration(days: 7)).toIso8601String();

    return data;
  }

  @override
  Future<List<Tender>> getTenders() async {
    try {
      final response = await _supabase
          .from('tenders')
          .select()
                    .order('posted_date', ascending: false)
                    .timeout(const Duration(seconds: 15));
                
                return (response as List).map((json) {
            try {
              return Tender.fromJson(_defensiveMap(json));
            } catch (e) {
              print('Error parsing individual tender: $e | JSON: $json');
              return null;
            }
          })
          .whereType<Tender>()
          .toList();
    } catch (e) {
      print('Global Error in getTenders: $e');
      rethrow;
    }
  }

  @override
  Future<Tender?> getTender(String id) async {
    try {
      final response = await _supabase
          .from('tenders')
          .select()
          .eq('id', id)
          .maybeSingle()
          .timeout(const Duration(seconds: 10));

      if (response == null) return null;
      return Tender.fromJson(_defensiveMap(response));
    } catch (e) {
      print('Error in getTender: $e');
      return null;
    }
  }

  @override
  Future<void> toggleSaveTender(String userId, String tenderId) async {
    final saved = await isTenderSaved(userId, tenderId);
    if (saved) {
      await _supabase
          .from('saved_tenders')
          .delete()
          .eq('user_id', userId)
          .eq('tender_id', tenderId);
    } else {
      await _supabase.from('saved_tenders').insert({
        'user_id': userId,
        'tender_id': tenderId,
      });
    }
  }

  @override
  Future<bool> isTenderSaved(String userId, String tenderId) async {
    try {
      final response = await _supabase
          .from('saved_tenders')
          .select()
          .eq('user_id', userId)
          .eq('tender_id', tenderId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Tender>> getSavedTenders(String userId) async {
    try {
      print('DEBUG: Fetching saved tenders for userId: $userId');
      // Fetch from saved_tenders and join with tenders table
      // We use tender_id to ensure the join happens on the correct column
      final response = await _supabase
          .from('saved_tenders')
          .select('tender_id, tenders(*)')
          .eq('user_id', userId);

      print('DEBUG: Raw saved_tenders response: $response');

      if (response == null || (response as List).isEmpty) {
        print('DEBUG: No saved tenders found in DB for this user.');
        return [];
      }

      final List<Tender> list = [];
      for (final item in (response as List)) {
        try {
          final tenderData = item['tenders'];
          if (tenderData == null) {
            print('DEBUG: tenderData is null for item: $item');
            continue;
          }
          
          // Handle both Map and List responses for the joined table
          if (tenderData is Map) {
            list.add(Tender.fromJson(_defensiveMap(Map<String, dynamic>.from(tenderData))));
          } else if (tenderData is List && tenderData.isNotEmpty) {
            list.add(Tender.fromJson(_defensiveMap(Map<String, dynamic>.from(tenderData.first))));
          }
        } catch (e) {
          print('DEBUG: Error parsing saved tender item: $e | JSON: $item');
        }
      }
      
      print('DEBUG: Successfully parsed ${list.length} saved tenders');
      return list;
    } catch (e) {
      print('DEBUG: Global Error in getSavedTenders: $e');
      return [];
    }
  }

  @override
  Future<List<Tender>> getTendersBySectors(List<String> sectors) async {
    try {
      if (sectors.isEmpty) return [];

      // The 'category' column in tenders is a TEXT (String) based on the model.
      // We use 'in' filter to match any of the selected sectors.
      final response = await _supabase
          .from('tenders')
          .select()
          .filter('category', 'in', sectors);

      if (response == null) return [];

      return (response as List)
          .map((json) {
            try {
              return Tender.fromJson(_defensiveMap(json));
            } catch (e) {
              return null;
            }
          })
          .whereType<Tender>()
          .toList();
    } catch (e) {
      return [];
    }
  }
}

final tenderRepositoryProvider = Provider<TenderRepository>((ref) {
  return SupabaseTenderRepository();
});
