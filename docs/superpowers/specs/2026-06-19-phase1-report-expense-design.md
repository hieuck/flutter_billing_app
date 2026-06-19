# Phase 1 — Báo cáo & Thu chi

## Mục tiêu

Nâng cấp POS billing app hiện tại lên giống Knote: thêm tính năng quản lý chi phí (expense) và báo cáo doanh thu/lợi nhuận (reporting).

## 1. Data Model Changes

### Product — Thêm costPrice

```
Product (hiện tại) → thêm:
  - costPrice (double?): giá vốn nhập vào
  - default: null (tương thích ngược)
```

**File:** `features/product/domain/entities/product.dart`
**Hive:** `ProductModel` cần thêm `@HiveField(5)` cho `costPrice` (typeAdapter typeId=0)

### Expense (mới)

```
Expense:
  - id: String
  - amount: double
  - category: ExpenseCategory
  - note: String (optional)
  - imagePath: String? (path to OCR'd bill photo)
  - date: DateTime
  - createdAt: DateTime
  - updatedAt: DateTime
```

**File:** `features/expense/domain/entities/expense.dart`
**Hive:** `ExpenseModel` typeId=2, box name: `expenses`

### ExpenseCategory (enum)

```
ExpenseCategory:
  - rawMaterials (nguyên vật liệu)
  - packaging (bao bì)
  - shipping (vận chuyển)
  - labor (nhân công)
  - utilities (điện nước)
  - rent (mặt bằng)
  - marketing (quảng cáo)
  - other (khác)
```

### Invoice (mới — lưu lịch sử đơn hàng)

```
Invoice:
  - id: String
  - items: List<CartItem>
  - subtotal: double
  - discount: double
  - totalAmount: double
  - totalCost: double (tổng giá vốn)
  - profit: double (= totalAmount - totalCost)
  - createdAt: DateTime
```

**File:** `features/billing/domain/entities/invoice.dart`
**Hive:** `InvoiceModel` typeId=3, box name: `invoices`

Invoice được tạo mỗi khi người dùng nhấn "Print Receipt" (hoặc "Hoàn tất đơn hàng").

## 2. Expense Feature Module

```
features/expense/
├── data/
│   ├── models/
│   │   └── expense_model.dart          # Hive @HiveType typeId=2
│   ├── repositories/
│   │   └── expense_repository_impl.dart # HiveDatabase.expensesBox
├── domain/
│   ├── entities/
│   │   └── expense.dart
│   ├── repositories/
│   │   └── expense_repository.dart
│   └── usecases/
│       └── expense_usecases.dart       # AddExpense, GetExpensesByDate, GetAllExpenses, DeleteExpense
└── presentation/
    ├── bloc/
    │   ├── expense_bloc.dart
    │   ├── expense_event.dart
    │   └── expense_state.dart
    └── pages/
        ├── expense_list_page.dart      # Danh sách chi phí + filter ngày/tháng
        ├── add_expense_page.dart       # Form nhập tay: amount, category, note, date
        └── scan_expense_page.dart      # Chụp ảnh hóa đơn → OCR → tự động điền
```

### OCR Implementation

- **Package:** `google_mlkit_text_recognition`
- **Flow:** Chụp ảnh → ML Kit nhận diện text → parse tìm số tiền (pattern: số thập phân) → tự điền vào form
- **Local processing:** Không cần internet, chạy hoàn toàn trên device

## 3. Invoice & Order History

**File hiện tại cần sửa:** `features/billing/presentation/bloc/billing_bloc.dart`

Khi `PrintReceiptEvent` được gọi (hoặc thêm `CompleteOrderEvent` mới):
1. Tạo `Invoice` từ `cartItems` hiện tại
2. Lưu vào Hive `invoices` box
3. Clear cart
4. Navigate về home hoặc checkout success page

**File mới:**
```
features/billing/data/models/invoice_model.dart  # Hive typeId=3
features/billing/data/repositories/invoice_repository_impl.dart
features/billing/domain/repositories/invoice_repository.dart
features/billing/domain/entities/invoice.dart
```

## 4. Report Dashboard

**Vị trí:** Màn hình Dashboard mới, thay thế hoặc bổ sung vào HomePage

### Layout

```
┌─────────────────────────────┐
│  TỔNG QUAN (cards)          │
│  [Doanh thu] [Chi phí] [Lãi]│
├─────────────────────────────┤
│  BIỂU ĐỒ DOANH THU (Bar)    │
│  ██ ██ ██ ██ ██ ██ ██      │
│  T2 T3 T4 T5 T6 T7 CN       │
├─────────────────────────────┤
│  CHI PHÍ THEO DM (Pie)      │
│   ┌─┐  Nguyên liệu: 40%     │
│   │/│  Nhân công: 25%       │
│   └─┘  ...                   │
├─────────────────────────────┤
│  TOP 5 SẢN PHẨM (Bar)       │
│  ████████ Trà sữe           │
│  ██████    Cà phê           │
│  ████      ...               │
├─────────────────────────────┤
│  BỘ LỌC: [Hôm nay][Tuần]   │
│          [Tháng][Tùy chỉnh] │
└─────────────────────────────┘
```

### Data Aggregation

- **Revenue:** `Invoice.totalAmount` grouped by date
- **Cost (expense):** `Expense.amount` grouped by date/category
- **Gross profit:** `(Invoice.totalAmount - Invoice.totalCost)` per period
- **Net profit:** `Gross profit - Total expense` per period
- **Top products:** Aggregate `Invoice.items` by product, sort by quantity/amount

### Dependencies

- `fl_chart: ^0.69.0` — biểu đồ Bar, Pie
- `intl: ^0.19.0` (đã có) — format ngày, số tiền

### Navigation

Thêm vào bottom nav hoặc drawer:
- Home (scanner + cart)
- Dashboard (mới)
- Products
- Settings

## 5. Service Locator Registration

`core/service_locator.dart` — thêm:
- `ExpenseRepositoryImpl` (lazySingleton)
- `AddExpenseUseCase`, `GetExpensesByDateUseCase`, etc.
- `ExpenseBloc` (factory)
- `InvoiceRepositoryImpl` (lazySingleton)
- `InvoiceBloc` hoặc tích hợp vào `BillingBloc`

## 6. Hive Database

`core/data/hive_database.dart` — thêm:
- `Box<ExpenseModel>` — box name: `expenses`
- `Box<InvoiceModel>` — box name: `invoices`
- Mở box mới trong `HiveDatabase.init()`
- Register adapter: `ExpenseModelAdapter`, `InvoiceModelAdapter`

## 7. Testing Strategy (TDD)

### Unit Tests
- `ExpenseUsecases`: add/get/delete expense
- `InvoiceRepository`: create/get invoices by date range
- `ReportAggregator`: tính đúng revenue, expense, profit, top products
- `OCRParser`: parse số tiền từ text OCR

### Bloc Tests
- `ExpenseBloc`: add expense, load list, filter by date
- `BillingBloc` (mở rộng): complete order → tạo Invoice → clear cart

### Widget Tests
- `AddExpensePage`: form validation, submit
- `ReportPage`: render đúng biểu đồ với mock data

### Integration Tests
- Full flow: scan product → add to cart → complete → check invoice in report
