import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../shared/models/freight_record.dart';

class ExportUtils {
  static Future<String?> exportToExcel(List<FreightRecord> records) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Sheet1'];

      // Headers from the provided image
      List<String> headers = [
        'DATE',
        'TRUCK NO.',
        'QNT.',
        'CHALLAN QNT.',
        'DIESEL',
        'ADV',
        'RATE',
        'SHORT AMNT',
        'UNLOADING',
        'FREIGHT',
        'NAME'
      ];

      sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

      for (var record in records) {
        sheetObject.appendRow([
          TextCellValue(DateFormat('yyyy-MM-dd').format(record.date)),
          TextCellValue(record.truckNumber),
          DoubleCellValue(record.quantity),
          DoubleCellValue(record.challanQuantity),
          DoubleCellValue(record.diesel),
          DoubleCellValue(record.advance),
          DoubleCellValue(record.rate),
          DoubleCellValue(record.shortAmount),
          DoubleCellValue(record.unloading),
          DoubleCellValue(record.calculatedFreight),
          TextCellValue(record.driverName),
        ]);
      }

      final bytes = excel.encode();
      if (bytes == null) return null;

      final uint8Bytes = Uint8List.fromList(bytes);
      final fileName =
          "Freight_Records_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx";

      if (kIsWeb) {
        await FilePicker.saveFile(
          fileName: fileName,
          bytes: uint8Bytes,
        );
        return 'downloaded'; // On web it returns null but triggers download
      } else {
        return await FilePicker.saveFile(
          dialogTitle: 'Save Exported Records',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['xlsx'],
          bytes: uint8Bytes,
        );
      }
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
    }
    return null;
  }
}
