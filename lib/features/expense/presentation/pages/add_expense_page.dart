import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/app_validators.dart';
import '../bloc/expense_bloc.dart';
import '../../domain/entities/expense_category.dart';

class AddExpensePage extends StatefulWidget {
  final String? scannedAmount;
  const AddExpensePage({super.key, this.scannedAmount});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  ExpenseCategory _category = ExpenseCategory.other;
  String? _note;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.scannedAmount ?? '');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      context.read<ExpenseBloc>().add(AddExpenseEvent(
            amount: double.parse(_amountController.text),
            category: _category,
            note: _note,
            date: _date,
          ));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addExpense),
        centerTitle: true,
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputLabel(text: AppLocalizations.of(context)!.expenseAmount),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    prefixText: '₫ ',
                  ),
                  validator: AppValidators.price,
                ),
                const SizedBox(height: 24),
                InputLabel(text: AppLocalizations.of(context)!.expenseCategory),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _category,
                  items: ExpenseCategory.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.name));
                  }).toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 24),
                InputLabel(text: AppLocalizations.of(context)!.expenseNote),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'e.g. Mua bột mì'),
                  onSaved: (v) => _note = v,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  onPressed: _submit,
                  icon: Icons.save,
                  label: AppLocalizations.of(context)!.saveExpense,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
