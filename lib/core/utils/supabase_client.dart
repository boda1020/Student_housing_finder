import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();

  factory SupabaseClientService() => _instance;

  SupabaseClientService._internal();

  static Future<void> initialize() async {
    await supa.Supabase.initialize(
      url: 'https://fclnqzxrctacrpjvoldb.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZjbG5xenhyY3RhY3JwanZvbGRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NDI2NDksImV4cCI6MjA5MDAxODY0OX0.J7mEfPD2B70J8SDquYGZmadbOjh_tnUUjqnQ5tVkWTo',
    );

    print('✅ Supabase Connected Successfully!');
  }

  supa.Supabase get client => supa.Supabase.instance;
}
