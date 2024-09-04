import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test_project/quote.dart';

class AddNewQuoteView extends StatefulWidget {
  const AddNewQuoteView({super.key});

  @override
  _AddNewQuoteViewState createState() => _AddNewQuoteViewState();
}

class _AddNewQuoteViewState extends State<AddNewQuoteView> {
  final TextEditingController _quoteController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  Future<void> addQuote(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> quotes = prefs.getStringList('quotes') ?? [];

    quotes.add(
        quote.toJsonString()); // Assuming toJsonString() returns a JSON string
    await prefs.setStringList('quotes', quotes);
  }

  void _submitQuote() {
    final quoteText = _quoteController.text;
    final authorText = _authorController.text;

    if (quoteText.isNotEmpty && authorText.isNotEmpty) {
      final newQuote = Quote(
        text: quoteText,
        author: authorText,
      );

      addQuote(newQuote).then((_) {
        Navigator.pop(context, true); // Return true to indicate success
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both quote and author')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Quote'),
        backgroundColor: Color.fromRGBO(186, 108, 59, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Theme(
                data:
                    Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: _quoteController,
                  decoration: const InputDecoration(
                      labelText: 'Quote',
                      border: OutlineInputBorder(),
                      fillColor: Color.fromRGBO(217, 217, 217, 1)),
                  maxLines: 3,
                )),
            const SizedBox(height: 10),
            Theme(
                data:
                    Theme.of(context).copyWith(splashColor: Colors.transparent),
                child: TextField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                      labelText: 'Author',
                      border: OutlineInputBorder(),
                      fillColor: Color.fromRGBO(217, 217, 217, 1)),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitQuote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(186, 108, 59, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Add Quote',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
