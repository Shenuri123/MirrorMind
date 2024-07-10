import 'package:mirrormind/model/model.dart';

class QuotesHelper {
  static Future<List<Quote>> getQuotes() async {
    List<Quote> quotes = [];
    quotes.add(Quote(
        name: '5/24/2023',
        description: "When you have a dream, you've!",
        isSelected: false));

    quotes.add(Quote(
        name: '5/24/2024',
        description: "When you have a dream, you've!",
        isSelected: false));
    return quotes;
  }
}
