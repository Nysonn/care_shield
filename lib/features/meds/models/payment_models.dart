enum PaymentMethod {
  mtnMomo('MTN Mobile Money', 'MTN MoMo'),
  airtelMoney('Airtel Mobile Money', 'Airtel Money'),
  visaCard('Visa Card', 'Visa');

  const PaymentMethod(this.displayName, this.shortName);
  final String displayName;
  final String shortName;
}

enum PaymentStatus {
  pending('Pending', 'Payment is being processed'),
  processing('Processing', 'Payment is in progress'),
  completed('Completed', 'Payment successful'),
  failed('Failed', 'Payment failed');

  const PaymentStatus(this.displayName, this.description);
  final String displayName;
  final String description;
}

class DeliveryOption {
  final String id;
  final String name;
  final String description;
  final double price;
  final String eta;
  final String currency;
  final List<String> availableZones;

  DeliveryOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.eta,
    this.currency = 'UGX',
    required this.availableZones,
  });

  static List<DeliveryOption> getDeliveryOptions() {
    return [
      DeliveryOption(
        id: 'same_day',
        name: 'Same Day Delivery',
        description: 'Within Kampala only',
        price: 5000,
        eta: 'Same day (6-8 hours)',
        availableZones: ['Kampala'],
      ),
      DeliveryOption(
        id: 'next_day',
        name: 'Next Day Delivery',
        description: 'Within Central Region',
        price: 8000,
        eta: 'Next day delivery',
        availableZones: ['Kampala', 'Wakiso', 'Mukono', 'Mpigi'],
      ),
      DeliveryOption(
        id: 'standard',
        name: 'Standard Delivery',
        description: 'Nationwide delivery',
        price: 12000,
        eta: '2-3 business days',
        availableZones: ['Nationwide'],
      ),
      DeliveryOption(
        id: 'express',
        name: 'Express Delivery',
        description: '2-4 hours in Kampala',
        price: 15000,
        eta: '2-4 hours',
        availableZones: ['Kampala Central'],
      ),
    ];
  }
}

class PaymentInfo {
  final PaymentMethod method;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? referenceCode;
  final DateTime? processedAt;
  final String? failureReason;

  PaymentInfo({
    required this.method,
    required this.status,
    required this.amount,
    this.currency = 'UGX',
    this.referenceCode,
    this.processedAt,
    this.failureReason,
  });

  Map<String, dynamic> toMap() => {
    'method': method.name,
    'status': status.name,
    'amount': amount,
    'currency': currency,
    'referenceCode': referenceCode,
    'processedAt': processedAt?.toIso8601String(),
    'failureReason': failureReason,
  };

  static PaymentInfo fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      method: PaymentMethod.values.firstWhere((e) => e.name == map['method']),
      status: PaymentStatus.values.firstWhere((e) => e.name == map['status']),
      amount: map['amount'].toDouble(),
      currency: map['currency'] ?? 'UGX',
      referenceCode: map['referenceCode'],
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
      failureReason: map['failureReason'],
    );
  }
}
