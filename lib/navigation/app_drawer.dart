import 'package:flutter/material.dart';
import '../core/theme/expense_tracker_app_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<ExpenseTrackerAppColors>()!;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.income, colors.expense],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Expense Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.attach_money, color: colors.income),
            title: const Text('Income'),
            selected: currentRoute == '/income' || currentRoute == null || currentRoute == '/',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != '/income' && currentRoute != '/') {
                Navigator.pushReplacementNamed(context, '/income');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.credit_card, color: colors.expense),
            title: const Text('Expense'),
            selected: currentRoute == '/expense',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != '/expense') {
                Navigator.pushReplacementNamed(context, '/expense');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.account_balance, color: colors.savings),
            title: const Text('Savings'),
            selected: currentRoute == '/savings',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != '/savings') {
                Navigator.pushReplacementNamed(context, '/savings');
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.grey),
            title: const Text('Reports'),
            selected: currentRoute == '/reports',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != '/reports') {
                Navigator.pushReplacementNamed(context, '/reports');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.pie_chart, color: Colors.grey),
            title: const Text('Distribution'),
            selected: currentRoute == '/chart',
            onTap: () {
              Navigator.pop(context);
              if (currentRoute != '/chart') {
                Navigator.pushReplacementNamed(context, '/chart');
              }
            },
          ),
        ],
      ),
    );
  }
}
