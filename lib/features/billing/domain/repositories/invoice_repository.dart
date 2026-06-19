import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import '../entities/invoice.dart';

abstract class InvoiceRepository {
  Future<Either<Failure, void>> saveInvoice(Invoice invoice);
  Future<Either<Failure, List<Invoice>>> getInvoicesByDateRange(
      DateTime from, DateTime to);
  Future<Either<Failure, List<Invoice>>> getAllInvoices();
}
