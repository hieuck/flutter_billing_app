# Phase 3 — QR Động & Loa báo tiền

## Mục tiêu

- Thêm QR thanh toán động (UPI) trên màn hình checkout
- Cashier xác nhận đã nhận tiền → app phát loa báo số tiền

## Kiến trúc

- **QR động**: Dùng `pretty_qr_code` (đã có) tạo `upi://pay?pa={upiId}&am={amount}&tn={orderId}` từ thông tin Shop
- **Loa báo tiền**: `flutter_tts` — Text-to-Speech phát "Đã nhận {amount} đồng"
- **Manual confirm**: Nút "Mark as Paid" trên checkout page → emit event → TTS → lưu Invoice → clear cart
- **Auto detect**: Dành cho phase sau (backend webhook)

## Files thay đổi

- `pubspec.yaml` — thêm flutter_tts
- `checkout_page.dart` — thêm QR code + nút xác nhận
- `core/utils/printer_helper.dart` hoặc tạo `core/utils/tts_helper.dart` — TTS wrapper
