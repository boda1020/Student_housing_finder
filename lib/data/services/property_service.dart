import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class PropertyService {
  final _supabase = Supabase.instance.client;

  // Cloudinary Configuration
  final String cloudName = 'dknqzbawm';
  final String uploadPreset = 'housing_preset';

  Future<String> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<void> addProperty({
    required String title,
    required String description,
    required double price,
    required String location,
    required int rooms,
    required String type,
    required List<String> imageUrls,
    required Map<String, bool> amenities,
    bool hasReception = false,
    bool hasSalon = false,
    bool isFurnished = false,
    int bedsCount = 1,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    List<String> selectedAmenities = amenities.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    await _supabase.from('properties').insert({
      'owner_id': user.id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'rooms': rooms,
      'property_type': type.toLowerCase(), 
      'images': imageUrls,
      'amenities': selectedAmenities,
      'has_reception': hasReception,
      'has_salon': hasSalon,
      'is_furnished': isFurnished,
      'beds_count': bedsCount,
      'is_available': true,
      'is_verified': false,
      'views': 0,
    });
  }

  Future<void> updateProperty({
    required String id,
    required String title,
    required String description,
    required double price,
    required String location,
    required int rooms,
    required String type,
    required List<String> imageUrls,
    required Map<String, bool> amenities,
    bool hasReception = false,
    bool hasSalon = false,
    bool isFurnished = false,
    int bedsCount = 1,
    bool isAvailable = true,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    List<String> selectedAmenities = amenities.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    final dynamic queryId = int.tryParse(id) ?? id;

    await _supabase.from('properties').update({
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'rooms': rooms,
      'property_type': type.toLowerCase(),
      'images': imageUrls,
      'amenities': selectedAmenities,
      'has_reception': hasReception,
      'has_salon': hasSalon,
      'is_furnished': isFurnished,
      'beds_count': bedsCount,
      'is_available': isAvailable,
    }).eq('id', queryId).eq('owner_id', user.id);
  }

  Future<void> deleteProperty(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final dynamic queryId = int.tryParse(id) ?? id;
    await _supabase.from('properties').delete().eq('id', queryId).eq('owner_id', user.id);
  }

  Future<void> incrementViews(String id) async {
    try {
      // استخدام الـ RPC الجديد لتخطي قيود الـ RLS وضمان تحديث العداد
      await _supabase.rpc('increment_property_views', params: {'prop_id': id.toString()});
      debugPrint('View incremented for: $id');
    } catch (e) {
      debugPrint('Error incrementing views: $e');
    }
  }

  Future<List<dynamic>> getOwnerProperties() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    return await _supabase.from('properties').select('*, profiles(full_name, phone, avatar_url)').eq('owner_id', user.id).order('created_at', ascending: false);
  }

  Future<bool> toggleFavorite(String propertyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      // البحث عن السجل الموجود
      final existing = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', user.id)
          .eq('property_id', propertyId)
          .maybeSingle();

      if (existing != null) {
        // حذف باستخدام الـ ID بتاع السجل نفسه لضمان الدقة
        await _supabase
            .from('favorites')
            .delete()
            .eq('id', existing['id']);
        return false; // تم الحذف
      } else {
        // إضافة سجل جديد
        await _supabase.from('favorites').insert({
          'user_id': user.id, 
          'property_id': propertyId
        });
        return true; // تم الإضافة
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String propertyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final existing = await _supabase
        .from('favorites')
        .select('id')
        .eq('user_id', user.id)
        .eq('property_id', propertyId)
        .maybeSingle();
    return existing != null;
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return <Map<String, dynamic>>[];
    final data = await _supabase.from('favorites').select('*, properties(*, profiles(full_name, phone, avatar_url))').eq('user_id', user.id);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Stream<List<Map<String, dynamic>>> getFavoritesStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);
    return _supabase.from('favorites').stream(primaryKey: ['id']).eq('user_id', user.id).asyncMap((event) async => await getFavorites());
  }

  Stream<List<Map<String, dynamic>>> getOwnerPropertiesStream() {
    final user = _supabase.auth.currentUser;
    if (user == null) return Stream.value([]);
    return _supabase.from('properties').stream(primaryKey: ['id']).eq('owner_id', user.id).order('created_at', ascending: false);
  }
}
