import 'package:flutter/material.dart';
import '../../../navigation/app_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/expense_tracker_app_colors.dart';
import '../../../core/widgets/amount_input_field.dart';
import '../../../core/widgets/category_chip_selector.dart';
import '../../../core/widgets/record_card.dart';
import '../domain/income_model.dart';
import 'income_bloc.dart';

class IncomeSourceScreen extends StatefulWidget {
  const IncomeSourceScreen({super.key});

  @override
  State<IncomeSourceScreen> createState() => _IncomeSourceScreenState();
}

class _IncomeSourceScreenState extends State<IncomeSourceScreen> {
  final List<String> _defaultCategories = ['Salary', 'Freelance', 'Consultancy'];

  @override
  void initState() {
    super.initState();
    context.read<IncomeBloc>().add(LoadIncomes());
  }

  void _showAddIncomeBottomSheet(BuildContext context, List<String> customCategories) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = _defaultCategories.first;
    DateTime selectedDate = DateTime.now();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Income',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    AmountInputField(controller: amountController),
                    const SizedBox(height: 16),
                    const Text('Category'),
                    const SizedBox(height: 8),
                    CategoryChipSelector(
                      defaultCategories: _defaultCategories,
                      customCategories: customCategories,
                      selectedCategory: selectedCategory,
                      selectedColor: Theme.of(context).extension<ExpenseTrackerAppColors>()!.income,
                      onCategorySelected: (category) {
                        setModalState(() {
                          selectedCategory = category;
                        });
                      },
                      onAddCustomCategory: () {
                        _showAddCustomCategoryDialog(ctx);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description (Optional)'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              setModalState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).extension<ExpenseTrackerAppColors>()!.income,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final amount = double.parse(amountController.text);
                            final income = IncomeModel(
                              amount: amount,
                              category: selectedCategory,
                              description: descriptionController.text.isEmpty
                                  ? null
                                  : descriptionController.text,
                              date: selectedDate,
                              createdAt: DateTime.now(),
                            );
                            this.context.read<IncomeBloc>().add(AddIncome(income));
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Save Income', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddCustomCategoryDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    showDialog(
      context: parentContext,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Custom Category'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Category Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  parentContext.read<IncomeBloc>().add(AddCustomCategory(controller.text.trim()));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ExpenseTrackerAppColors>()!;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(           // ← Add this
        title: const Text('Income'),
        backgroundColor: colors.income,
      ),
      body: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
          if (state is IncomeLoading || state is IncomeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is IncomeLoaded) {
            if (state.incomes.isEmpty) {
              return Center(
                child: Text(
                  'No incomes recorded yet.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              );
            }
            
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: colors.incomeLight,
                  child: Column(
                    children: [
                      const Text('Total Income', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '₹ ${state.totalIncome.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colors.income,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.incomes.length,
                    itemBuilder: (context, index) {
                      final item = state.incomes[index];
                      return RecordCard(
                        amount: item.amount,
                        category: item.category,
                        description: item.description,
                        date: item.date,
                        cardColor: Colors.white,
                        onDelete: () {
                          context.read<IncomeBloc>().add(DeleteIncome(item.id!));
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is IncomeError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<IncomeBloc, IncomeState>(
        builder: (context, state) {
          List<String> customCategories = [];
          if (state is IncomeLoaded) {
            customCategories = state.customCategories;
          }
          return FloatingActionButton(
            backgroundColor: colors.income,
            onPressed: () => _showAddIncomeBottomSheet(context, customCategories),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
