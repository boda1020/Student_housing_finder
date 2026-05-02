import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SupabaseClientService {
  static final SupabaseClientService _instance = SupabaseClientService._internal();

  factory SupabaseClientService() => _instance;

  SupabaseClientService._internal();

  static Future<void> initialize() async {
    await supa.Supabase.initialize(
      url: 'https://qleulxlgighwxrdkobdt.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsZXVseGxnaWdod3hyZGtvYmR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1NTI4MjcsImV4cCI6MjA5MzEyODgyN30.r2O2rlHzYR5Plzx6uWfcAARbzW0Inb5ZXtnsEhglbws',
    );

    print('✅ Supabase Connected Successfully!');
  }

  supa.Supabase get client => supa.Supabase.instance;
}
