import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../notifications_page.dart';

class NotificationService {
  static String? _token;

  
  static int unreadCount = 0;

  
  static void setToken(String token) {
    _token = token;
  }

  
  static Future<void> _loadTokenIfNeeded() async {
    if (_token == null || _token!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('jwt_token');
    }
  }

  // GET 
  static Future<List<NotificationItem>> getNotifications() async {
    await _loadTokenIfNeeded();

    final url = Uri.parse("${AuthService.baseUrl}/api/notifications");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Erreur serveur (${response.statusCode}) : ${response.body}");
    }

    final jsonBody = jsonDecode(response.body);

    if (jsonBody == null || jsonBody["data"] == null) {
      throw Exception("Format JSON invalide : ${response.body}");
    }

  
    List notifications = jsonBody["data"];

    
    unreadCount = jsonBody["unread_count"] ?? 0;

    return notifications
        .map((e) => NotificationItem.fromJson(e))
        .toList();
  }

  //POST 
  static Future<void> markAsRead(int notificationId) async {
    await _loadTokenIfNeeded();

    final url = Uri.parse("${AuthService.baseUrl}/api/notifications/$notificationId/read");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          "Erreur lors du marquage de la notification (${response.statusCode}) : ${response.body}");
    }

    
    if (unreadCount > 0) {
      unreadCount--;
    }
  }
}