import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications(String userId);
  Future<Notification?> getNotification(String id);
  Future<Notification> createNotification(Notification notification);
  Future<Notification> updateNotification(String id, Notification notification);
  Future<void> deleteNotification(String id);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(String userId);
}

class SupabaseNotificationRepository implements NotificationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Notification>> getNotifications(String userId) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) {
      // Ensure 'type' exists to match Notification model
      if (json['type'] == null) json['type'] = 'general';
      return Notification.fromJson(json);
    }).toList();
  }

  @override
  Future<Notification?> getNotification(String id) async {
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('id', id)
        .single();
    return Notification.fromJson(response);
  }

  @override
  Future<Notification> createNotification(Notification notification) async {
    final data = notification.toJson();
    if (data['type'] == null) data['type'] = 'general';
    
    final response = await _supabase
        .from('notifications')
        .insert(data)
        .select()
        .single();
    return Notification.fromJson(response);
  }

  @override
  Future<Notification> updateNotification(
    String id,
    Notification notification,
  ) async {
    final response = await _supabase
        .from('notifications')
        .update(notification.toJson())
        .eq('id', id)
        .select()
        .single();
    return Notification.fromJson(response);
  }

  @override
  Future<void> deleteNotification(String id) async {
    await _supabase.from('notifications').delete().eq('id', id);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
