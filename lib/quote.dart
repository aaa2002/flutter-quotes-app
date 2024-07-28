import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Quote {
  String text;
  String author;

  Quote({required this.text, required this.author});

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
      };

  static Quote fromJson(Map<String, dynamic> json) => Quote(
        text: json['text'],
        author: json['author'],
      );

  static Quote fromJsonString(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return fromJson(json);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

Future<void> addQuote(Quote quote) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> quotes = prefs.getStringList('quotes') ?? [];

  quotes.add(quote.toJsonString());
  await prefs.setStringList('quotes', quotes);
}

Future<List<Quote>> getQuotes() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> quotes = prefs.getStringList('quotes') ?? [];

  return quotes.map((quote) => Quote.fromJsonString(quote)).toList();
}