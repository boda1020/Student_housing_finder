import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/property_model.dart';

class PropertyService {
  final _supabase = Supabase.instance.client;

  // Fetch all available properties for students
  Future<List<Property>> fetchAllProperties() async {
    final response = await _supabase
        .from('properties')
        .select()
        .eq('status', 'Available')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Property.fromJson(json)).toList();
  }

  // Fetch properties owned by the current user (Owner)
  Future<List<Property>> fetchOwnerProperties() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('properties')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Property.fromJson(json)).toList();
  }

  // Add a new property
  Future<void> addProperty(Property property) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final data = property.toJson();
    data['owner_id'] = userId;
    data.remove('id'); // Let Supabase generate the ID

    await _supabase.from('properties').insert(data);
  }

  // Update an existing property
  Future<void> updateProperty(Property property) async {
    await _supabase
        .from('properties')
        .update(property.toJson())
        .eq('id', property.id);
  }

  // Delete a property
  Future<void> deleteProperty(String propertyId) async {
    await _supabase.from('properties').delete().eq('id', propertyId);
  }

  // Upload property image to Supabase Storage
  Future<String?> uploadPropertyImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final path = 'properties/$fileName';
      
      await _supabase.storage.from('images').upload(path, imageFile);
      
      final imageUrl = _supabase.storage.from('images').getPublicUrl(path);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
