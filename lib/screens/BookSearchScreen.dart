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
      'tags': ['Fantasy']
    };
    apiService.get(ApiEndpoints.booksSearch, queryParameters).then( (response) {
      log('Test Search StatusCode: ${response.statusCode}');
      log('Test Search body: ${response.body}');

      _booksPage = BooksPage.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      log('booksPage size: ${_booksPage.size}');
      log('booksPage content: ${_booksPage.content}');
      setState(() {

      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('Search for books'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () {},)
        ],
      ),
      body: ListView(
        children: (_booksPage != null) ? _booksPage.content.map((book) {
          return ListTile(title: Text(book.title), subtitle: Text(book.author.name), onTap: _displayBookDetails(book));
        }).toList() : [],
      ),
    );
  }

  _displayBookDetails(Book book) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)));
  }
}
