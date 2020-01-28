import 'dart:async';

import 'package:epubmanager_flutter/exception/ConnectionException.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/model/Tag.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:epubmanager_flutter/services/BookService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:get_it/get_it.dart';

import 'MenuDrawer.dart';
import 'NoConnectionDialog.dart';

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
  final String _advancedSearchText = '(Advanced Search)';

  Icon _actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  List<Tag> _allTags = [];
  List<String> _selectedTags = [];
  List<dynamic> _multiSelectValue;
  String _sortDirection = 'ASCENDING';
  String _sortType = 'NONE';

  bool _initialLoading = true;
  bool _connectionError = false;

  BookSearchScreenState() {
    this._fetchAllTags();

    _titleSearchController.addListener(() {
      if (_advancedSearch &&
          _titleSearchController.text != _advancedSearchText) {
        _titleSearchController.text = '';
        _selectedTags = [];
        _sortDirection = 'ASCENDING';
        _sortType = 'NONE';
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _titleAdvancedSearchController.clear());
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => _authorAdvancedSearchController.clear());
        _advancedSearch = false;
      }

      if (_titleSearchController.text.isEmpty) {
        setState(() {
          this._actionIcon = new Icon(Icons.search, color: Colors.white);
        });
      } else {
        setState(() {
          this._actionIcon = new Icon(Icons.close, color: Colors.white);
        });
      }
      this._resetBooks();
    });
  }

  @override
  void initState() {
    super.initState();
    this._resetBooks();
  }

  @override
  void dispose() {
    _titleSearchController.dispose();
    _titleAdvancedSearchController.dispose();
    _authorAdvancedSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: new TextField(
          autofocus: false,
          controller: _titleSearchController,
          style: new TextStyle(color: Colors.white),
          decoration: new InputDecoration(
              hintText: 'Search...',
              hintStyle: new TextStyle(color: Colors.white),
              suffixIcon: new IconButton(
                icon: _actionIcon,
                onPressed: () => setState(() {
                  if (this._actionIcon.icon == Icons.close) {
                    _titleSearchController.text = '';
                  }
                }),
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))),
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showAdvancedSearchDialog(context);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_connectionError) {
      return Center(
        child: new Text('Connection error!',
            style: new TextStyle(fontSize: 20, color: Colors.red)),
      );
    } else if (_initialLoading) {
      return Center(heightFactor: 10, child: CircularProgressIndicator());
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
              return new BookChildItem(_books[index]);
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

  _showAdvancedSearchDialog(BuildContext context) async {
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
                        decoration: InputDecoration(labelText: 'Title: '),
                      )),
                      Flexible(
                        child: new TextField(
                          controller: _authorAdvancedSearchController,
                          decoration: InputDecoration(labelText: 'Author: '),
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
                              } else
                                return null;
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
                                this._multiSelectValue = value;
                                if (value != null) {
                                  this._selectedTags = List(value.length);
                                  for (int i = 0; i < value.length; i++) {
                                    this._selectedTags[i] = value[i];
                                  }
                                } else {
                                  this._selectedTags = [];
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: <Widget>[
                            Text('Sort type: '),
                            DropdownButton(
                              value: _sortType,
                              items: _possibleSortTypes.map((status) {
                                return DropdownMenuItem(
                                    child: Text(status), value: status);
                              }).toList(),
                              onChanged: (value) =>
                                  setState(() => _sortType = value),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: Row(
                          children: <Widget>[
                            Text('Sort direction: '),
                            DropdownButton(
                              value: _sortDirection,
                              items: _possibleSortDirections.map((status) {
                                return DropdownMenuItem(
                                    child: Text(status), value: status);
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
                                onPressed: () {
                                  _titleSearchController.text =
                                      _advancedSearchText;
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
                                onPressed: () => Navigator.of(context).pop(),
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

  void _fetchAllTags() {
    _bookService.getAllTags().then((allTags) {
      setState(() {
        allTags.sort((t1, t2) {
          return t1.name.compareTo(t2.name);
        });
        this._allTags = allTags;
      });
    }).catchError((error) {
      setState(() {
        _connectionError = true;
      });
    }, test: (e) => e is ConnectionException);
  }

  Future<BooksPage> _getBooksPage(int pageNumber) async {
    return _bookService
        .findBooks(
            _advancedSearch
                ? _titleAdvancedSearchController.text
                : _titleSearchController.text,
            _advancedSearch ? _authorAdvancedSearchController.text : '',
            _advancedSearch ? _selectedTags : [],
            pageNumber,
            20,
            _advancedSearch ? _sortType : 'NONE',
            _advancedSearch ? _sortDirection : 'ASCENDING')
        .then((booksPage) {
      this._lastPage = booksPage.totalPages - 1;
      return booksPage;
    }).catchError((error) {
      NoConnectionDialog.show(context);
      setState(() {
        _connectionError = true;
      });
    }, test: (e) => e is ConnectionException);
  }

  void _resetBooks() {
    _currentPage = 0;
    _lastPage = 50;
    _getBooksPage(_currentPage).then((booksPage) {
      setState(() {
        _books = booksPage?.content;
        _initialLoading = false;
      });
    });
  }

  void _fetchMoreBooks() {
    if (_currentPage < _lastPage) {
      _currentPage++;
      _getBooksPage(_currentPage).then((booksPage) {
        setState(() {
          _books.addAll(booksPage.content);
        });
      });
    }
  }
}

class BookChildItem extends StatelessWidget {
  final Book _book;

  BookChildItem(this._book);

  @override
  Widget build(BuildContext context) {
    String tags = _book.tags.map((f) => f.name).join(', ');

    return new ListTile(
        title: Text(_book.title),
        subtitle: Text(_book.author.name + '\n' + tags),
        isThreeLine: true,
        onTap: () => _navigateToBookDetails(_book, context));
  }

  _navigateToBookDetails(Book book, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => BookDetailsScreen(book.id)));
  }
}
