import 'dart:developer';

import 'package:epubmanager_flutter/book/BookService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/model/Tag.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';

import '../MenuDrawer.dart';

class BookSearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return BookSearchScreenState();
  }
}

class BookSearchScreenState extends State<BookSearchScreen> {
  final BookService _bookService = GetIt.instance.get<BookService>();

  List<Book> _books;
  int _currentPage = 0;
  int _lastPage = 50;

  final TextEditingController _titleSearchController = TextEditingController();

  final _titleAdvancedSearchController = new TextEditingController();
  final _authorAdvancedSearchController = new TextEditingController();
  final _possibleSortTypes = ['TITLE', 'AUTHOR', 'NONE'];
  final _possibleSortDirections = ['ASCENDING', 'DESCENDING'];

  bool _advancedSearch = false;

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  List<Tag> _allTags = [];
  List<String> _selectedTags = [];
  List<dynamic> _multiSelectValue = null;
  String _sortDirection = 'ASCENDING';
  String _sortType = 'NONE';

  bool _initialLoading = true;

  BookSearchScreenState() {
    this._getAllTags();

    _titleSearchController.addListener(() {
      if (_titleSearchController.text.isEmpty) {
        setState(() {
          this.actionIcon = new Icon(Icons.search, color: Colors.white);
          if(_advancedSearch){
            this._selectedTags = [];
            _sortDirection = 'ASCENDING';
            _sortType = 'NONE';
            WidgetsBinding.instance.addPostFrameCallback((_) => _titleAdvancedSearchController.clear());
            WidgetsBinding.instance.addPostFrameCallback((_) => _authorAdvancedSearchController.clear());
            _advancedSearch = false;
          }
          this._resetBooks();
        });
      }
      else {
        setState(() {
          this.actionIcon = new Icon(Icons.close, color: Colors.white);
        });
      }
    });
  }

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
          autofocus: false,
          onChanged: (s) => this._resetBooks(),
          controller: _titleSearchController,
          style: new TextStyle(color: Colors.white),
          decoration: new InputDecoration(
              hintText: 'Search...',
              hintStyle: new TextStyle(color: Colors.white),
              suffixIcon: new IconButton(
                icon: actionIcon,
                onPressed: () {
                  setState(() {
                    if (this.actionIcon.icon == Icons.close) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => _titleSearchController.clear());
                    }
                  });
                },
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: (){
              _advancedSearchDialog(context);
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

  _advancedSearchDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Advanced search',
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Flexible(
                          child: new TextField(
                            controller: _titleAdvancedSearchController,
                            decoration: InputDecoration(
                                labelText: 'Title: '),
                          )),
                      Flexible(
                        child: new TextField(
                          controller: _authorAdvancedSearchController,
                          decoration: InputDecoration(
                              labelText: 'Author: '),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          child: MultiSelect(
                            autovalidate: false,
                            titleText: 'Tags: ',
                            validator: (value) {
                              if (value == null) {
                                return 'Please select tag(s)';
                              } else return null;
                            },
                            errorText: 'Please select tag(s)',
                            dataSource: this._allTags.map((tag) {
                              return {'name': tag.name, 'id': tag.name};
                            }).toList(),
                            textField: 'name',
                            valueField: 'id',
                            filterable: false,
                            required: false,
                            initialValue: this._multiSelectValue,
                            value: null,
                            change: (value) {
                              setState(() {
                                if(value != null) {
                                  this._multiSelectValue = value;
                                  this._selectedTags = List(value.length);
                                  for (int i = 0; i < value.length; i++) {
                                    this._selectedTags[i] = value[i];
                                  }
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        child:  Row(
                          children: <Widget>[
                            Text('Sort type: '),
                            DropdownButton(
                              value: _sortType,
                              items: _possibleSortTypes.map((status) {
                                return DropdownMenuItem(child: Text(status), value: status);
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _sortType = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child:  Row(
                          children: <Widget>[
                            Text('Sort direction: '),
                            DropdownButton(
                              value: _sortDirection,
                              items: _possibleSortDirections.map((status) {
                                return DropdownMenuItem(child: Text(status), value: status);
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _sortDirection = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                child: new Text('SEARCH'),
                                color: Colors.deepPurple,
                                textColor: Colors.white,
                                onPressed: () {
                                  WidgetsBinding.instance.addPostFrameCallback((_) => _titleSearchController.text='(Advanced search)');
                                  setState(() {
                                    _advancedSearch = true;

                                  });
                                  _resetBooks();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: RaisedButton(
                                child: new Text('CANCEL'),
                                color: Colors.deepPurple,
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  void _getAllTags() {
    _bookService.getAllTags().then((allTags){
      setState(() {
        allTags.sort((t1, t2) {
          return t1.name.compareTo(t2.name);
        });
        this._allTags = allTags;
      });
    });
  }


  Future<BooksPage> _getBooksPage(int pageNumber) async {
    log('Getting book page ${pageNumber}');
    BooksPage booksPage = await _bookService.findBooks(
        _advancedSearch ? _titleAdvancedSearchController.text : _titleSearchController.text,
        _advancedSearch ? _authorAdvancedSearchController.text : '',
        this._selectedTags,
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
        MaterialPageRoute(builder: (context) => BookDetailsScreen(book.id)));
  }
}
