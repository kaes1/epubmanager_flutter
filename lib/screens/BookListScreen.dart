import 'dart:developer';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'dart:convert';
import '../MenuDrawer.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart' as ApiEndpoints;

import 'BookDetailsScreen.dart';

class BookListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookListScreenState();
  }
}

class BookListScreenState extends State<BookListScreen> {
  ApiService apiService = GetIt.instance.get<ApiService>();

  List<BookListEntry> bookList = [];

  @override
  void initState() {
    super.initState();

    apiService.get(ApiEndpoints.bookList).then((response) {
      setState(() {
        bookList = BookListEntry.listFromJson(
            json.decode(utf8.decode(response.bodyBytes)));
      });
      log('response.body: ${json.decode(utf8.decode(response.bodyBytes))}');
      log('bookList length: ${bookList.length}');
    });
  }

  List<Widget> generateTiles() {
    return bookList.map((entry) {
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(book: entry.book)));
            Navigator.pushNamed(context, '/book-details');
          });
    }).toList();
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
}
