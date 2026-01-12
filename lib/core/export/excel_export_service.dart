import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/forms/models/form_model.dart';
import '../../features/submissions/models/submission_model.dart';

final excelExportServiceProvider = Provider((ref) => ExcelExportService());

class ExcelExportService {
  Future<String> exportFormSubmissions(FormModel form, List<SubmissionModel> submissions) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // 1. Create Headers
    final headers = [
      'Submission ID',
      'Sync Status',
      'Created At',
      ...form.fields.map((f) => f.label),
    ];
    
    sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // 2. Add Data Rows
    for (final submission in submissions) {
      final row = <CellValue>[];
      
      // Standard Columns
      row.add(TextCellValue(submission.id));
      row.add(TextCellValue(submission.syncStatus.name));
      row.add(TextCellValue(submission.createdAt.toIso8601String()));

      // Dynamic Columns matching form.fields order
      for (final field in form.fields) {
        final value = submission.data[field.label] ?? '';
        row.add(TextCellValue(value.toString()));
      }

      sheet.appendRow(row);
    }

    // 3. Save File
    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final fileName = '${form.title.replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final filePath = '${exportDir.path}/$fileName';
    
    final fileBytes = excel.save();
    if (fileBytes != null) {
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
    }

    return filePath;
  }
}
