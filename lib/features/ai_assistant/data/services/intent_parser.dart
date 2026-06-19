enum IntentType { revenue, expense, profit, topProducts, unknown }

enum TimeFrame { today, yesterday, thisWeek, thisMonth, lastMonth, custom }

class ParseResult {
  final IntentType intent;
  final TimeFrame timeFrame;
  final DateTime? customFrom;
  final DateTime? customTo;

  const ParseResult({
    required this.intent,
    this.timeFrame = TimeFrame.today,
    this.customFrom,
    this.customTo,
  });
}

class IntentParser {
  static const _revenueKeywords = ['doanh thu', 'bán được', 'thu về', 'doanh số'];
  static const _expenseKeywords = ['chi phí', 'đã chi', 'chi tiêu', 'mua'];
  static const _profitKeywords = ['lãi', 'lỗ', 'lợi nhuận', 'lời'];
  static const _topProductKeywords = ['bán chạy', 'sản phẩm', 'mặt hàng', 'top'];

  static const _todayKeywords = ['hôm nay'];
  static const _yesterdayKeywords = ['hôm qua'];
  static const _thisWeekKeywords = ['tuần này'];
  static const _thisMonthKeywords = ['tháng này'];
  static const _lastMonthKeywords = ['tháng trước'];

  ParseResult parseIntent(String text) {
    final lower = text.toLowerCase();
    final intent = _detectIntent(lower);
    final timeFrame = _detectTimeFrame(lower);

    return ParseResult(intent: intent, timeFrame: timeFrame);
  }

  IntentType _detectIntent(String lower) {
    for (final k in _revenueKeywords) {
      if (lower.contains(k)) return IntentType.revenue;
    }
    for (final k in _expenseKeywords) {
      if (lower.contains(k)) return IntentType.expense;
    }
    for (final k in _profitKeywords) {
      if (lower.contains(k)) return IntentType.profit;
    }
    for (final k in _topProductKeywords) {
      if (lower.contains(k)) return IntentType.topProducts;
    }
    return IntentType.unknown;
  }

  TimeFrame _detectTimeFrame(String lower) {
    for (final k in _todayKeywords) { if (lower.contains(k)) return TimeFrame.today; }
    for (final k in _yesterdayKeywords) { if (lower.contains(k)) return TimeFrame.yesterday; }
    for (final k in _thisWeekKeywords) { if (lower.contains(k)) return TimeFrame.thisWeek; }
    for (final k in _thisMonthKeywords) { if (lower.contains(k)) return TimeFrame.thisMonth; }
    for (final k in _lastMonthKeywords) { if (lower.contains(k)) return TimeFrame.lastMonth; }
    return TimeFrame.today;
  }
}
