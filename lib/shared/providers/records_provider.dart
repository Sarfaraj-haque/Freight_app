import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/freight_record.dart';

enum RecordFilter { all, pending, completed, profit, loss }

class RecordsProvider extends ChangeNotifier {
  RecordsProvider() {
    _loadRecords();
  }

  List<FreightRecord> _records = [];
  RecordFilter _filter = RecordFilter.all;
  String _searchQuery = '';
  bool _isLoading = false;

  List<FreightRecord> get allRecords => _records;
  RecordFilter get filter => _filter;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<FreightRecord> get filteredRecords {
    List<FreightRecord> result = List.from(_records);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((r) =>
              r.truckNumber.toLowerCase().contains(q) ||
              r.driverName.toLowerCase().contains(q))
          .toList();
    }

    switch (_filter) {
      case RecordFilter.all:
        break;
      case RecordFilter.pending:
        result = result.where((r) => r.status == RecordStatus.pending).toList();
        break;
      case RecordFilter.completed:
        result =
            result.where((r) => r.status == RecordStatus.completed).toList();
        break;
      case RecordFilter.profit:
        result = result.where((r) => r.isProfit).toList();
        break;
      case RecordFilter.loss:
        result = result.where((r) => !r.isProfit).toList();
        break;
    }

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  // Dashboard stats
  int get totalTrips => _records.length;
  int get pendingCount =>
      _records.where((r) => r.status == RecordStatus.pending).length;
  double get pendingOwed => _records
      .where((r) => r.status == RecordStatus.pending)
      .fold(0, (sum, r) => sum + r.calculatedFreight.abs());
  double get totalFreight =>
      _records.fold(0, (sum, r) => sum + r.calculatedFreight);
  double get totalDiesel => _records.fold(0, (sum, r) => sum + r.diesel);
  double get totalWeight => _records.fold(0, (sum, r) => sum + r.quantity);
  double get avgPerTrip =>
      _records.isEmpty ? 0 : totalFreight / _records.length;
  int get profitableCount => _records.where((r) => r.isProfit).length;

  List<FreightRecord> get recentRecords {
    final sorted = List<FreightRecord>.from(_records)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  void setFilter(RecordFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addRecord(FreightRecord record) async {
    _records.add(record);
    notifyListeners();
    await _saveRecords();
  }

  Future<void> bulkAddRecords(List<FreightRecord> records) async {
    _records.addAll(records);
    notifyListeners();
    await _saveRecords();
  }

  Future<void> updateRecord(FreightRecord record) async {
    final index = _records.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      _records[index] = record;
      notifyListeners();
      await _saveRecords();
    }
  }

  Future<void> deleteRecord(String id) async {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
    await _saveRecords();
  }

  Future<void> _loadRecords() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(AppConstants.keyRecords);
      if (json != null) {
        _records = FreightRecord.listFromJson(json);
      }
    } catch (_) {
      _records = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          AppConstants.keyRecords, FreightRecord.listToJson(_records));
    } catch (_) {}
  }

  // Monthly data for analytics
  Map<String, double> get monthlyFreight {
    final Map<String, double> result = {};
    for (final record in _records) {
      final key =
          '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + record.calculatedFreight;
    }
    return result;
  }

  // Truck performance data
  Map<String, double> get truckFreight {
    final Map<String, double> result = {};
    for (final record in _records) {
      result[record.truckNumber] =
          (result[record.truckNumber] ?? 0) + record.calculatedFreight;
    }
    return result;
  }
}
