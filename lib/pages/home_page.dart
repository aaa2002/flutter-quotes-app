import 'package:flutter/material.dart';
import 'package:flutter_test_project/pages/add_new_quote.dart';
import 'package:flutter_test_project/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Quote>> _quotesFuture;

  @override
  void initState() {
    super.initState();
    _quotesFuture = getQuotes();
  }

  Future<List<Quote>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> quotes = prefs.getStringList('quotes') ?? [];
    return quotes
        .map((quoteString) => Quote.fromJsonString(quoteString))
        .toList();
  }

  void _refreshQuotes() {
    setState(() {
      _quotesFuture = getQuotes();
    });
  }

  Future<void> _deleteQuote(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> quotes = prefs.getStringList('quotes') ?? [];
    quotes.remove(quote.toJsonString());
    await prefs.setStringList('quotes', quotes);
    _refreshQuotes();
  }

  Future<void> _showDeleteConfirmationDialog(Quote quote) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Quote'),
          content: const Text('Are you sure you want to delete this quote?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _deleteQuote(quote);
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(186, 108, 59, 1),
        surfaceTintColor: Colors.transparent,
        leading: null,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Quote '),
            Image.asset(
              'assets/logo.png',
              height: 42.0,
            ),
            const Text(' Knot'),
          ],
        ),
      ),
      body: FutureBuilder<List<Quote>>(
        future: _quotesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Quote>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: snapshot.data!.map((quote) {
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      color: const Color.fromRGBO(217, 217, 217, 1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    quote.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      size: 20,
                                      color: Colors.black),
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(quote);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '- ${quote.author}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No quotes added yet.'));
          } else {
            return const Center(child: Text('Something went wrong.'));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNewQuoteView()),
          );
          if (result == true) {
            _refreshQuotes();
          }
        },
        backgroundColor: const Color.fromRGBO(186, 108, 59, 1),
        child: const Icon(Icons.add),
      ),
    );
  }
}
