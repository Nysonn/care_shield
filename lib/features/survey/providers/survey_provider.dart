import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:care_shield/services/api_client.dart';

class SurveyTicket {
  final String id;
  final List<String> symptoms;
  final String severity;
  final String? notes;
  final DateTime createdAt;
  final String status; // e.g., 'Pending', 'Reviewed'

  SurveyTicket({
    required this.id,
    required this.symptoms,
    required this.severity,
    required this.notes,
    required this.createdAt,
    required this.status,
  });

  factory SurveyTicket.fromMap(Map<String, dynamic> map) {
    return SurveyTicket(
      id: map['id'],
      symptoms: List<String>.from(map['symptoms'] ?? []),
      severity: map['severity'] ?? 'Mild',
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      status: map['status'] ?? 'Pending',
    );
  }
}

class SurveyProvider extends ChangeNotifier {
  final ApiClient apiClient;

  SurveyProvider({required this.apiClient});

  Future<void> init() async {
    print('SurveyProvider: init started');
    print('SurveyProvider: init finished');
  }

  Future<void> createTicket({
    required List<String> symptoms,
    required String severity,
    String? notes,
  }) async {
    try {
      await apiClient.dio.post('/survey-tickets', data: {
        'symptoms': symptoms,
        'severity': severity,
        'notes': notes,
      });
      notifyListeners();
    } on DioError catch (e) {
      throw e.response?.data['message'] ?? 'Failed to create survey ticket';
    }
  }

  Future<List<SurveyTicket>> fetchTickets() async {
    try {
      final response = await apiClient.dio.get('/survey-tickets');
      return (response.data as List).map((t) => SurveyTicket.fromMap(t)).toList();
    } catch (e) {
      return [];
    }
  }
}
