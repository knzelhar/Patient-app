import 'dart:convert';
import 'package:http/http.dart' as http;
import '../appointments_page.dart';

class AppointmentService {
  static const baseUrl = 'http://10.0.2.2:3000/api/appointments';

  // Variable pour stocker le token JWT
  static String? _token;

  static void setToken(String token) {
    _token = token;
    print('🔑 Token défini');
  }

  // Test de connexion
  static Future<void> testConnection() async {
    try {
      print('🔍 Test de connexion vers: $baseUrl');
      final res = await http.get(Uri.parse(baseUrl)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw Exception('⏱️ Timeout - Le serveur ne répond pas');
        },
      );
      print('✅ Connexion OK - Status: ${res.statusCode}');
      print('📦 Réponse: ${res.body}');
    } catch (e) {
      print('❌ Erreur de connexion: $e');
    }
  }

  // GET tous les rendez vous
  static Future<List<Appointment>> fetchAppointments() async {
    try {
      print('📥 Récupération des RDV depuis: $baseUrl');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final res = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      );
      
      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List appointments = data['data'];
        return appointments.map((json) => Appointment.fromJson(json)).toList();
      } else {
        throw Exception('Erreur ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('❌ Erreur fetchAppointments: $e');
      rethrow;
    }
  }

  // POST un rendez-vous
  static Future<Appointment> createAppointment(Appointment appt) async {
    try {
      print('📤 Création RDV vers: $baseUrl');
      
      final body = {
        'title': appt.title,
        'description': appt.description,
        'doctor': appt.doctor,
        'location': appt.location,
        'appointment_at': appt.appointmentAt.toIso8601String(),
      };
      
      print('📦 Données envoyées: $body');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
        print('🔑 Token envoyé: ${_token?.substring(0, 20)}...');
      } else {
        print('⚠️ ATTENTION: Aucun token défini !');
      }

      final res = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 201) {
        final json = jsonDecode(res.body);
        return Appointment.fromJson(json['data']);
      } else {
        throw Exception('Erreur ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('❌ Erreur createAppointment: $e');
      rethrow;
    }
  }

  // PUT modifier un rendez vous
  static Future<Appointment> updateAppointment(Appointment appt) async {
    try {
      print('📝 Modification RDV: $baseUrl/${appt.id}');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final res = await http.put(
        Uri.parse('$baseUrl/${appt.id}'),
        headers: headers,
        body: jsonEncode({
          'title': appt.title,
          'description': appt.description,
          'doctor': appt.doctor,
          'location': appt.location,
          'appointment_at': appt.appointmentAt.toIso8601String(),
        }),
      );

      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        return Appointment.fromJson(json['data']);
      } else {
        throw Exception('Erreur ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('❌ Erreur updateAppointment: $e');
      rethrow;
    }
  }

  // DELETE un rendez vous
  static Future<void> deleteAppointment(String id) async {
    try {
      print('🗑️ Suppression RDV: $baseUrl/$id');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (_token != null) {
        headers['Authorization'] = 'Bearer $_token';
      }

      final res = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );
      
      print('📥 Status: ${res.statusCode}');

      if (res.statusCode != 200) {
        throw Exception('Erreur ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('❌ Erreur deleteAppointment: $e');
      rethrow;
    }
  }
}