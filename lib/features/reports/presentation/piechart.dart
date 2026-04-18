import 'package:fl_chart/fl_chart.dart';
import '../../../navigation/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/expense_tracker_app_colors.dart';
import '../bloc/report_bloc.dart';

class PieChartScreen extends StatefulWidget {
  const PieChartScreen({super.key});

  @override
  State<PieChartScreen> createState() => _PieChartScreenState();
}

class _PieChartScreenState extends State<PieChartScreen> {
  // 0=Summary, 1=Income, 2=Expense, 3=Savings
  int _selectedTypeIndex = 0;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(LoadReport());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ExpenseTrackerAppColors>()!;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Distribution'),
        backgroundColor: Colors.grey.shade800,
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading || state is ReportInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportLoaded) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('Summary')),
                        ButtonSegment(value: 1, label: Text('Income')),
                        ButtonSegment(value: 2, label: Text('Expense')),
                        ButtonSegment(value: 3, label: Text('Savings')),
                      ],
                      selected: {_selectedTypeIndex},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() {
                          _selectedTypeIndex = newSelection.first;
                          _touchedIndex = -1;
                        });
                      },
                    ),
                  ),
                ),
                if (_selectedTypeIndex == 0)
                  Expanded(child: _buildSummaryChart(state, colors))
                else
                  Expanded(child: _buildCategoryChart(state, colors)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummaryChart(ReportLoaded state, ExpenseTrackerAppColors colors) {
    final totalIncome = state.totalIncome;
    final totalExpense = state.totalExpense;
    final netSavings = state.netSavings;
    final inHandCash = state.inHandCash;

    if (totalIncome == 0) {
      return const Center(child: Text('No income data available'));
    }

    final summaryData = <_SummarySlice>[
      _SummarySlice('Expense', totalExpense, colors.expense),
      _SummarySlice('Savings', netSavings > 0 ? netSavings : 0, colors.savings),
      _SummarySlice('In-hand Cash', inHandCash > 0 ? inHandCash : 0, Colors.blueGrey),
    ].where((s) => s.value > 0).toList();

    if (summaryData.isEmpty) {
      return const Center(child: Text('No data to display'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'From Total Income  ₹ ${totalIncome.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 48,
              sections: List.generate(summaryData.length, (i) {
                final isTouched = i == _touchedIndex;
                final pct = summaryData[i].value / totalIncome * 100;
                return PieChartSectionData(
                  color: summaryData[i].color,
                  value: summaryData[i].value,
                  title: '${pct.toStringAsFixed(1)}%',
                  radius: isTouched ? 115.0 : 100.0,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 16.0 : 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: summaryData.map((slice) {
              final pct = slice.value / totalIncome * 100;
              return ListTile(
                leading: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: slice.color, borderRadius: BorderRadius.circular(3)),
                ),
                title: Text(slice.label),
                trailing: Text(
                  '₹ ${slice.value.toStringAsFixed(2)}  (${pct.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(ReportLoaded state, ExpenseTrackerAppColors colors) {
    Map<String, double> dataMap = {};
    Color baseColor;

    if (_selectedTypeIndex == 1) {
      baseColor = colors.income;
      for (var i in state.incomes) {
        dataMap[i.category] = (dataMap[i.category] ?? 0) + i.amount;
      }
    } else if (_selectedTypeIndex == 2) {
      baseColor = colors.expense;
      for (var e in state.expenses) {
        dataMap[e.category] = (dataMap[e.category] ?? 0) + e.amount;
      }
    } else {
      baseColor = colors.savings;
      for (var s in state.savings) {
        dataMap[s.category] = (dataMap[s.category] ?? 0) + s.amount;
      }
    }

    final isDataEmpty = dataMap.isEmpty || dataMap.values.every((v) => v == 0);

    if (isDataEmpty) {
      return const Center(child: Text('No data available for chart'));
    }

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _generateSections(dataMap, baseColor),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildLegend(dataMap, baseColor),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, double> dataMap, Color baseColor) {
    if (dataMap.isEmpty) return [];
    final total = dataMap.values.reduce((a, b) => a + b);
    final entries = dataMap.entries.toList();

    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final percentage = entries[i].value / total * 100;
      final hsl = HSLColor.fromColor(baseColor);
      final lightness = (0.2 + (i * 0.1)).clamp(0.2, 0.8);
      final sliceColor = hsl.withLightness(lightness).toColor();

      return PieChartSectionData(
        color: sliceColor,
        value: entries[i].value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isTouched ? 110.0 : 100.0,
        titleStyle: TextStyle(
          fontSize: isTouched ? 20.0 : 12.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  Widget _buildLegend(Map<String, double> dataMap, Color baseColor) {
    final entries = dataMap.entries.toList();
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final hsl = HSLColor.fromColor(baseColor);
        final lightness = (0.2 + (i * 0.1)).clamp(0.2, 0.8);
        final sliceColor = hsl.withLightness(lightness).toColor();

        return ListTile(
          leading: Container(width: 16, height: 16, color: sliceColor),
          title: Text(entries[i].key),
          trailing: Text(
            '₹ ${entries[i].value.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}

class _SummarySlice {
  final String label;
  final double value;
  final Color color;
  const _SummarySlice(this.label, this.value, this.color);
}
