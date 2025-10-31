// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService with ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _loadUserData();
  }

  int? _userId;
  String? _token;
  String? _userName;
  String? _userEmail;

  int? get userId => _userId;
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  bool get isLoggedIn => _userId != null && _token != null;

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('userId');
      _token = prefs.getString('token');
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');

      if (kDebugMode) {
        print('📱 Datos de usuario cargados: ID: $_userId');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error cargando datos de usuario: $e');
      }
    }
  }

  Future<void> login(Map<String, dynamic> responseData) async {
    try {
      _userId = responseData['usuario']['id'];
      _token = responseData['token'];
      _userName = responseData['usuario']['nombre'];
      _userEmail = responseData['usuario']['email'];

      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _userId!);
      await prefs.setString('token', _token!);
      await prefs.setString('userName', _userName!);
      await prefs.setString('userEmail', _userEmail!);

      if (kDebugMode) {
        print('✅ Usuario logueado - ID: $_userId, Nombre: $_userName');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando datos de usuario: $e');
      }
    }
  }

  Future<void> logout() async {
    try {
      _userId = null;
      _token = null;
      _userName = null;
      _userEmail = null;

 
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('userName');
      await prefs.remove('userEmail');

      if (kDebugMode) {
        print('✅ Usuario deslogueado');
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error durante logout: $e');
      }
    }
  }


  Future<void> clearSessionOnExit() async {
    try {
      if (kDebugMode) {
        print('🚪 Limpiando sesión al salir de la app...');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('token');
      await prefs.remove('userName');
      await prefs.remove('userEmail');

      _userId = null;
      _token = null;
      _userName = null;
      _userEmail = null;

      if (kDebugMode) {
        print('✅ Sesión limpiada exitosamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando sesión: $e');
      }
    }
  }

  Future<bool> hasActiveSession() async {
    await _loadUserData();
    return isLoggedIn;
  }
}