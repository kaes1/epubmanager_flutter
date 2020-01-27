import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/book/BookListService.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../MenuDrawer.dart';
import 'BookDetailsScreen.dart';


final RouteObserver<PageRoute> routeObserver = new RouteObserver<PageRoute>();

class BookListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookListScreenState();
  }
}

class BookListScreenState extends State<BookListScreen> with RouteAware {
  //TODO display message when booklist is empty.
  final BookListService _bookListService = GetIt.instance.get<BookListService>();

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
      body: _bookList.isEmpty ?
      Center(child: Text('No entries to display!', style: TextStyle(fontSize: 20, color: Colors.red)))
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
          trailing: SizedBox(
            width: 70,
            child: Column(
              children: <Widget>[
                Stack(

                  alignment: Alignment.center,
                  children: <Widget>[

                    Icon(Icons.star, color: Colors.amber, size: 45),
                    Text(
                      entry.rating.toString(),
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
                Text(
                  entry.status,
                  style: TextStyle(fontSize: 9.5),
                )
              ],
            ),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookDetailsScreen(entry.book.id)));
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
