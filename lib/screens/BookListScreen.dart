import 'package:epubmanager_flutter/services/BookListService.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'MenuDrawer.dart';

final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

class BookListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookListScreenState();
  }
}

class BookListScreenState extends State<BookListScreen> with RouteAware {
  final BookListService _bookListService =
      GetIt.instance.get<BookListService>();

  List<BookListEntry> _bookList = [];

  @override
  void initState() {
    super.initState();
    _fetchBookList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    _fetchBookList();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('My book list'),
      ),
      body: _bookList.isEmpty
          ? Center(
              child: Text('No entries to display!',
                  style: TextStyle(fontSize: 20, color: Colors.red)))
          : ListView(children: generateTiles()),
    );
  }

  List<Widget> generateTiles() {
    return _bookList.map((entry) {
      String tags = entry.book.tags.map((f) => f.name).join(', ');

      return ListTile(
          title: Text(entry.book.title),
          subtitle: Text(entry.book.author.name + '\n' + tags),
          isThreeLine: true,
          trailing: Column(
            children: <Widget>[
              SizedBox(
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Icon(Icons.star, color: Colors.amber, size: 56),
                    Text(
                      entry.rating?.toString() ?? '-',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        statusToPrettyString(entry.status),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => BookDetailsScreen(entry.book.id)));
          });
    }).toList();
  }

  void _fetchBookList() {
    _bookListService.getBookList().then((bookList) {
      setState(() {
        this._bookList = bookList;
      });
    });
  }
}
