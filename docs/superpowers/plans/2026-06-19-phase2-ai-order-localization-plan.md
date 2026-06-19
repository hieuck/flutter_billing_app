# Phase 2 — AI Order & Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add AI-powered ordering (voice, text paste, photo) and Vietnamese localization to the POS billing app.

**Architecture:** New `ai_order` feature module (Clean Architecture) with a shared `TextParser` engine. Localization via `flutter_localizations` + ARB files.

**Tech Stack:** Flutter, flutter_bloc, speech_to_text (new), google_mlkit_text_recognition (added), flutter_localizations, intl

---

## PART A: AI ORDER

### Task A1: Add speech_to_text dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add dependency**

Add to `dependencies`:
```yaml
  speech_to_text: ^6.6.0
```

- [ ] **Step 2: Install and commit**

```bash
cd E:\GitHub\flutter_billing_app && flutter pub get && git add pubspec.yaml pubspec.lock && git commit -m "chore: add speech_to_text for voice ordering"
```

---

### Task A2: Create ParsedOrderItem entity and TextParser

**Files:**
- Create: `lib/features/ai_order/domain/entities/parsed_order_item.dart`
- Create: `lib/features/ai_order/domain/services/order_parser.dart`
- Create: `lib/features/ai_order/data/services/order_parser_impl.dart`
- Create: `test/features/ai_order/domain/entities/parsed_order_item_test.dart`
- Create: `test/features/ai_order/data/services/order_parser_impl_test.dart`

- [ ] **Step 1: Write failing test for entity**

`test/features/ai_order/domain/entities/parsed_order_item_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/ai_order/domain/entities/parsed_order_item.dart';

void main() {
  group('ParsedOrderItem', () {
    test('creates item with all fields', () {
      final item = ParsedOrderItem(
        productName: 'Trà sữa',
        quantity: 2,
        confidence: 0.95,
        matchedProductId: '123',
      );
      expect(item.productName, 'Trà sữa');
      expect(item.quantity, 2);
      expect(item.confidence, 0.95);
    });

    test('quantity defaults to 1', () {
      final item = ParsedOrderItem(
        productName: 'Cà phê',
        confidence: 0.8,
      );
      expect(item.quantity, 1);
    });

    test('props includes fields', () {
      final item = ParsedOrderItem(productName: 'Test', confidence: 1.0);
      expect(item.props.contains('Test'), isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test**

```bash
cd E:\GitHub\flutter_billing_app && flutter test test/features/ai_order/domain/entities/parsed_order_item_test.dart
```
Expected: FAIL

- [ ] **Step 3: Create entity**

`lib/features/ai_order/domain/entities/parsed_order_item.dart`:
```dart
import 'package:equatable/equatable.dart';

class ParsedOrderItem extends Equatable {
  final String productName;
  final double quantity;
  final double confidence;
  final String? matchedProductId;

  const ParsedOrderItem({
    required this.productName,
    this.quantity = 1,
    required this.confidence,
    this.matchedProductId,
  });

  @override
  List<Object?> get props =>
      [productName, quantity, confidence, matchedProductId];
}
```

- [ ] **Step 4: Run test**

```bash
cd E:\GitHub\flutter_billing_app && flutter test test/features/ai_order/domain/entities/parsed_order_item_test.dart
```
Expected: PASS

- [ ] **Step 5: Write failing test for OrderParser**

`test/features/ai_order/data/services/order_parser_impl_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/features/ai_order/data/services/order_parser_impl.dart';

void main() {
  late OrderParserImpl parser;

  setUp(() {
    parser = OrderParserImpl([]);
  });

  group('parse', () {
    test('parses single product name', () {
      parser = OrderParserImpl(['Trà sữa', 'Cà phê']);
      final result = parser.parse('Trà sữa');
      expect(result.length, 1);
      expect(result.first.productName, 'Trà sữa');
      expect(result.first.quantity, 1);
    });

    test('parses product with quantity prefix', () {
      parser = OrderParserImpl(['Trà sữa']);
      final result = parser.parse('2 Trà sữa');
      expect(result.length, 1);
      expect(result.first.productName, 'Trà sữa');
      expect(result.first.quantity, 2);
    });

    test('parses multiple lines', () {
      parser = OrderParserImpl(['Trà sữa', 'Cà phê']);
      final result = parser.parse('2 Trà sữa\n1 Cà phê');
      expect(result.length, 2);
      expect(result.first.productName, 'Trà sữa');
      expect(result.first.quantity, 2);
      expect(result.last.productName, 'Cà phê');
    });

    test('returns empty list when no match', () {
      parser = OrderParserImpl(['Trà sữa']);
      final result = parser.parse('Bánh mì');
      expect(result, isEmpty);
    });
  });
}
```

- [ ] **Step 6: Run test**

```bash
cd E:\GitHub\flutter_billing_app && flutter test test/features/ai_order/data/services/order_parser_impl_test.dart
```
Expected: FAIL

- [ ] **Step 7: Create OrderParser interface**

`lib/features/ai_order/domain/services/order_parser.dart`:
```dart
import '../entities/parsed_order_item.dart';

abstract class OrderParser {
  List<ParsedOrderItem> parse(String rawText);
}
```

- [ ] **Step 8: Create OrderParserImpl**

`lib/features/ai_order/data/services/order_parser_impl.dart`:
```dart
import 'package:billing_app/features/ai_order/domain/entities/parsed_order_item.dart';
import 'package:billing_app/features/ai_order/domain/services/order_parser.dart';

class OrderParserImpl implements OrderParser {
  final List<String> knownProductNames;

  OrderParserImpl(this.knownProductNames);

  @override
  List<ParsedOrderItem> parse(String rawText) {
    if (rawText.trim().isEmpty) return [];

    final results = <ParsedOrderItem>[];
    final lines = rawText
        .replaceAll(',', '\n')
        .replaceAll(' và ', '\n')
        .replaceAll(' với ', '\n')
        .split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parsed = _parseLine(trimmed);
      if (parsed != null) results.add(parsed);
    }

    return results;
  }

  ParsedOrderItem? _parseLine(String line) {
    final quantityRegex = RegExp(r'^(\d+)\s*(.+)$');
    double quantity = 1;
    String searchName = line;

    final match = quantityRegex.firstMatch(line);
    if (match != null) {
      quantity = double.parse(match.group(1)!);
      searchName = match.group(2)!.trim();
    }

    for (final known in knownProductNames) {
      if (searchName.toLowerCase().contains(known.toLowerCase()) ||
          known.toLowerCase().contains(searchName.toLowerCase())) {
        return ParsedOrderItem(
          productName: known,
          quantity: quantity,
          confidence: searchName.toLowerCase() == known.toLowerCase() ? 1.0 : 0.8,
        );
      }
    }

    return null;
  }
}
```

- [ ] **Step 9: Run tests**

```bash
cd E:\GitHub\flutter_billing_app && flutter test test/features/ai_order/data/services/order_parser_impl_test.dart
```
Expected: PASS

- [ ] **Step 10: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: add ParsedOrderItem entity and TextParser engine"
```

---

### Task A3: Create AiOrderBloc

**Files:**
- Create: `lib/features/ai_order/presentation/bloc/ai_order_event.dart`
- Create: `lib/features/ai_order/presentation/bloc/ai_order_state.dart`
- Create: `lib/features/ai_order/presentation/bloc/ai_order_bloc.dart`
- Create: `test/features/ai_order/presentation/bloc/ai_order_bloc_test.dart`

- [ ] **Step 1: Create events**

`lib/features/ai_order/presentation/bloc/ai_order_event.dart`:
```dart
import 'package:equatable/equatable.dart';

abstract class AiOrderEvent extends Equatable {
  const AiOrderEvent();
  @override
  List<Object?> get props => [];
}

class ParseTextEvent extends AiOrderEvent {
  final String rawText;
  const ParseTextEvent(this.rawText);
  @override
  List<Object?> get props => [rawText];
}

class ConfirmItemsEvent extends AiOrderEvent {}

class ClearResultsEvent extends AiOrderEvent {}
```

- [ ] **Step 2: Create states**

`lib/features/ai_order/presentation/bloc/ai_order_state.dart`:
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/parsed_order_item.dart';

abstract class AiOrderState extends Equatable {
  const AiOrderState();
  @override
  List<Object?> get props => [];
}

class AiOrderInitial extends AiOrderState {}

class AiOrderLoading extends AiOrderState {}

class AiOrderParsed extends AiOrderState {
  final List<ParsedOrderItem> items;
  final String sourceText;
  const AiOrderParsed({required this.items, required this.sourceText});
  @override
  List<Object?> get props => [items, sourceText];
}

class AiOrderConfirmed extends AiOrderState {
  final List<ParsedOrderItem> items;
  const AiOrderConfirmed(this.items);
  @override
  List<Object?> get props => [items];
}

class AiOrderError extends AiOrderState {
  final String message;
  const AiOrderError(this.message);
  @override
  List<Object?> get props => [message];
}
```

- [ ] **Step 3: Create Bloc**

`lib/features/ai_order/presentation/bloc/ai_order_bloc.dart`:
```dart
import 'package:bloc/bloc.dart';
import 'dart:math';
import '../../domain/entities/parsed_order_item.dart';
import '../../domain/services/order_parser.dart';
import '../../../../core/data/hive_database.dart';
import '../../../product/data/models/product_model.dart';

part 'ai_order_event.dart';
part 'ai_order_state.dart';

class AiOrderBloc extends Bloc<AiOrderEvent, AiOrderState> {
  final OrderParser parser;
  List<ParsedOrderItem> _lastParsedItems = [];

  AiOrderBloc({required this.parser}) : super(AiOrderInitial()) {
    on<ParseTextEvent>(_onParseText);
    on<ConfirmItemsEvent>(_onConfirm);
    on<ClearResultsEvent>((_, emit) => emit(AiOrderInitial()));
  }

  Future<void> _onParseText(
      ParseTextEvent event, Emitter<AiOrderState> emit) async {
    emit(AiOrderLoading());
    try {
      final items = parser.parse(event.rawText);
      _lastParsedItems = items;
      if (items.isEmpty) {
        emit(const AiOrderError('No products found in text'));
      } else {
        emit(AiOrderParsed(items: items, sourceText: event.rawText));
      }
    } catch (e) {
      emit(AiOrderError('Parse error: $e'));
    }
  }

  void _onConfirm(ConfirmItemsEvent event, Emitter<AiOrderState> emit) {
    if (_lastParsedItems.isNotEmpty) {
      emit(AiOrderConfirmed(_lastParsedItems));
    }
  }
}
```

- [ ] **Step 4: Create test**

`test/features/ai_order/presentation/bloc/ai_order_bloc_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billing_app/features/ai_order/domain/services/order_parser.dart';
import 'package:billing_app/features/ai_order/domain/entities/parsed_order_item.dart';
import 'package:billing_app/features/ai_order/presentation/bloc/ai_order_bloc.dart';

class MockParser extends Mock implements OrderParser {}

void main() {
  late AiOrderBloc bloc;
  late MockParser mockParser;

  setUp(() {
    mockParser = MockParser();
    bloc = AiOrderBloc(parser: mockParser);
  });

  tearDown(() => bloc.close());

  blocTest<AiOrderBloc, AiOrderState>(
    'emits [loading, parsed] on successful parse',
    build: () {
      when(() => mockParser.parse('Trà sữa'))
          .thenReturn([ParsedOrderItem(productName: 'Trà sữa', confidence: 1.0)]);
      return bloc;
    },
    act: (bloc) => bloc.add(const ParseTextEvent('Trà sữa')),
    expect: () => [
      AiOrderLoading(),
      isA<AiOrderParsed>(),
    ],
  );

  blocTest<AiOrderBloc, AiOrderState>(
    'emits [loading, error] when no products found',
    build: () {
      when(() => mockParser.parse('xyz')).thenReturn([]);
      return bloc;
    },
    act: (bloc) => bloc.add(const ParseTextEvent('xyz')),
    expect: () => [
      AiOrderLoading(),
      isA<AiOrderError>(),
    ],
  );
}
```

- [ ] **Step 5: Run tests**

```bash
cd E:\GitHub\flutter_billing_app && flutter test test/features/ai_order/presentation/bloc/ai_order_bloc_test.dart
```
Expected: PASS

- [ ] **Step 6: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: add AiOrderBloc with parse/confirm/clear"
```

---

### Task A4: Create AI Order UI pages

**Files:**
- Create: `lib/features/ai_order/presentation/pages/ai_order_page.dart`
- Create: `lib/features/ai_order/presentation/pages/voice_tab.dart`
- Create: `lib/features/ai_order/presentation/pages/text_tab.dart`
- Create: `lib/features/ai_order/presentation/pages/photo_tab.dart`
- Modify: `lib/config/routes/app_routes.dart`

- [ ] **Step 1: Create ai_order_page.dart**

`lib/features/ai_order/presentation/pages/ai_order_page.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/ai_order_bloc.dart';
import '../../domain/entities/parsed_order_item.dart';
import '../../../../core/widgets/primary_button.dart';
import 'voice_tab.dart';
import 'text_tab.dart';
import 'photo_tab.dart';

class AiOrderPage extends StatelessWidget {
  const AiOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Order'), centerTitle: true),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.mic), text: 'Voice'),
                Tab(icon: Icon(Icons.text_fields), text: 'Text'),
                Tab(icon: Icon(Icons.camera_alt), text: 'Photo'),
              ],
            ),
            Expanded(
              child: BlocConsumer<AiOrderBloc, AiOrderState>(
                listener: (context, state) {
                  if (state is AiOrderConfirmed) {
                    context.pop(state.items);
                  }
                },
                builder: (context, state) {
                  return Stack(
                    children: [
                      TabBarView(
                        children: [
                          VoiceTab(),
                          TextTab(),
                          PhotoTab(),
                        ],
                      ),
                      if (state is AiOrderParsed)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: _buildParsedBanner(context, state),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedBanner(BuildContext context, AiOrderParsed state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Found ${state.items.length} items',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          PrimaryButton(
            onPressed: () => context.read<AiOrderBloc>().add(ConfirmItemsEvent()),
            icon: Icons.add_shopping_cart,
            label: 'Add to Cart',
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Create voice_tab.dart**

`lib/features/ai_order/presentation/pages/voice_tab.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_order_bloc.dart';

class VoiceTab extends StatefulWidget {
  @override
  State<VoiceTab> createState() => _VoiceTabState();
}

class _VoiceTabState extends State<VoiceTab> {
  bool _isListening = false;
  String _transcript = '';

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() { _isListening = true; _transcript = ''; });
    // speech_to_text integration will go here
    // For now, simulate with a demo
  }

  void _stopListening() {
    setState(() => _isListening = false);
    if (_transcript.isNotEmpty) {
      context.read<AiOrderBloc>().add(ParseTextEvent(_transcript));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTapDown: (_) => _startListening(),
            onTapUp: (_) => _stopListening(),
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? Colors.red : Colors.grey[300],
              ),
              child: Icon(
                Icons.mic,
                size: 60,
                color: _isListening ? Colors.white : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(_isListening ? 'Listening...' : 'Tap and hold to speak',
              style: const TextStyle(fontSize: 16)),
          if (_transcript.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(_transcript, style: const TextStyle(fontSize: 18)),
          ],
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Create text_tab.dart**

`lib/features/ai_order/presentation/pages/text_tab.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../bloc/ai_order_bloc.dart';

class TextTab extends StatefulWidget {
  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parseText() {
    if (_controller.text.trim().isNotEmpty) {
      context.read<AiOrderBloc>().add(ParseTextEvent(_controller.text));
    }
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!;
      _parseText();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Paste or type order here...',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.content_paste),
                onPressed: _pasteFromClipboard,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _parseText,
            icon: Icon(Icons.search),
            label: Text('Parse Order'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create photo_tab.dart**

`lib/features/ai_order/presentation/pages/photo_tab.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_order_bloc.dart';

class PhotoTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          const Text('Take a photo of a menu or order list',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Integrate with google_mlkit_text_recognition
              context.read<AiOrderBloc>().add(
                const ParseTextEvent('Demo item from photo'),
              );
            },
            icon: const Icon(Icons.camera),
            label: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Add routes**

Add to `lib/config/routes/app_routes.dart`:
```dart
import '../../features/ai_order/presentation/pages/ai_order_page.dart';

GoRoute(
  path: 'ai-order',
  builder: (context, state) => const AiOrderPage(),
),
```

Add inside `GoRoute(path: '/')` routes list:
```dart
GoRoute(
  path: 'ai-order',
  builder: (context, state) => const AiOrderPage(),
),
```

- [ ] **Step 6: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: add AI Order UI pages with voice/text/photo tabs"
```

---

### Task A5: Register AI Order DI and wire up HomePage

**Files:**
- Modify: `lib/core/service_locator.dart`
- Modify: `lib/main.dart`
- Modify: `lib/features/billing/presentation/pages/home_page.dart`

- [ ] **Step 1: Register in service_locator**

Add to `lib/core/service_locator.dart`:
```dart
import '../../features/ai_order/domain/services/order_parser.dart';
import '../../features/ai_order/data/services/order_parser_impl.dart';
import '../../features/ai_order/presentation/bloc/ai_order_bloc.dart';
```

Add:
```dart
  // Features - AI Order
  sl.registerLazySingleton<OrderParser>(
    () => OrderParserImpl(
      sl<ProductRepository>() is ProductRepositoryImpl
          ? [] // Will be populated lazily
          : [],
    ),
  );
  sl.registerFactory(
    () => AiOrderBloc(parser: sl()),
  );
```

- [ ] **Step 2: Add AiOrderBloc to main.dart**

Add import and provider:
```dart
import 'features/ai_order/presentation/bloc/ai_order_bloc.dart';

BlocProvider<AiOrderBloc>(
  create: (context) => di.sl<AiOrderBloc>(),
),
```

- [ ] **Step 3: Add AI Order button to home_page.dart**

Find the area with scanner/camera and add a button before the floating action:
```dart
ElevatedButton.icon(
  onPressed: () async {
    final result = await context.push<List<ParsedOrderItem>>('/ai-order');
    if (result != null && mounted) {
      for (final item in result) {
        // Add each parsed item to cart by looking up product
        // (will be refined later)
      }
    }
  },
  icon: const Icon(Icons.smart_toy),
  label: const Text('AI Order'),
),
```

- [ ] **Step 4: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: register AI Order DI and add AI Order button to HomePage"
```

---

## PART B: LOCALIZATION

### Task B1: Add flutter_localizations SDK

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Update pubspec.yaml**

Add under `dependencies`:
```yaml
  flutter_localizations:
    sdk: flutter
```

Add under `flutter:` section:
```yaml
  generate: true
```

- [ ] **Step 2: Install**

```bash
cd E:\GitHub\flutter_billing_app && flutter pub get
```

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock && git commit -m "chore: add flutter_localizations SDK"
```

---

### Task B2: Create ARB files for English and Vietnamese

**Files:**
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_vi.arb`

- [ ] **Step 1: Create app_en.arb**

`lib/l10n/app_en.arb`:
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

- [ ] **Step 2: Create app_vi.arb**

`lib/l10n/app_vi.arb`:
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

- [ ] **Step 3: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: add ARB files for English and Vietnamese"
```

---

### Task B3: Generate localization files and configure MaterialApp

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Run code generator**

```bash
cd E:\GitHub\flutter_billing_app && flutter gen-l10n
```

Expected: Generates `lib/l10n/app_localizations.dart` and `app_localizations_en.dart`, `app_localizations_vi.dart`

- [ ] **Step 2: Update main.dart**

Add imports:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
```

Update `MaterialApp.router`:
```dart
MaterialApp.router(
  title: 'Billing App',
  theme: AppTheme.lightTheme,
  routerConfig: router,
  debugShowCheckedModeBanner: false,
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    const Locale('en'),
    const Locale('vi'),
  ],
  locale: const Locale('vi'),
)
```

- [ ] **Step 3: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: add localization delegates and set Vietnamese as default"
```

---

### Task B4: Wrap strings in existing pages with AppLocalizations

**Files:**
- Modify: All existing page files with hardcoded strings

Replace hardcoded strings with `AppLocalizations.of(context)!.xxx` in:
- `lib/features/billing/presentation/pages/home_page.dart`
- `lib/features/billing/presentation/pages/checkout_page.dart`
- `lib/features/billing/presentation/pages/scanner_page.dart`
- `lib/features/product/presentation/pages/product_list_page.dart`
- `lib/features/product/presentation/pages/add_product_page.dart`
- `lib/features/product/presentation/pages/edit_product_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/shop/presentation/pages/shop_details_page.dart`
- `lib/features/expense/presentation/pages/expense_list_page.dart`
- `lib/features/expense/presentation/pages/add_expense_page.dart`
- `lib/features/report/presentation/pages/report_page.dart`
- `lib/features/ai_order/presentation/pages/ai_order_page.dart`
- `lib/features/ai_order/presentation/pages/voice_tab.dart`
- `lib/features/ai_order/presentation/pages/text_tab.dart`
- `lib/features/ai_order/presentation/pages/photo_tab.dart`

Example pattern for each string:
```dart
// Before:
Text('Settings')
// After:
Text(AppLocalizations.of(context)!.settings)
```

- [ ] **Step 1: Replace strings in home_page.dart**

- [ ] **Step 2: Replace strings in checkout_page.dart**

- [ ] **Step 3: Replace strings in product pages**

- [ ] **Step 4: Replace strings in settings pages**

- [ ] **Step 5: Replace strings in expense pages**

- [ ] **Step 6: Replace strings in report_page.dart**

- [ ] **Step 7: Replace strings in ai_order pages**

- [ ] **Step 8: Run analyze**

```bash
cd E:\GitHub\flutter_billing_app && flutter analyze
```
Expected: No errors

- [ ] **Step 9: Commit**

```bash
cd E:\GitHub\flutter_billing_app && git add -A && git commit -m "feat: localize all pages with AppLocalizations"
```
