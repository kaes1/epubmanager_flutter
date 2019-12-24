import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:epubmanager_flutter/screens/BookListScreen.dart';
import 'package:epubmanager_flutter/screens/BookSearchScreen.dart';
import 'package:epubmanager_flutter/screens/BookUploadScreen.dart';
import 'package:epubmanager_flutter/screens/HomeScreen.dart';
import 'package:epubmanager_flutter/screens/LoginScreen.dart';
import 'package:epubmanager_flutter/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  GetIt.instance.registerSingleton<ApiService>(ApiService());
  GetIt.instance.registerSingleton<StateService>(StateService());
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/book-list': (context) => BookListScreen(),
        '/book-upload': (context) => BookUploadScreen(),
        '/book-details': (context) => BookDetailsScreen(),
        '/search': (context) => BookSearchScreen(),
      },
      title: 'epubmanager',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
    );
  }
}
//todo RXDART ?
//class RandomWords extends StatefulWidget {
//  @override
//  RandomWordsState createState() {
//    return RandomWordsState();
//  }
//}
//class RandomWordsState extends State<RandomWords> {
//  final List<WordPair> _suggestions = <WordPair>[];
//  final Set<WordPair> _saved = Set<WordPair>();
//  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Startup Name Generator'),
//        actions: <Widget>[
//          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)
//        ],
//      ),
//      body: ListView.builder(itemBuilder: (context, i) {
//        if (i.isOdd) return Divider(thickness: 5);
//        final int index = i ~/ 2;
//        if (index >= _suggestions.length) {
//          _suggestions.addAll(generateWordPairs().take(10));
//        }
//        return _buildRow(_suggestions[index]);
//      }),
//    );
//  }
//
//  ListTile _buildRow(WordPair pair) {
//    final bool alreadySaved = _saved.contains(pair);
//    return ListTile(
//      title: Text(
//        pair.asPascalCase,
//        style: _biggerFont,
//      ),
//      trailing: Icon(
//        alreadySaved ? Icons.favorite : Icons.favorite_border,
//        color: alreadySaved ? Colors.red : null,
//      ),
//      onTap: () {
//        setState(() {
//          alreadySaved ? _saved.remove(pair) : _saved.add(pair);
//        });
//      },
//    );
//  }
//
//  void _pushSaved() {
//    Navigator.of(context)
//        .push(MaterialPageRoute(builder: (BuildContext context) {
//      final Iterable<ListTile> tiles = _saved.map((WordPair pair) {
//        return ListTile(title: Text(pair.asPascalCase, style: _biggerFont));
//      });
//
//      final List<Widget> divided =
//      ListTile.divideTiles(context: context, tiles: tiles).toList();
//
//      return Scaffold(
//        appBar: AppBar(title: Text('Saved Suggestions')),
//        body: ListView(children: divided),
//      );
//    }));
//  }
//}
