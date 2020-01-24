import 'dart:developer';

import 'package:epubmanager_flutter/book/BookService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/model/Tag.dart';
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
  final BookService bookService = GetIt.instance.get<BookService>();

  List<Book> _books;
  int _currentPage = 0;
  int _lastPage = 50;

  final TextEditingController _titleSearchController = TextEditingController();

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  List<Tag> _selectedTags = [];
  String _sortDirection = 'ASCENDING';
  String _sortType = 'NONE';

  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    this._resetBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: new TextField(
          onChanged: (s) => this._resetBooks(),
          controller: _titleSearchController,
          style: new TextStyle(color: Colors.white),
          decoration: new InputDecoration(
              hintText: 'Search...',
              hintStyle: new TextStyle(color: Colors.white),
              prefixIcon: new Icon(Icons.search, color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
        ),
        actions: <Widget>[
          new IconButton(
            icon: actionIcon,
            onPressed: () {
              setState(() {
                if (this.actionIcon.icon == Icons.search) {
                  this.actionIcon = new Icon(Icons.close, color: Colors.white);
                } else {
                  this.actionIcon = new Icon(Icons.search, color: Colors.white);
                }
              });
            },
          ),
        ],
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_initialLoading){
      return Center(
          heightFactor: 10, child: CircularProgressIndicator());
    } else if (_books == null || _books.isEmpty) {
      return Center(
        child: new Text('No results to display!',
            style: new TextStyle(fontSize: 20, color: Colors.red)),
      );
    } else {
      return ListView.builder(
          itemCount: _books.length + 1,
          itemBuilder: (context, index) {
            if (index < _books.length) {
              return new ChildItem(_books[index]);
            } else if (_currentPage < _lastPage) {
              _fetchMoreBooks();
              return Center(
                  heightFactor: 3, child: CircularProgressIndicator());
            } else {
              return null;
            }
          });
    }
  }

  Future<BooksPage> _getBooksPage(int pageNumber) async {
    log('Getting book page ${pageNumber}');
    BooksPage booksPage = await bookService.findBooks(
        _titleSearchController.text,
        '',
        _selectedTags.map((tag) => tag.name).toList(),
        pageNumber,
        15,
        _sortType,
        _sortDirection);
    this._lastPage = booksPage.totalPages - 1;
    log('Current page: ${pageNumber}, Last Page: ${_lastPage}');
    return booksPage;
  }

  void _resetBooks() {
    this._books = [];
    this._currentPage = 0;
    this._lastPage = 50;
    this._getBooksPage(_currentPage).then((booksPage) {
      this.setState(() {
        this._books.addAll(booksPage.content);
        _initialLoading = false;
      });
    });
  }

  void _fetchMoreBooks() {
    if (_currentPage < _lastPage) {
      _currentPage++;
      this._getBooksPage(_currentPage).then((booksPage) {
        this.setState(() {
          this._books.addAll(booksPage.content);
        });
      });
    }
  }
}

class ChildItem extends StatelessWidget {
  final Book book;

  ChildItem(this.book);

  @override
  Widget build(BuildContext context) {
    String tags = this.book.tags.map((f) => f.name).join(', ');

    return new ListTile(
        title: Text(this.book.title),
        subtitle: Text(this.book.author.name + '\n' + tags),
        isThreeLine: true,
        onTap: () => _displayBookDetails(this.book, context));
  }

  _displayBookDetails(Book book, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => BookDetailsScreen(book: book)));
  }
}
