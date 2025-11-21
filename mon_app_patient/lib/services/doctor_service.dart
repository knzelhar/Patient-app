import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class Doctor {
  final int id;
  final String fullName;
  final String? specialty;
  final String? phone;
  final String? email;

  Doctor({
    required this.id,
    required this.fullName,
    this.specialty,
    this.phone,
    this.email,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      specialty: json['specialty'],
      phone: json['phone'],
      email: json['email'],
    );
  }

  
  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}

class DoctorService {
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<void> _loadTokenIfNeeded() async {
    if (_token == null || _token!.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('jwt_token');
    }
  }

  // Recuperer tous les medecins du patient
  static Future<List<Doctor>> getMyDoctors() async {
    await _loadTokenIfNeeded();

    final url = Uri.parse("${AuthService.baseUrl}/api/doctors/my-doctors");

    print("🔵 Récupération des médecins depuis: $url");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json",
      },
    );

    print("🔵 Réponse doctors: ${response.statusCode}");
    print("🔵 Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
          "Erreur serveur (${response.statusCode}) : ${response.body}");
    }

    final jsonBody = jsonDecode(response.body);

    if (jsonBody == null || jsonBody["data"] == null) {
      throw Exception("Format JSON invalide : ${response.body}");
    }

    List doctors = jsonBody["data"];

    print("🔵 Nombre de médecins: ${doctors.length}");

    return doctors.map((e) => Doctor.fromJson(e)).toList();
  }

  // Recuperer le medecin de famille principal
  static Future<Doctor?> getFamilyDoctor() async {
    await _loadTokenIfNeeded();

    final url = Uri.parse("${AuthService.baseUrl}/api/doctors/family-doctor");

    print("🔵 Récupération médecin de famille depuis: $url");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $_token",
        "Accept": "application/json",
      },
    );

    print("🔵 Réponse family doctor: ${response.statusCode}");
    print("🔵 Body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception(
          "Erreur serveur (${response.statusCode}) : ${response.body}");
    }

    final jsonBody = jsonDecode(response.body);

    if (jsonBody == null || jsonBody["data"] == null) {
      return null; // Aucun medecin de famille
    }

    return Doctor.fromJson(jsonBody["data"]);
  }
}