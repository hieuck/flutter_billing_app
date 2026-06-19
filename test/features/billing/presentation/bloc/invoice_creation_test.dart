import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/billing/domain/entities/cart_item.dart';
import 'package:billing_app/features/billing/domain/repositories/invoice_repository.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/billing/domain/entities/invoice.dart';

class MockGetProductByBarcode extends Mock implements GetProductByBarcodeUseCase {}
class MockInvoiceRepository extends Mock implements InvoiceRepository {}

void main() {
  late BillingBloc bloc;
  late MockGetProductByBarcode mockGetBarcode;
  late MockInvoiceRepository mockInvoiceRepo;

  setUpAll(() {
    registerFallbackValue(Invoice(
      id: 'test',
      items: [],
      totalAmount: 0,
      totalCost: 0,
    ));
  });

  setUp(() {
    mockGetBarcode = MockGetProductByBarcode();
    mockInvoiceRepo = MockInvoiceRepository();
    bloc = BillingBloc(
      getProductByBarcodeUseCase: mockGetBarcode,
      invoiceRepository: mockInvoiceRepo,
    );
  });

  tearDown(() => bloc.close());

  blocTest<BillingBloc, BillingState>(
    'saves invoice on CompleteOrderEvent and clears cart',
    build: () {
      when(() => mockInvoiceRepo.saveInvoice(any()))
          .thenAnswer((_) async => const Right(null));
      return bloc;
    },
    seed: () => BillingState(
      cartItems: [
        CartItem(
          product: const Product(
            id: '1', name: 'Test', barcode: '123',
            price: 100.0, costPrice: 60.0,
          ),
          quantity: 2,
        ),
      ],
    ),
    act: (bloc) => bloc.add(const CompleteOrderEvent()),
    expect: () => [
      isA<BillingState>().having(
        (s) => s.cartItems, 'cart is empty', isEmpty),
    ],
    verify: (_) {
      verify(() => mockInvoiceRepo.saveInvoice(any())).called(1);
    },
  );
}
