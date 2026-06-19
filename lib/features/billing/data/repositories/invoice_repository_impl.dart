import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/features/billing/domain/entities/invoice.dart';
import 'package:billing_app/features/billing/domain/repositories/invoice_repository.dart';
import '../models/invoice_model.dart';

class InvoiceRepositoryImpl implements InvoiceRepository {
  @override
  Future<Either<Failure, void>> saveInvoice(Invoice invoice) async {
    try {
      final model = InvoiceModel.fromEntity(invoice);
      await HiveDatabase.invoicesBox.put(invoice.id, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoicesByDateRange(
      DateTime from, DateTime to) async {
    try {
      final all = HiveDatabase.invoicesBox.values
          .where((m) =>
              m.createdAt
                  .isAfter(from.subtract(const Duration(days: 1))) &&
              m.createdAt.isBefore(to.add(const Duration(days: 1))))
          .map((m) => m.toEntity([]))
          .toList();
      return Right(all);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getAllInvoices() async {
    try {
      final all = HiveDatabase.invoicesBox.values
          .map((m) => m.toEntity([]))
          .toList();
      return Right(all);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
