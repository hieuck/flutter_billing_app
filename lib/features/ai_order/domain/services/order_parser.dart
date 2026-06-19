import '../entities/parsed_order_item.dart';

abstract class OrderParser {
  List<ParsedOrderItem> parse(String rawText);
}
