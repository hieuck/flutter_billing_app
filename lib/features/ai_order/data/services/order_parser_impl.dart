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
          confidence:
              searchName.toLowerCase() == known.toLowerCase() ? 1.0 : 0.8,
        );
      }
    }

    return null;
  }
}
