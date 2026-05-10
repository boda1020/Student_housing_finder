import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/property_service.dart';

class FavoriteProvider with ChangeNotifier {
  final _propertyService = PropertyService();
  final _supabase = Supabase.instance.client;
  List<String> _favoriteIds = [];

  List<String> get favoriteIds => _favoriteIds;

  FavoriteProvider() {
    _init();
  }

  void _init() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // مراقبة جدول المفضلة لحظياً
    _supabase
        .from('favorites')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((data) {
          _favoriteIds = data.map((f) => f['property_id'].toString()).toList();
          notifyListeners();
        });
  }

  Future<void> toggleFavorite(String propertyId) async {
    await _propertyService.toggleFavorite(propertyId);
    // الـ Stream سيتكفل بتحديث القائمة تلقائياً
  }

  bool isFavorite(String propertyId) {
    return _favoriteIds.contains(propertyId);
  }
}
