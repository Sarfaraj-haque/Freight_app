import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/freight_record.dart';

class ImportResult {
  final List<FreightRecord>? records;
  final String? error;
  final bool isCancelled;

  ImportResult({this.records, this.error, this.isCancelled = false});
}

class ImportUtils {
  static Future<ImportResult> pickAndParse() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult(isCancelled: true);
      }

      final platformFile = result.files.first;
      final extension = platformFile.extension?.toLowerCase();

      Uint8List? bytes = platformFile.bytes;

      if (bytes == null) {
        try {
          bytes = await platformFile.readAsBytes();
        } catch (e) {
          return ImportResult(
            error:
                'Could not read file data. Try moving the file to your Downloads folder.',
          );
        }
      }

      if (extension == 'csv') {
        try {
          String input;
          try {
            input = utf8.decode(bytes);
          } catch (_) {
            input = String.fromCharCodes(bytes);
          }
          final records = _parseCSVString(input);
          return ImportResult(records: records);
        } catch (e) {
          return ImportResult(error: 'Failed to parse CSV: $e');
        }
      } else if (extension == 'xlsx') {
        try {
          final records = _parseExcelFromBytes(bytes);
          return ImportResult(records: records);
        } catch (e) {
          return ImportResult(error: 'Failed to parse Excel: $e');
        }
      } else {
        return ImportResult(error: 'Unsupported format: .$extension');
      }
    } catch (e) {
      return ImportResult(error: 'An unexpected error occurred: $e');
    }
  }

  static List<FreightRecord> _parseCSVString(String input) {
    final List<List<dynamic>> rows = Csv().decode(input);
    if (rows.isEmpty) return [];
    return _processDynamicRows(rows);
  }

  static List<FreightRecord> _parseExcelFromBytes(Uint8List bytes) {
    final excelDoc = Excel.decodeBytes(bytes);
    final List<List<dynamic>> allRows = [];

    for (var table in excelDoc.tables.keys) {
      final sheet = excelDoc.tables[table]!;
      for (var i = 0; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        allRows.add(row.map((cell) => cell?.value).toList());
      }
      break; // Process only the first sheet
    }
    return _processDynamicRows(allRows);
  }

  static List<FreightRecord> _processDynamicRows(List<List<dynamic>> allRows) {
    if (allRows.isEmpty) return [];

    int headerRowIndex = -1;
    Map<String, int> colMap = {};

    // 1. Find the header row by searching for keywords
    for (int i = 0; i < allRows.length; i++) {
      final row = allRows[i];
      final rowStr = row.map((e) => e.toString().toUpperCase()).toList();

      if (rowStr.contains('DATE') || rowStr.contains('TRUCK NO.')) {
        headerRowIndex = i;
        for (int j = 0; j < row.length; j++) {
          final header = row[j]?.toString().toUpperCase().trim() ?? '';
          if (header.contains('DATE')) colMap['date'] = j;
          if (header.contains('TRUCK NO')) colMap['truck'] = j;
          if (header.contains('QNT') && !header.contains('CHALLAN'))
            colMap['qty'] = j;
          if (header.contains('CHALLAN')) colMap['challan'] = j;
          if (header.contains('DISEL')) colMap['diesel'] = j;
          if (header.contains('ADV')) colMap['advance'] = j;
          if (header.contains('RATE')) colMap['rate'] = j;
          if (header.contains('SHORT')) colMap['short'] = j;
          if (header.contains('UNLOD')) colMap['unloading'] = j;
          if (header.contains('NAME')) colMap['name'] = j;
        }
        break;
      }
    }

    // Fallback to fixed positions if headers not found
    if (headerRowIndex == -1) {
      debugPrint('Header row not found, using default mapping');
      headerRowIndex = 0; // Assume data starts from row 1
      colMap = {
        'date': 0,
        'truck': 1,
        'qty': 2,
        'challan': 3,
        'diesel': 4,
        'advance': 5,
        'rate': 6,
        'short': 7,
        'unloading': 8,
        'name': 10
      };
    }

    final List<FreightRecord> records = [];
    const uuid = Uuid();

    // 2. Process data starting from the row AFTER the header
    for (int i = headerRowIndex + 1; i < allRows.length; i++) {
      final row = allRows[i];
      if (row.isEmpty || row.every((cell) => cell == null)) continue;

      try {
        records.add(FreightRecord(
          id: uuid.v4(),
          date: _parseDate(_getVal(row, colMap['date'])),
          truckNumber: _toString(_getVal(row, colMap['truck'])),
          quantity: _toDouble(_getVal(row, colMap['qty'])),
          challanQuantity: _toDouble(_getVal(row, colMap['challan'])),
          diesel: _toDouble(_getVal(row, colMap['diesel'])),
          advance: _toDouble(_getVal(row, colMap['advance'])),
          rate: _toDouble(_getVal(row, colMap['rate'])),
          shortAmount: _toDouble(_getVal(row, colMap['short'])),
          unloading: _toDouble(_getVal(row, colMap['unloading'])),
          driverName: _toString(_getVal(row, colMap['name'])),
          status: RecordStatus.pending,
        ));
      } catch (e) {
        debugPrint('Error parsing row $i: $e');
      }
    }

    return records;
  }

  static dynamic _getVal(List<dynamic> row, int? index) {
    if (index == null || index < 0 || index >= row.length) return null;
    return row[index];
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    // Handle specific CellValue types from excel package if necessary
    if (value is CellValue) {
      // Depending on the version, CellValue might have a 'value' property or toString()
      return value.toString().trim();
    }
    return value.toString().trim();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is CellValue) {
      final str = value.toString();
      return double.tryParse(str) ?? 0.0;
    }
    final str = value.toString();
    return double.tryParse(str) ?? 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;

    // For Excel dates which might come as double
    if (value is num) {
      // Excel base date is 1899-12-30
      return DateTime(1899, 12, 30).add(Duration(days: value.toInt()));
    }

    String dateStr = value.toString();

    // Try standard parsing
    DateTime? parsed = DateTime.tryParse(dateStr);
    if (parsed != null) return parsed;

    // Custom parsing for common formats if tryParse fails
    // e.g. 03-11-26 (DD-MM-YY)
    try {
      final parts = dateStr.split(RegExp(r'[-/]'));
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        if (year < 100) year += 2000;
        return DateTime(year, month, day);
      }
    } catch (_) {}

    return DateTime.now();
  }
}
