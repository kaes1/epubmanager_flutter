import 'dart:convert';
import 'dart:developer';

import 'package:epubmanager_flutter/ApiEndpoints.dart' as ApiEndpoints;
import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../MenuDrawer.dart';

class BookSearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookSearchScreenState();
  }
}

class BookSearchScreenState extends State<BookSearchScreen> {
  ApiService apiService = GetIt.instance.get<ApiService>();

  BooksPage _booksPage;
  final key = GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = TextEditingController();
  bool _isSearching = false;
  String _searchText = "";
  Widget appBarTitle = new Text('Search for books', style: new TextStyle(color: Colors.white),);
  Icon actionIcon = new Icon(Icons.search, color: Colors.white,);


  @override
  void initState() {
    super.initState();
    //test search
    Map<String, dynamic> queryParameters = {
      'title': '',
      'author': '',
      'pageNumber': '0',
      'pageSize': '5',
      'sort': 'NONE',
      'sortDirection': 'ASCENDING',
      'tags': []
    };

    apiService.get(ApiEndpoints.booksSearch, queryParameters).then( (response) {
      log('Test Search StatusCode: ${response.statusCode}');
      log('Test Search body: ${response.body}');
      setState(() {
        _booksPage = BooksPage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        log('booksPage size: ${_booksPage.size}');
        log('booksPage content: ${_booksPage.content}');

        _searchQuery.addListener(() {
          if (_searchQuery.text.isEmpty) {
            setState(() {
              _isSearching = false;
              _searchText = "";
            });
          }
          else {
            setState(() {
              _isSearching = true;
              _searchText = _searchQuery.text;
            });
          }
        });
      });
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: key,
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(icon: actionIcon, onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close, color: Colors.white,);
                this.appBarTitle = new TextField(
                  controller: _searchQuery,
                  style: new TextStyle(
                    color: Colors.white,

                  ),
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      hintText: 'Search...',
                      hintStyle: new TextStyle(color: Colors.white)
                  ),
                );
                _handleSearchStart();
              }
              else {
                _handleSearchEnd();
              }
            });
          },),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody(){
    if(_booksPage != null){
      return ListView(
        children: _isSearching ? _buildSearchList() : _buildList(),
      );
    } else {
      return Center(
        child: new Text('No results to display!', style: new TextStyle(fontSize: 20, color: Colors.red)),
      );
    }
  }

  List<ChildItem> _buildList() {
    return _booksPage.content.map((book) => new ChildItem(book)).toList();
  }

  List<ChildItem> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _booksPage.content.map((book) => new ChildItem(book))
          .toList();
    }
    else {
      List<Book> _searchList = List();
      for (int i = 0; i < _booksPage.content.length; i++) {
        Book  foundBook = _booksPage.content.elementAt(i);
        if (foundBook.title.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(foundBook);
        }
      }
      return _searchList.map((book) => new ChildItem(book))
          .toList();
    }
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      this.appBarTitle =
      new Text('Search for books', style: new TextStyle(color: Colors.white),);
      _isSearching = false;
      _searchQuery.clear();
    });
  }

}


class ChildItem extends StatelessWidget {
  final Book book;

  ChildItem(this.book);

  @override
  Widget build(BuildContext context) {
    return new ListTile(title: Text(this.book.title), subtitle: Text(this.book.author.name), onTap: () => _displayBookDetails(this.book, context));
  }

  _displayBookDetails(Book book, BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)));
  }

}
