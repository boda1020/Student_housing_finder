import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  final _supabase = Supabase.instance.client;

  Future<void> loadCurrentUser() async {
    final sessionUser = _authService.currentUser;
    if (sessionUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', sessionUser.id)
          .single();
      
      _user = UserModel.fromJson(data);
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
