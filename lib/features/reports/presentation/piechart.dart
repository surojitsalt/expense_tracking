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
  int _selectedTypeIndex = 0; // 0=Income, 1=Expense, 2=Savings
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
            Map<String, double> dataMap = {};
            Color baseColor;

            if (_selectedTypeIndex == 0) {
              baseColor = colors.income;
              for (var i in state.incomes) {
                dataMap[i.category] = (dataMap[i.category] ?? 0) + i.amount;
              }
            } else if (_selectedTypeIndex == 1) {
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

            final isDataEmpty = dataMap.isEmpty || dataMap.values.every((element) => element == 0);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Income')),
                      ButtonSegment(value: 1, label: Text('Expense')),
                      ButtonSegment(value: 2, label: Text('Savings')),
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
                Expanded(
                  child: isDataEmpty
                      ? const Center(child: Text('No data available for chart'))
                      : Column(
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
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, double> dataMap, Color baseColor) {
    if (dataMap.isEmpty) return [];
    
    final total = dataMap.values.reduce((a, b) => a + b);
    final entries = dataMap.entries.toList();
    
    return List.generate(entries.length, (i) {
      final isTouched = i == _touchedIndex;
      final fontSize = isTouched ? 20.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      final percentage = entries[i].value / total * 100;
      
      final hsl = HSLColor.fromColor(baseColor);
      final lightness = (0.2 + (i * 0.1)).clamp(0.2, 0.8);
      final sliceColor = hsl.withLightness(lightness).toColor();

      return PieChartSectionData(
        color: sliceColor,
        value: entries[i].value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
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
