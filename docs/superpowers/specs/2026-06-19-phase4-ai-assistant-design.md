# Phase 4 — AI Assistant

## Mục tiêu
Chat với AI hỏi đáp về doanh thu, chi phí, lợi nhuận, sản phẩm bán chạy.

## Kiến trúc
- **Rule-based**: Parse tiếng Việt → intent + time → query Hive → trả lời
- **Intent types**: revenue, expense, profit, topProducts, expenseBreakdown
- **Time**: hôm nay, hôm qua, tuần này, tháng này, tháng trước

## Files
```
features/ai_assistant/
├── domain/services/business_assistant.dart
├── data/services/intent_parser.dart
├── data/services/business_assistant_impl.dart
├── presentation/bloc/
│   ├── assistant_event.dart
│   ├── assistant_state.dart
│   └── assistant_bloc.dart
└── presentation/pages/assistant_page.dart
```
