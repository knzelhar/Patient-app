import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'appointment_service.dart';
import 'history_service.dart';
import 'notification_service.dart';
class AuthService {
  // Configuration automatique selon la plateforme
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:3000"; // Émulateur Android
    } else if (Platform.isIOS) {
      return "http://localhost:3000"; // Simulateur iOS
    } else {
      return "http://localhost:3000"; // Web/Desktop
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse("$baseUrl/api/auth/login");
      print("🔗 Connexion à: $url");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10));

      print("📡 Status: ${response.statusCode}");
      print("📄 Body: ${response.body}");

      final responseData = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : {};

      // Si connexion réussie sauvegarder le token
      if (response.statusCode == 200) {
        
        final token = responseData['token'] ?? responseData['data']?['token'];
        
        if (token != null) {
          // Sauvegarder dans SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          
          // definir le token pour AppointmentService
          AppointmentService.setToken(token);
          HistoryService.setToken(token);
          NotificationService.setToken(token);
          print('✅ Token sauvegardé: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ Aucun token trouvé dans la réponse');
        }
      }

      return {
        "success": response.statusCode == 200,
        "status": response.statusCode,
        "data": responseData,
        "message": responseData['message'] ?? 'Réponse du serveur',
      };
      
    } catch (e) {
      print("❌ Erreur: $e");
      return {
        "success": false,
        "status": 0,
        "data": null,
        "message": "Erreur de connexion: $e",
      };
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse("$baseUrl/api/auth/register");
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      final responseData = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : {};

      return {
        "success": response.statusCode == 200 || response.statusCode == 201,
        "status": response.statusCode,
        "data": responseData,
        "message": responseData['message'] ?? 'Réponse du serveur',
      };
      
    } catch (e) {
      return {
        "success": false,
        "status": 0,
        "data": null,
        "message": "Erreur de connexion: $e",
      };
    }
  }

  // Recuperer le token sauvegardé
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Deconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    AppointmentService.setToken('');
    print('🚪 Déconnexion effectuée');
  }

  // Verifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}