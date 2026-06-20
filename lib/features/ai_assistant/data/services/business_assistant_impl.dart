import 'package:flutter/material.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../billing/data/models/invoice_model.dart';
import '../../../expense/data/models/expense_model.dart';
import '../services/intent_parser.dart';
import '../../domain/services/business_assistant.dart';

class BusinessAssistantImpl implements BusinessAssistant {
  final IntentParser _parser = IntentParser();

  @override
  Future<String> answer(String question) async {
    final parsed = _parser.parseIntent(question);

    if (parsed.intent == IntentType.unknown) {
      return 'Xin lỗi, tôi chưa hiểu câu hỏi. Bạn có thể hỏi về:\n'
          '- Doanh thu hôm nay\n'
          '- Chi phí tháng này\n'
          '- Lợi nhuận\n'
          '- Sản phẩm bán chạy';
    }

    final range = _getDateRange(parsed.timeFrame);
    final timeLabel = _timeLabel(parsed.timeFrame);

    switch (parsed.intent) {
      case IntentType.revenue:
        return _answerRevenue(range, timeLabel);
      case IntentType.expense:
        return _answerExpense(range, timeLabel);
      case IntentType.profit:
        return _answerProfit(range, timeLabel);
      case IntentType.topProducts:
        return _answerTopProducts(range, timeLabel);
      default:
        return 'Xin lỗi, tôi chưa thể trả lời câu hỏi này.';
    }
  }

  String _answerRevenue(DateTimeRange range, String timeLabel) {
    final invoices = HiveDatabase.invoicesBox.values.where((m) =>
        m.createdAt.isAfter(range.start) &&
        m.createdAt.isBefore(range.end));
    final total = invoices.fold<double>(0, (s, m) => s + m.totalAmount);
    final count = invoices.length;

    return '$timeLabel, doanh thu là ${CurrencyHelper.format(total)} từ $count đơn hàng.';
  }

  String _answerExpense(DateTimeRange range, String timeLabel) {
    final expenses = HiveDatabase.expensesBox.values.where((e) =>
        e.date.isAfter(range.start) && e.date.isBefore(range.end));
    final total = expenses.fold<double>(0, (s, e) => s + e.amount);
    final count = expenses.length;

    return '$timeLabel, tổng chi phí là ${CurrencyHelper.format(total)} từ $count khoản chi.';
  }

  String _answerProfit(DateTimeRange range, String timeLabel) {
    final invoices = HiveDatabase.invoicesBox.values.where((m) =>
        m.createdAt.isAfter(range.start) &&
        m.createdAt.isBefore(range.end));
    final expenses = HiveDatabase.expensesBox.values.where((e) =>
        e.date.isAfter(range.start) && e.date.isBefore(range.end));
    final revenue = invoices.fold<double>(0, (s, m) => s + m.totalAmount);
    final cost = expenses.fold<double>(0, (s, e) => s + e.amount);
    final profit = revenue - cost;

    return '$timeLabel, doanh thu ${CurrencyHelper.format(revenue)}, '
        'chi phí ${CurrencyHelper.format(cost)}, '
        '${profit >= 0 ? "lãi" : "lỗ"} ${CurrencyHelper.format(profit.abs())}.';
  }

  String _answerTopProducts(DateTimeRange range, String timeLabel) {
    final invoices = HiveDatabase.invoicesBox.values.where((m) =>
        m.createdAt.isAfter(range.start) &&
        m.createdAt.isBefore(range.end));
    final count = invoices.length;

    return '$timeLabel có $count đơn hàng. '
        '(Tính năng top sản phẩm sẽ được cập nhật sau)';
  }

  DateTimeRange _getDateRange(TimeFrame timeFrame) {
    final now = DateTime.now();
    switch (timeFrame) {
      case TimeFrame.today:
        return DateTimeRange(start: _startOfDay(now), end: _endOfDay(now));
      case TimeFrame.yesterday:
        final y = now.subtract(const Duration(days: 1));
        return DateTimeRange(start: _startOfDay(y), end: _endOfDay(y));
      case TimeFrame.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return DateTimeRange(start: _startOfDay(weekStart), end: _endOfDay(now));
      case TimeFrame.thisMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: _endOfDay(now),
        );
      case TimeFrame.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateTimeRange(
          start: lastMonth,
          end: _endOfDay(DateTime(now.year, now.month, 0)),
        );
      default:
        return DateTimeRange(start: _startOfDay(now), end: _endOfDay(now));
    }
  }

  String _timeLabel(TimeFrame tf) {
    switch (tf) {
      case TimeFrame.today: return 'Hôm nay';
      case TimeFrame.yesterday: return 'Hôm qua';
      case TimeFrame.thisWeek: return 'Tuần này';
      case TimeFrame.thisMonth: return 'Tháng này';
      case TimeFrame.lastMonth: return 'Tháng trước';
      default: return '';
    }
  }

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);
}
