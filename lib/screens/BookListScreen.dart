import 'dart:developer';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/book/BookListService.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../MenuDrawer.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart';

import 'BookDetailsScreen.dart';

class BookListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookListScreenState();
  }
}

class BookListScreenState extends State<BookListScreen> {
  //TODO display message when booklist is empty.
  final BookListService _bookListService = GetIt.instance.get<BookListService>();
  final ApiService _apiService = GetIt.instance.get<ApiService>();

  List<BookListEntry> _bookList = [];

  @override
  void initState() {
    super.initState();
    _fetchBookList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('My book list'),
      ),
      body: ListView(
        children: generateTiles(),
      ),
    );
  }

  List<Widget> generateTiles() {
    return _bookList.map((entry) {
      return ListTile(
          title: Text(entry.book.title),
          subtitle: Text(entry.book.author.name),
          trailing: Stack(

            alignment: Alignment.center,
            children: <Widget>[

              Icon(Icons.star, color: Colors.amber, size: 50,),
              Text(
                entry.rating.toString(),
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(entry.book)));
          });
    }).toList();
  }

  void _fetchBookList() {
    _bookListService.getBookList().then((bookList){
      setState(() {
        this._bookList = bookList;
      });
    });
  }
}
