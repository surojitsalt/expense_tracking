import 'package:flutter/material.dart';
import '../../../navigation/app_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/expense_tracker_app_colors.dart';
import '../../../core/widgets/amount_input_field.dart';
import '../../../core/widgets/category_chip_selector.dart';
import '../../../core/widgets/record_card.dart';
import '../domain/expense_model.dart';
import 'expense_bloc.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  const ExpenseDetailsScreen({super.key});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final List<String> _defaultCategories = [
    'Transport', 'Food', 'Vegetable', 'Savings', 'Medicine', 'Doctor visit' 
  ];

  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(LoadExpenses());
  }

  void _showAddExpenseBottomSheet(BuildContext context, List<String> customCategories) {
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
                      'Add Expense',
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
                      selectedColor: Theme.of(context).extension<ExpenseTrackerAppColors>()!.expense,
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
                          backgroundColor: Theme.of(context).extension<ExpenseTrackerAppColors>()!.expense,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final amount = double.parse(amountController.text);
                            final expense = ExpenseModel(
                              amount: amount,
                              category: selectedCategory,
                              description: descriptionController.text.isEmpty
                                  ? null
                                  : descriptionController.text,
                              date: selectedDate,
                              createdAt: DateTime.now(),
                            );
                            this.context.read<ExpenseBloc>().add(AddExpense(expense));
                            Navigator.pop(ctx);
                          }
                        },
                        child: const Text('Save Expense', style: TextStyle(color: Colors.white)),
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
                  parentContext.read<ExpenseBloc>().add(AddCustomCategory(controller.text.trim()));
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
        title: const Text('Expense'),
        backgroundColor: colors.expense,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading || state is ExpenseInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return Center(
                child: Text(
                  'No expenses recorded yet.\nTap + to add one.',
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
                  color: colors.expenseLight,
                  child: Column(
                    children: [
                      const Text('Total Expense', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '₹ ${state.totalExpense.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final item = state.expenses[index];
                      return RecordCard(
                        amount: item.amount,
                        category: item.category,
                        description: item.description,
                        date: item.date,
                        cardColor: Colors.white,
                        onDelete: () {
                          context.read<ExpenseBloc>().add(DeleteExpense(item.id!));
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is ExpenseError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          List<String> customCategories = [];
          if (state is ExpenseLoaded) {
            customCategories = state.customCategories;
          }
          return FloatingActionButton(
            backgroundColor: colors.expense,
            onPressed: () => _showAddExpenseBottomSheet(context, customCategories),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
