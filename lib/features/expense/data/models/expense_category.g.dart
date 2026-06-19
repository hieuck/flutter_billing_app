// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:hive/hive.dart';
import 'package:billing_app/features/expense/domain/entities/expense_category.dart';

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 3;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.rawMaterials;
      case 1:
        return ExpenseCategory.packaging;
      case 2:
        return ExpenseCategory.shipping;
      case 3:
        return ExpenseCategory.labor;
      case 4:
        return ExpenseCategory.utilities;
      case 5:
        return ExpenseCategory.rent;
      case 6:
        return ExpenseCategory.marketing;
      case 7:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.other;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.rawMaterials:
        writer.writeByte(0);
        break;
      case ExpenseCategory.packaging:
        writer.writeByte(1);
        break;
      case ExpenseCategory.shipping:
        writer.writeByte(2);
        break;
      case ExpenseCategory.labor:
        writer.writeByte(3);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(4);
        break;
      case ExpenseCategory.rent:
        writer.writeByte(5);
        break;
      case ExpenseCategory.marketing:
        writer.writeByte(6);
        break;
      case ExpenseCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
