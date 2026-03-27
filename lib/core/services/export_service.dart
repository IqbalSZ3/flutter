import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../features/transactions/data/models/transaction_model.dart';

class ExportService {
  static Future<void> exportTransactionsToCSV(
      BuildContext context, List<TransactionModel> transactions) async {
    try {
      final List<List<dynamic>> rows = [];
      // Header
      rows.add([
        'ID',
        'Type',
        'Amount',
        'Category ID',
        'Date',
        'Notes',
      ]);

      for (var transaction in transactions) {
        rows.add([
          transaction.id,
          transaction.type.name,
          transaction.amount,
          transaction.categoryId,
          DateFormat('yyyy-MM-dd HH:mm').format(transaction.date),
          transaction.notes ?? '',
        ]);
      }

      final String csvData = rows.map((row) => row.join(',')).join('\\n');

      final Directory tempDir = await getTemporaryDirectory();
      final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final String path = '${tempDir.path}/fintrack_transactions_$timestamp.csv';

      final File file = File(path);
      await file.writeAsString(csvData);

      if (!context.mounted) return;

      final xFile = XFile(path, mimeType: 'text/csv');
      // ignore: deprecated_member_use
      await Share.shareXFiles([xFile], text: 'FinTrack Transactions Export');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export: $e')),
        );
      }
    }
  }
}
