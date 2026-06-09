import 'dart:convert';

enum RecordStatus { pending, completed }

class FreightRecord {
  const FreightRecord({
    required this.id,
    required this.date,
    required this.truckNumber,
    required this.driverName,
    required this.quantity,
    this.challanQuantity = 0,
    required this.rate,
    this.diesel = 0,
    this.advance = 0,
    this.unloading = 0,
    this.shortAmount = 0,
    required this.status,
  });

  final String id;
  final DateTime date;
  final String truckNumber;
  final String driverName;
  final double quantity;
  final double challanQuantity;
  final double rate;
  final double diesel;
  final double advance;
  final double unloading;
  final double shortAmount;
  final RecordStatus status;

  double get calculatedFreight =>
      (quantity * rate) - diesel - advance - unloading - shortAmount;

  bool get isProfit => calculatedFreight > 0;

  FreightRecord copyWith({
    String? id,
    DateTime? date,
    String? truckNumber,
    String? driverName,
    double? quantity,
    double? challanQuantity,
    double? rate,
    double? diesel,
    double? advance,
    double? unloading,
    double? shortAmount,
    RecordStatus? status,
  }) {
    return FreightRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      truckNumber: truckNumber ?? this.truckNumber,
      driverName: driverName ?? this.driverName,
      quantity: quantity ?? this.quantity,
      challanQuantity: challanQuantity ?? this.challanQuantity,
      rate: rate ?? this.rate,
      diesel: diesel ?? this.diesel,
      advance: advance ?? this.advance,
      unloading: unloading ?? this.unloading,
      shortAmount: shortAmount ?? this.shortAmount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'truckNumber': truckNumber,
        'driverName': driverName,
        'quantity': quantity,
        'challanQuantity': challanQuantity,
        'rate': rate,
        'diesel': diesel,
        'advance': advance,
        'unloading': unloading,
        'shortAmount': shortAmount,
        'status': status.name,
      };

  factory FreightRecord.fromJson(Map<String, dynamic> json) => FreightRecord(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        truckNumber: json['truckNumber'] as String,
        driverName: json['driverName'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        challanQuantity: (json['challanQuantity'] as num? ?? 0).toDouble(),
        rate: (json['rate'] as num).toDouble(),
        diesel: (json['diesel'] as num? ?? 0).toDouble(),
        advance: (json['advance'] as num? ?? 0).toDouble(),
        unloading: (json['unloading'] as num? ?? 0).toDouble(),
        shortAmount: (json['shortAmount'] as num? ?? 0).toDouble(),
        status: RecordStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RecordStatus.pending,
        ),
      );

  static List<FreightRecord> listFromJson(String source) {
    final List<dynamic> list = jsonDecode(source) as List<dynamic>;
    return list
        .map((e) => FreightRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<FreightRecord> records) {
    return jsonEncode(records.map((e) => e.toJson()).toList());
  }
}
