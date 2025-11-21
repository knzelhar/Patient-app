// lib/services/history_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';


class ConsultationHistory {
  final int id;
  final String doctorName;
  final String dateConsultation;
  final String motif;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsultationHistory({
    required this.id,
    required this.doctorName,
    required this.dateConsultation,
    required this.motif,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultationHistory.fromJson(Map<String, dynamic> json) {
    return ConsultationHistory(
      id: json['id'],
      doctorName: json['doctor_name'],
      dateConsultation: json['date_consultation'],
      motif: json['motif'],
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  String get formattedDate {
    try {
      final date = DateTime.parse(dateConsultation);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateConsultation;
    }
  }

  String get formattedTime {
    try {
      final date = DateTime.parse(dateConsultation);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String get formattedDateTime {
    return '$formattedDate à $formattedTime';
  }
}

// Service pour gerer les consultations
class HistoryService {
  static const baseUrl = 'http://10.0.2.2:3000/api/history';

  static String? _token;

  static void setToken(String token) {
    _token = token;
    print('🔑 Token défini pour HistoryService');
  }

  
  static Future<List<ConsultationHistory>> fetchConsultations() async {
    try {
      print('📥 Récupération des consultations depuis: $baseUrl');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      
      if (_token != null && _token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_token';
        print('🔐 Token ajouté aux headers');
      } else {
        print('⚠️ Aucun token disponible');
      }

      final res = await http.get(
        Uri.parse(baseUrl),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('⏱️ Timeout - Le serveur ne répond pas');
        },
      );
      
      print('📥 Status: ${res.statusCode}');
      print('📥 Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        if (data['data'] == null) {
          print('⚠️ Aucune donnée dans la réponse');
          return [];
        }
        
        final List consultationsList = data['data'];
        print('✅ ${consultationsList.length} consultation(s) trouvée(s)');
        
        return consultationsList
            .map((json) => ConsultationHistory.fromJson(json))
            .toList();
            
      } else if (res.statusCode == 401) {
        throw Exception('🔒 Non autorisé - Token invalide ou expiré');
      } else if (res.statusCode == 404) {
        throw Exception('❌ Endpoint non trouvé - Vérifier l\'URL du backend');
      } else {
        throw Exception('Erreur ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      print('❌ Erreur fetchConsultations: $e');
      rethrow;
    }
  }
}