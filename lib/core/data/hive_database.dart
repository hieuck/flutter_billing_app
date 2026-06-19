import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/expense/data/models/expense_model.dart';
import '../../features/expense/data/models/expense_category.g.dart';
import '../../features/billing/data/models/invoice_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String expensesBoxName = 'expenses';
  static const String invoicesBoxName = 'invoices';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());
    Hive.registerAdapter(ExpenseModelAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());
    Hive.registerAdapter(InvoiceModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName); // Generic box for simple key-value
    await Hive.openBox<ExpenseModel>(expensesBoxName);
    await Hive.openBox<InvoiceModel>(invoicesBoxName);
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<ExpenseModel> get expensesBox =>
      Hive.box<ExpenseModel>(expensesBoxName);
  static Box<InvoiceModel> get invoicesBox =>
      Hive.box<InvoiceModel>(invoicesBoxName);
}
