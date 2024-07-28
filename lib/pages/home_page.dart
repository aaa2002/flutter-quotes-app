import 'package:flutter/material.dart';
import 'package:flutter_test_project/pages/add_new_quote.dart';
import 'package:flutter_test_project/quote.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotient'),
        backgroundColor: Colors.deepOrange[200],
        //app logo as png
        leading: Image.asset('assets/logo.png'),
      ),
      body: FutureBuilder<List<Quote>>(
        future: _quotesFuture,
        builder: (BuildContext context, AsyncSnapshot<List<Quote>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: snapshot.data!.map((quote) {
                  return Container(
                    width: double.infinity,
                    child: Card(
                      margin: EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quote.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
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
            return Center(child: Text('No quotes added yet.'));
          } else {
            return Center(child: Text('Something went wrong.'));
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewQuoteView()),
          );
          if (result == true) {
            _refreshQuotes();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrange[200],
      ),
    );
  }
}
