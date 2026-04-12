import 'package:flutter/material.dart';
import '../../../navigation/app_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/expense_tracker_app_colors.dart';
import '../bloc/report_bloc.dart';

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
      
      setState(() {
        _dateRange = range;
      });
      final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      context.read<ReportBloc>().add(FilterReportByDate(range.start, end));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ExpenseTrackerAppColors>()!;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.grey.shade800,
        actions: [
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
            final netBalance = state.totalIncome - state.totalExpense - state.totalSavings;

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
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard('Income', state.totalIncome, colors.incomeLight, colors.income),
                      _buildSummaryCard('Expense', state.totalExpense, colors.expenseLight, colors.expense),
                      _buildSummaryCard('Savings', state.totalSavings, colors.savingsLight, colors.savings),
                    ],
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: netBalance >= 0 ? colors.incomeLight : Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Net Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '₹ ${netBalance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: netBalance >= 0 ? colors.income : Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                                    DataCell(Text('₹ ${r['amount']}', style: const TextStyle(fontWeight: FontWeight.bold))),
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

  Widget _buildSummaryCard(String title, double amount, Color bgColor, Color textColor) {
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
                '₹ ${amount.toStringAsFixed(0)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
