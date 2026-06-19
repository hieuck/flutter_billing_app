import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/expense_bloc.dart';
import '../../domain/entities/expense_category.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseBloc>().add(const LoadExpensesByDateEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.expenses),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<ExpenseBloc>()
                .add(const LoadExpensesByDateEvent()),
          ),
        ],
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is ExpenseLoaded && state.expenses.isEmpty) {
            return const Center(child: Text('No expenses recorded yet'));
          }
          if (state is ExpenseLoaded) {
            final total = state.expenses.fold<double>(
                0, (sum, e) => sum + e.amount);
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${state.expenses.length} items',
                          style: const TextStyle(fontSize: 14)),
                      Text(
                        'Total: ${NumberFormat.currency(symbol: '₫', decimalDigits: 0).format(total)}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.expenses[index];
                      return Dismissible(
                        key: Key(expense.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => context
                            .read<ExpenseBloc>()
                            .add(DeleteExpenseEvent(expense.id)),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          leading: _categoryIcon(expense.category),
                          title: Text(_categoryLabel(expense.category),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(expense.note ?? ''),
                          trailing: Text(
                            NumberFormat.currency(
                                    symbol: '₫', decimalDigits: 0)
                                .format(expense.amount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/expenses/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _categoryIcon(ExpenseCategory category) {
    final icons = {
      ExpenseCategory.rawMaterials: Icons.shopping_cart,
      ExpenseCategory.packaging: Icons.inventory,
      ExpenseCategory.shipping: Icons.local_shipping,
      ExpenseCategory.labor: Icons.people,
      ExpenseCategory.utilities: Icons.bolt,
      ExpenseCategory.rent: Icons.home,
      ExpenseCategory.marketing: Icons.campaign,
      ExpenseCategory.other: Icons.more_horiz,
    };
    return CircleAvatar(
      backgroundColor: Colors.grey[200],
      child: Icon(icons[category] ?? Icons.more_horiz, size: 20),
    );
  }

  String _categoryLabel(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rawMaterials: return 'Raw Materials';
      case ExpenseCategory.packaging: return 'Packaging';
      case ExpenseCategory.shipping: return 'Shipping';
      case ExpenseCategory.labor: return 'Labor';
      case ExpenseCategory.utilities: return 'Utilities';
      case ExpenseCategory.rent: return 'Rent';
      case ExpenseCategory.marketing: return 'Marketing';
      case ExpenseCategory.other: return 'Other';
    }
  }
}
