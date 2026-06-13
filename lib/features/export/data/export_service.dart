import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../expense/domain/expense_usecase.dart';
import '../../income/domain/income_usecase.dart';
import '../../savings/domain/savings_usecase.dart';
import '../../savings/domain/savings_withdrawal_usecase.dart';

class ExportResult {
  final int rowCount;
  final String filePath;
  final ShareResultStatus shareStatus;

  ExportResult({
    required this.rowCount,
    required this.filePath,
    required this.shareStatus,
  });
}

class ExportService {
  final IncomeUseCase incomeUseCase;
  final ExpenseUseCase expenseUseCase;
  final SavingsUseCase savingsUseCase;
  final SavingsWithdrawalUseCase withdrawalUseCase;

  ExportService({
    required this.incomeUseCase,
    required this.expenseUseCase,
    required this.savingsUseCase,
    required this.withdrawalUseCase,
  });

  Future<ExportResult> exportAllAsCsv() async {
    final incomes = await incomeUseCase.getAllIncomes();
    final expenses = await expenseUseCase.getAllExpenses();
    final savings = await savingsUseCase.getAllSavings();
    final withdrawals = await withdrawalUseCase.getAllWithdrawals();

    final rows = <List<String>>[
      ['Type', 'Date', 'Category', 'Amount', 'Description', 'Created At'],
    ];

    final dateFmt = DateFormat('yyyy-MM-dd');

    for (final i in incomes) {
      rows.add([
        'Income',
        dateFmt.format(i.date),
        i.category,
        i.amount.toStringAsFixed(2),
        i.description ?? '',
        i.createdAt.toIso8601String(),
      ]);
    }
    for (final e in expenses) {
      rows.add([
        'Expense',
        dateFmt.format(e.date),
        e.category,
        e.amount.toStringAsFixed(2),
        e.description ?? '',
        e.createdAt.toIso8601String(),
      ]);
    }
    for (final s in savings) {
      rows.add([
        'Saving',
        dateFmt.format(s.date),
        s.category,
        s.amount.toStringAsFixed(2),
        s.description ?? '',
        s.createdAt.toIso8601String(),
      ]);
    }
    for (final w in withdrawals) {
      rows.add([
        'Withdrawal',
        dateFmt.format(w.date),
        '',
        w.amount.toStringAsFixed(2),
        w.description ?? '',
        w.createdAt.toIso8601String(),
      ]);
    }

    final csv = rows.map(_formatCsvRow).join('\n');

    final stamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'expense_tracker_$stamp.csv'));
    await file.writeAsString(csv, flush: true);

    final result = await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: 'Expense Tracker export',
      text: 'Expense Tracker data export ($stamp)',
    );

    return ExportResult(
      // Row count excludes the header.
      rowCount: rows.length - 1,
      filePath: file.path,
      shareStatus: result.status,
    );
  }

  String _formatCsvRow(List<String> fields) => fields.map(_escapeCsv).join(',');

  String _escapeCsv(String value) {
    final needsQuoting = value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r');
    if (!needsQuoting) return value;
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
