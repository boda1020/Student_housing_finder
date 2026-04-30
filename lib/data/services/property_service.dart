import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class PropertyService {
  final _supabase = Supabase.instance.client;

  Future<String> uploadImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
    final filePath = 'property_images/$fileName';

    await _supabase.storage.from('properties').upload(filePath, imageFile);
    
    final imageUrl = _supabase.storage.from('properties').getPublicUrl(filePath);
    return imageUrl;
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
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    await _supabase.from('properties').insert({
      'owner_id': user.id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'rooms': rooms,
      'type': type,
      'images': imageUrls,
      'amenities': amenities,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
