# Phase 3 — QR Động & Loa báo tiền Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development

**Goal:** Add dynamic UPI QR payment and cash announcement speaker

**Tech Stack:** Flutter, pretty_qr_code (đã có), flutter_tts (mới), flutter_bloc

---

### Task 1: Add flutter_tts dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1:** Add to dependencies:
```yaml
  flutter_tts: ^4.0.2
```

- [ ] **Step 2:** `flutter pub get && git add -A && git commit -m "chore: add flutter_tts for cash announcement"`

---

### Task 2: Create TtsHelper service

**Files:**
- Create: `lib/core/utils/tts_helper.dart`
- Create: `test/core/utils/tts_helper_test.dart`

- [ ] **Step 1 (TDD):** Write test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:billing_app/core/utils/tts_helper.dart';

void main() {
  group('TtsHelper', () {
    test('can be instantiated', () {
      expect(TtsHelper(), isNotNull);
    });
  });
}
```

- [ ] **Step 2:** Run → FAIL
- [ ] **Step 3:** Create `lib/core/utils/tts_helper.dart`:
```dart
import 'package:flutter_tts/flutter_tts.dart';

class TtsHelper {
  final FlutterTts _tts = FlutterTts();

  TtsHelper() {
    _tts.setLanguage('vi-VN');
    _tts.setSpeechRate(0.5);
  }

  Future<void> announcePayment(double amount) async {
    final formatted = amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);
    await _tts.speak('Đã nhận $formatted đồng');
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
```

- [ ] **Step 4:** Run → PASS
- [ ] **Step 5:** Commit

---

### Task 3: Add QR code + Mark as Paid button to checkout page

**Files:**
- Modify: `lib/features/billing/presentation/pages/checkout_page.dart`
- Modify: `lib/core/service_locator.dart` (register TtsHelper)

- [ ] **Step 1:** Update checkout_page.dart

Current checkout_page.dart reads shop + cart from state. Add:
- `flutter_tts` audio plays "Đã nhận X đồng" when "Mark as Paid" is tapped
- Dynamic UPI QR code using `pretty_qr_code`

Key changes to checkout_page.dart:
```dart
// Add imports
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/features/shop/data/models/shop_model.dart';

// In the build method, after the order summary section, add:
// (Read shop data from HiveDatabase.shopBox)
// Generate QR: upi://pay?pa={upiId}&am={totalAmount}&tn={orderId}
// Display PrettyQrView(data: qrData)
// Add "Mark as Paid" ElevatedButton that:
//   1. Plays TTS: "Đã nhận X đồng"
//   2. Calls CompleteOrderEvent on BillingBloc to save Invoice
//   3. Shows success SnackBar
//   4. Pops back
```

- [ ] **Step 2:** Analyze + commit
```bash
cd E:\GitHub\flutter_billing_app && flutter analyze && git add -A && git commit -m "feat: add dynamic QR payment and cash announcement speaker"
```
