import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Sign up a new user
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? university,
    required String role,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
      },
    );

    if (response.user != null) {
      await _supabase.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'phone': phone,
        'university': university,
        'role': role,
      });
    }
    return response;
  }

  // Regular sign in
  Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
  
  Future<bool> isOwner() async {
    final userId = currentUser?.id;
    if (userId == null) return false;
    
    final data = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    
    return data != null && data['role'] == 'owner';
  }
}
