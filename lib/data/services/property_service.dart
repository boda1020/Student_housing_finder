import '../../models/property_model.dart';

/// Fetches property listings.
///
/// Currently uses local mock data. Replace this implementation with
/// a real data source (e.g., Supabase) when ready.
class PropertyService {
  PropertyService._();

  static Future<List<Property>> fetchProperties() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    return [
      Property(
        id: '1',
        title: 'Cozy Studio Apartment Near Campus',
        address: '123 University Ave, College Town',
        price: 650,
        distanceToUniversity: 0.8,
        roomType: 'Studio',
        facilities: ['WiFi', 'AC', 'Washer'],
        imageUrl:
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1600&q=80',
        status: 'Available',
      ),
      Property(
        id: '2',
        title: 'Bright 1BR with Study Nook',
        address: '789 College St, Campus District',
        price: 820,
        distanceToUniversity: 1.2,
        roomType: '1BR',
        facilities: ['WiFi', 'Gym', 'Parking'],
        imageUrl:
            'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1600&q=80',
        status: 'Available',
      ),
      Property(
        id: '3',
        title: 'Modern 2BR Apartment with Balcony',
        address: '456 Elm St, Downtown',
        price: 1200,
        distanceToUniversity: 2.4,
        roomType: '2BR',
        facilities: ['WiFi', 'Elevator', 'Pool'],
        imageUrl:
            'https://images.unsplash.com/photo-1560185127-c0aa0f86cb4a?auto=format&fit=crop&w=1600&q=80',
        status: 'Available',
      ),
    ];
  }
}
