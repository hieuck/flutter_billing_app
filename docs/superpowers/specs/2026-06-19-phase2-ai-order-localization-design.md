# Phase 2 — AI Order & Localization

## Mục tiêu

Thêm 3 cách lên đơn bằng AI (Voice, Text paste, Photo) và bản địa hóa tiếng Việt.

---

## 1. AI Order Feature

### 1.1 Architecture

```
features/ai_order/
├── domain/
│   ├── entities/
│   │   └── parsed_order_item.dart
│   └── services/
│       └── order_parser.dart         # Interface
├── data/
│   └── services/
│       ├── order_parser_impl.dart    # Pattern matching + DB lookup
│       └── voice_listener.dart       # speech_to_text wrapper
└── presentation/
    ├── bloc/
    │   ├── ai_order_bloc.dart
    │   ├── ai_order_event.dart
    │   └── ai_order_state.dart
    └── pages/
        ├── ai_order_page.dart        # Main page với 3 tabs
        ├── voice_tab.dart
        ├── text_tab.dart
        ├── photo_tab.dart
        └── review_page.dart          # Confirm parsed items before adding to cart
```

### 1.2 ParsedOrderItem Entity

```dart
class ParsedOrderItem extends Equatable {
  final String productName;
  final double? quantity;
  final double confidence; // 0.0 - 1.0
  final String? matchedProductId;
}
```

### 1.3 TextParser — Shared Parsing Engine

Input: raw text (from voice transcript, pasted text, or OCR)
Output: `List<ParsedOrderItem>`

**Algorithm:**
1. Split text by newlines, commas, or Vietnamese delimiters ("và", "với")
2. For each segment, extract quantity patterns (số đứng trước hoặc sau tên)
3. Match product names against local DB (fuzzy match — contains, lowercase)
4. Calculate confidence score based on match quality

**Packages needed:** `speech_to_text` (voice), `google_mlkit_text_recognition` (đã có)

### 1.4 Voice Ordering

- `speech_to_text` listens continuously
- Real-time transcript → TextParser → live results
- User sees products being matched as they speak
- Tap "Add All" to add all matched items to cart

### 1.5 Text Paste Ordering

- User pastes text (long-press paste or from clipboard)
- TextParser processes → shows parsed results
- User can edit quantities before confirming

### 1.6 Photo Ordering

- Camera → `google_mlkit_text_recognition` → extract text
- Same TextParser for item extraction
- Review and confirm

### 1.7 AI Order Page Layout

```
┌──────────────────────────┐
│  AI Order                │
│  [Voice] [Text] [Photo]  │  ← 3 tabs
├──────────────────────────┤
│                          │
│  (Tab content)           │
│                          │
│  ─── Parsed Items ───    │
│  ☐ Trà sữa  x2   80.000 │
│  ☐ Cà phê  x1   20.000  │
│  (tap to edit/qty)       │
│                          │
├──────────────────────────┤
│  [Add Selected to Cart]  │
└──────────────────────────┘
```

### 1.8 Navigation

- New button on HomePage: "AI Order" (icon: smart_toy)
- Routes: `/ai-order` and `/ai-order/review`

---

## 2. Localization (Bản địa hóa)

### 2.1 Setup

- Package: `flutter_localizations` (SDK) + `intl` (đã có)
- Directory: `lib/l10n/`
- Files: `app_en.arb`, `app_vi.arb`
- Generate: `flutter gen-l10n`

### 2.2 ARB Files

**app_en.arb** (English — default):
```json
{
  "@@locale": "en",
  "appTitle": "Billing App",
  "scanBarcode": "Scan Barcode",
  "addProduct": "Add Product",
  "checkout": "Checkout",
  "total": "Total",
  "printReceipt": "Print Receipt",
  "settings": "Settings",
  "products": "Products",
  "expenses": "Expenses",
  "dashboard": "Dashboard",
  "aiOrder": "AI Order",
  "voice": "Voice",
  "text": "Text",
  "photo": "Photo",
  "addToCart": "Add to Cart",
  "confirm": "Confirm",
  "cancel": "Cancel",
  "save": "Save",
  "delete": "Delete",
  "search": "Search",
  "noData": "No data",
  "error": "Error",
  "success": "Success",
  "loading": "Loading..."
}
```

**app_vi.arb** (Vietnamese):
```json
{
  "@@locale": "vi",
  "appTitle": "Billing App",
  "scanBarcode": "Quét mã vạch",
  "addProduct": "Thêm sản phẩm",
  "checkout": "Thanh toán",
  "total": "Tổng cộng",
  "printReceipt": "In hóa đơn",
  "settings": "Cài đặt",
  "products": "Sản phẩm",
  "expenses": "Chi phí",
  "dashboard": "Báo cáo",
  "aiOrder": "AI Lên đơn",
  "voice": "Giọng nói",
  "text": "Văn bản",
  "photo": "Ảnh chụp",
  "addToCart": "Thêm vào giỏ",
  "confirm": "Xác nhận",
  "cancel": "Hủy",
  "save": "Lưu",
  "delete": "Xóa",
  "search": "Tìm kiếm",
  "noData": "Không có dữ liệu",
  "error": "Lỗi",
  "success": "Thành công",
  "loading": "Đang tải..."
}
```

### 2.3 Integration

- `MaterialApp` → add `localizationsDelegates`, `supportedLocales`
- Wrap all hardcoded strings in existing widgets with `AppLocalizations.of(context)!.xxx`
- Affected files: home_page, settings_page, product_list_page, add_product_page, edit_product_page, expense_list_page, add_expense_page, report_page, checkout_page, scanner_page, shop_details_page

---

## 3. Dependencies

- `flutter_localizations` (SDK, thêm vào pubspec.yaml)
- `speech_to_text: ^6.6.0` (mới)
- `intl` (đã có)
