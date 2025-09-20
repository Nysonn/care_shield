import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:care_shield/services/local_storage_service.dart';

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'symptoms': symptoms,
    'severity': severity,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };

  static SurveyTicket fromMap(Map map) => SurveyTicket(
    id: map['id'],
    symptoms: List<String>.from(map['symptoms'] ?? []),
    severity: map['severity'] ?? 'Mild',
    notes: map['notes'],
    createdAt: DateTime.parse(map['createdAt']),
    status: map['status'] ?? 'Pending',
  );
}

class SurveyProvider extends ChangeNotifier {
  static const _ticketsBox = 'survey_tickets_box';

  SurveyProvider();

  Future<void> init() async {
    await LocalStorageService.openEncryptedBox(_ticketsBox);
  }

  Future<void> createTicket({
    required List<String> symptoms,
    required String severity,
    String? notes,
  }) async {
    final id = const Uuid().v4();
    final ticket = SurveyTicket(
      id: id,
      symptoms: symptoms,
      severity: severity,
      notes: notes,
      createdAt: DateTime.now(),
      status: 'Pending',
    );

    final box = Hive.box(_ticketsBox);
    await box.put(id, ticket.toMap());
    notifyListeners();
  }

  Future<List<SurveyTicket>> fetchTickets() async {
    final box = Hive.box(_ticketsBox);
    final out = <SurveyTicket>[];
    for (final val in box.values) {
      out.add(SurveyTicket.fromMap(Map<String, dynamic>.from(val)));
    }
    return out;
  }
}
