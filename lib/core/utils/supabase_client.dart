import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();

  factory SupabaseClientService() => _instance;

  SupabaseClientService._internal();

  static Future<void> initialize() async {
    await supa.Supabase.initialize(
      url: 'https://fclnqzxrctacrpjvoldb.supabase.co',     // ← غيرها بالـ URL بتاعك
      anonKey: 'sb_publishable_FGhuQU3kPBWkWj22E2gTQg_nj0hmw7Z', // ← غيرها بالـ Anon Key بتاعك (كامل)
    );

    print('✅ Supabase Connected Successfully!');
  }

  supa.Supabase get client => supa.Supabase.instance;
}