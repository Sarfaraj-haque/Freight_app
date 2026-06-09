import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/freight_record.dart';

class ImportUtils {
  static Future<List<FreightRecord>?> pickAndParse() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = await result.files.single.readAsBytes();
          final extension = result.files.single.extension?.toLowerCase();
          if (extension == 'csv') {
            return _parseCSVFromBytes(bytes);
          } else {
            return _parseExcelFromBytes(bytes);
          }
        } else {
          final path = result.files.single.path;
          if (path == null) return null;
          final file = File(path);
          final extension = result.files.single.extension?.toLowerCase();

          if (extension == 'csv') {
            return _parseCSV(file);
          } else {
            return _parseExcel(file);
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking or parsing file: $e');
    }
    return null;
  }

  static Future<List<FreightRecord>> _parseCSV(File file) async {
    final input = await file.readAsString();
    return _parseCSVString(input);
  }

  static List<FreightRecord> _parseCSVFromBytes(Uint8List bytes) {
    final input = String.fromCharCodes(bytes);
    return _parseCSVString(input);
  }

  static List<FreightRecord> _parseCSVString(String input) {
    final List<List<dynamic>> rows = Csv().decode(input);
    if (rows.isEmpty) return [];

    final List<List<dynamic>> dataRows = rows.skip(1).toList();
    return _processRows(dataRows);
  }

  static Future<List<FreightRecord>> _parseExcel(File file) async {
    final bytes = await file.readAsBytes();
    return _parseExcelFromBytes(bytes);
  }

  static List<FreightRecord> _parseExcelFromBytes(Uint8List bytes) {
    final excelDoc = Excel.decodeBytes(bytes);
    final List<List<dynamic>> dataRows = [];

    for (var table in excelDoc.tables.keys) {
      final sheet = excelDoc.tables[table]!;
      for (var i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        dataRows.add(row.map((cell) => cell?.value).toList());
      }
      break;
    }
    return _processRows(dataRows);
  }

  static List<FreightRecord> _processRows(List<List<dynamic>> rows) {
    final List<FreightRecord> records = [];
    const uuid = Uuid();

    for (final row in rows) {
      try {
        if (row.isEmpty) continue;
        final firstCell = row[0];
        if (firstCell == null) continue;

        records.add(FreightRecord(
          id: uuid.v4(),
          date: _parseDate(firstCell),
          truckNumber: _toString(row.length > 1 ? row[1] : ''),
          driverName: _toString(row.length > 2 ? row[2] : ''),
          quantity: _toDouble(row.length > 3 ? row[3] : 0),
          challanQuantity: _toDouble(row.length > 4 ? row[4] : 0),
          rate: _toDouble(row.length > 5 ? row[5] : 0),
          diesel: _toDouble(row.length > 6 ? row[6] : 0),
          advance: _toDouble(row.length > 7 ? row[7] : 0),
          unloading: _toDouble(row.length > 8 ? row[8] : 0),
          shortAmount: _toDouble(row.length > 9 ? row[9] : 0),
          status: _toString(row.length > 10 ? row[10] : '').toLowerCase() ==
                  'completed'
              ? RecordStatus.completed
              : RecordStatus.pending,
        ));
      } catch (e) {
        debugPrint('Error parsing row: $e');
      }
    }
    return records;
  }

  static String _toString(dynamic value) {
    if (value == null) return '';
    if (value is CellValue) {
      return value.toString();
    }
    return value.toString();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is CellValue) {
      final str = value.toString();
      return double.tryParse(str) ?? 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;

    if (value is CellValue) {
      final str = value.toString();
      return DateTime.tryParse(str) ?? DateTime.now();
    }

    final str = value.toString();
    return DateTime.tryParse(str) ?? DateTime.now();
  }
}
