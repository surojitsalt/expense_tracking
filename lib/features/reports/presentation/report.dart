import 'package:flutter/material.dart';
import '../../../navigation/app_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/expense_tracker_app_colors.dart';
import '../bloc/report_bloc.dart';
import '../../savings/domain/savings_withdrawal_model.dart';
import '../../settings/presentation/settings_bloc.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReport());
  }

  void _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (range != null) {
      if (!mounted) return;
      setState(() => _dateRange = range);
      final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      context.read<ReportBloc>().add(FilterReportByDate(range.start, end));
    }
  }

  void _showWithdrawalDialog() {
    final currencySymbol = context.read<SettingsBloc>().state.currencySymbol;
    final amountController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('Withdraw from Savings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount ($currencySymbol)',
                    prefixIcon: const Icon(Icons.monetization_on_outlined),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.notes),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setDialogState(() => selectedDate = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text.trim());
                  if (amount == null || amount <= 0) return;
                  context.read<ReportBloc>().add(
                    AddSavingsWithdrawal(
                      SavingsWithdrawalModel(
                        amount: amount,
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                        date: selectedDate,
                        createdAt: DateTime.now(),
                      ),
                    ),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Withdraw'),
              ),
            ],
          );
        });
      },
    );
  }

  Color _savingsAlertColor(double netSavings) {
    if (netSavings >= 30000) return Colors.green.shade600;
    if (netSavings >= 15000) return Colors.yellow.shade700;
    if (netSavings >= 10000) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  String _savingsAlertLabel(double netSavings) {
    if (netSavings >= 30000) return 'Healthy';
    if (netSavings >= 15000) return 'Moderate';
    if (netSavings >= 10000) return 'Low';
    return 'Critical';
  }

  IconData _savingsAlertIcon(double netSavings) {
    if (netSavings >= 30000) return Icons.check_circle;
    if (netSavings >= 15000) return Icons.warning_amber;
    if (netSavings >= 10000) return Icons.warning;
    return Icons.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ExpenseTrackerAppColors>()!;
    final currencySymbol = context.watch<SettingsBloc>().state.currencySymbol;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.grey.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Withdraw from Savings',
            onPressed: _showWithdrawalDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading || state is ReportInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportLoaded) {
            final netSavings = state.netSavings;
            final alertColor = _savingsAlertColor(netSavings);

            List<Map<String, dynamic>> allRecords = [];
            for (var i in state.incomes) {
              allRecords.add({'date': i.date, 'type': 'Income', 'category': i.category, 'amount': i.amount, 'color': colors.income});
            }
            for (var e in state.expenses) {
              allRecords.add({'date': e.date, 'type': 'Expense', 'category': e.category, 'amount': e.amount, 'color': colors.expense});
            }
            for (var s in state.savings) {
              allRecords.add({'date': s.date, 'type': 'Saving', 'category': s.category, 'amount': s.amount, 'color': colors.savings});
            }
            for (var w in state.withdrawals) {
              allRecords.add({'date': w.date, 'type': 'Withdrawal', 'category': 'Savings', 'amount': w.amount, 'color': Colors.deepOrange});
            }
            allRecords.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

            return Column(
              children: [
                if (_dateRange != null)
                  Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${DateFormat('MMM dd, yyyy').format(_dateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_dateRange!.end)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            setState(() => _dateRange = null);
                            context.read<ReportBloc>().add(LoadReport());
                          },
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard('Income', state.totalIncome, colors.incomeLight, colors.income, currencySymbol),
                      _buildSummaryCard('Expense', state.totalExpense, colors.expenseLight, colors.expense, currencySymbol),
                      _buildSummaryCard('Withdrawn', state.totalWithdrawals, Colors.deepOrange.shade50, Colors.deepOrange, currencySymbol),
                    ],
                  ),
                ),
                // Savings health card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: alertColor.withValues(alpha:0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: alertColor, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Icon(_savingsAlertIcon(netSavings), color: alertColor, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Net Savings  •  ${_savingsAlertLabel(netSavings)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: alertColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '$currencySymbol ${netSavings.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: alertColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Income − Expense − Withdrawn',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                              Text(
                                '$currencySymbol${state.totalIncome.toStringAsFixed(0)} − $currencySymbol${state.totalExpense.toStringAsFixed(0)} − $currencySymbol${state.totalWithdrawals.toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Alert threshold legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildThresholdChip('≥ 30K', Colors.green.shade600, netSavings >= 30000),
                      _buildThresholdChip('15–30K', Colors.yellow.shade700, netSavings >= 15000 && netSavings < 30000),
                      _buildThresholdChip('10–15K', Colors.orange.shade700, netSavings >= 10000 && netSavings < 15000),
                      _buildThresholdChip('< 10K', Colors.red.shade700, netSavings < 10000),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: allRecords.isEmpty
                      ? const Center(child: Text('No records found.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                              columns: const [
                                DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: allRecords.map((r) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(DateFormat('MMM dd, yyyy').format(r['date'] as DateTime))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: r['color'],
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          r['type'],
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(r['category'])),
                                    DataCell(Text('$currencySymbol ${(r['amount'] as double).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            );
          } else if (state is ReportError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, Color bgColor, Color textColor, String currencySymbol) {
    return Expanded(
      child: Card(
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text(
                '$currencySymbol ${amount.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdChip(String label, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha:0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? color : Colors.grey.shade300, width: isActive ? 1.5 : 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? color : Colors.grey.shade500,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
