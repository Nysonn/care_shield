import 'package:flutter/material.dart';
import '../models/drug.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:care_shield/services/local_storage_service.dart';

class MedOrder {
  final String id;
  final String stage;
  final List<Drug> drugs;
  final String location;
  final DateTime createdAt;
  final String eta;

  MedOrder({
    required this.id,
    required this.stage,
    required this.drugs,
    required this.location,
    required this.createdAt,
    required this.eta,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'stage': stage,
    'drugs': drugs
        .map((d) => {'id': d.id, 'name': d.name, 'dosage': d.dosage})
        .toList(),
    'location': location,
    'createdAt': createdAt.toIso8601String(),
    'eta': eta,
  };

  static MedOrder fromMap(Map map) {
    final drugsList = (map['drugs'] as List)
        .map(
          (d) => Drug(
            id: d['id'],
            name: d['name'],
            description: '',
            dosage: d['dosage'],
          ),
        )
        .toList();
    return MedOrder(
      id: map['id'],
      stage: map['stage'],
      drugs: drugsList,
      location: map['location'],
      createdAt: DateTime.parse(map['createdAt']),
      eta: map['eta'],
    );
  }
}

class MedsProvider extends ChangeNotifier {
  final List<Drug> _drugs = [
    Drug(
      id: 'd1',
      name: 'Tenofovir/Lamivudine/Efavirenz (TLE)',
      description: 'Common first-line regimen',
      dosage: '1 tablet daily',
    ),
    Drug(
      id: 'd2',
      name: 'Tenofovir/Lamivudine/Dolutegravir (TLD)',
      description: 'Preferred regimen',
      dosage: '1 tablet daily',
    ),
    Drug(
      id: 'd3',
      name: 'Abacavir/Lamivudine (ABC/3TC)',
      description: 'Alternative backbone',
      dosage: '1 tablet daily',
    ),
    Drug(
      id: 'd4',
      name: 'AZT/3TC/NVP',
      description: 'Older regimen',
      dosage: 'As prescribed',
    ),
  ];

  List<Drug> get drugs => List.unmodifiable(_drugs);

  static const _ordersBox = 'med_orders_box';

  MedsProvider();

  Future<void> init() async {
    await LocalStorageService.openEncryptedBox(_ordersBox);
  }

  Future<void> placeOrder({
    required String stage,
    required List<Drug> drugs,
    required String location,
  }) async {
    final id = const Uuid().v4();
    final createdAt = DateTime.now();
    final eta = '2-4 days';

    final order = MedOrder(
      id: id,
      stage: stage,
      drugs: drugs,
      location: location,
      createdAt: createdAt,
      eta: eta,
    );
    final box = Hive.box(_ordersBox);
    await box.put(id, order.toMap());
    notifyListeners();
  }

  Future<List<MedOrder>> fetchOrders() async {
    final box = Hive.box(_ordersBox);
    final out = <MedOrder>[];
    for (final val in box.values) {
      out.add(MedOrder.fromMap(Map<String, dynamic>.from(val)));
    }
    return out;
  }
}
