import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/book/BookListService.dart';
import 'package:epubmanager_flutter/book/BookService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:epubmanager_flutter/model/Comment.dart';
import 'package:epubmanager_flutter/model/NewComment.dart';
import 'package:epubmanager_flutter/screens/EditBookListDialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BookDetailsScreen extends StatefulWidget {
  final int _bookId;

  BookDetailsScreen(this._bookId);

  @override
  State<StatefulWidget> createState() {
    return BookDetailsScreenState();
  }
}

class BookDetailsScreenState extends State<BookDetailsScreen> {
  final StateService _stateService = GetIt.instance.get<StateService>();
  final ApiService _apiService = GetIt.instance.get<ApiService>();
  final BookListService _bookListService =
  GetIt.instance.get<BookListService>();
  final BookService _bookService = GetIt.instance.get<BookService>();

  BookListEntry _bookListEntry = null;
  Book _book = null;

  List<Comment> commentList = [];

  @override
  void initState() {
    super.initState();
    _fetchBook();
    if(_stateService.isLoggedIn()) {
      _fetchBookListEntry();
    }
    _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book details')),
      body: new Column(
        children: <Widget>[
          (_book == null) ? Center(heightFactor: 10, child: CircularProgressIndicator()) : _bookDetailsCard(),
          new Expanded(
            child: Container(
              child: (_book == null) ? Center(heightFactor: 10, child: CircularProgressIndicator()) : _buildCommentsList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _bookDetailsCard() {
    return new Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        height: 220,
        width: 400,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  _book.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text('Author: ' + _book.author.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                Text('Publisher: ' + _book.publisher,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                Text('Rating: ' + _book.rating.toStringAsFixed(2),
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
              ],
            ),
            if (_stateService.isLoggedIn())
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: <Widget>[
                        RaisedButton(
                          child: _bookListEntry == null
                              ? new Text('ADD TO MY LIST')
                              : new Text('EDIT LIST ENTRY'),
                          onPressed: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return EditBookListDialog(
                                  _book.id,
                                  _bookListEntry,
                                  onClose: () => _actualizeDisplayedInfo(),
                                );
                              }),
                          color: Colors.deepPurple,
                          textColor: Colors.white,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        RaisedButton(
                          child: new Text('ADD COMMENT'),
                          onPressed: () {
                            _addCommentDialog(context);
                          },
                          color: Colors.deepPurple,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    if (commentList == null || commentList.isEmpty) {
      return new Center(
        child: Text('No comments to display', style: TextStyle(color: Colors.red)),
      );
    } else {
      return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: commentList
            .map((comment) => new CommentsListItem(comment))
            .toList(),
      );
    }
  }

  _addCommentDialog(BuildContext context) async {
    final commentController = new TextEditingController();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Add Comment',
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: new TextField(
                        controller: commentController,
                        toolbarOptions: const ToolbarOptions(
                            copy: true, paste: true, cut: true, selectAll: false),
                        enableInteractiveSelection: true,
                        autofocus: true,
                        showCursor: true,
                        maxLength: 200,
                        maxLines: 7,
                        keyboardType: TextInputType.multiline,
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          contentPadding: new EdgeInsets.only(
                              left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                          hintText: ' add review',
                          hintStyle: new TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.0,
                            fontFamily: 'helvetica_neue_light',
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              child: new Text('ADD'),
                              color: Colors.deepPurple,
                              textColor: Colors.white,
                              onPressed: () {
                                _addComment(commentController.text);
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
                );
              },
            ),
          );
        });
  }

  _addComment(String comment) {
    if (comment.isNotEmpty) {
      NewComment newComment = new NewComment(_book.id, comment);
      _apiService.post(ApiEndpoints.commentsAdd, newComment).then((response) {
        _fetchComments();
      });
      Navigator.of(context).pop();
    }
  }

  void _actualizeDisplayedInfo(){
    _fetchBook();
    _fetchBookListEntry();
  }

  void _fetchBook(){
    _bookService.getBook(widget._bookId).then((book) {
      setState(() {
        _book = book;
      });
    });
  }

  void _fetchBookListEntry() {
    _bookListService.getBookListEntry(widget._bookId).then((entry) {
      setState(() {
        _bookListEntry = entry;
      });
    });
  }

  void _fetchComments() {
    _apiService
        .get(ApiEndpoints.comments + '/' + widget._bookId.toString())
        .then((response) {
      setState(() {
        commentList =
            Comment.listFromJson(response);
        commentList.sort((c1, c2) {
          return c2.datePosted.compareTo(c1.datePosted);
        });
      });
    });
  }
}

class CommentsListItem extends StatelessWidget {
  final Comment comment;

  CommentsListItem(this.comment);

  @override
  Widget build(BuildContext context) {
    return new Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: ListTile(
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            this.comment.author +
                ' commented on ' +
                this.comment.datePosted.substring(0, 10),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: <Widget>[
              Icon(Icons.format_quote, color: Colors.deepPurple),
              Text(this.comment.message.trim(),
                  style: TextStyle(color: Colors.black))
            ],
          ),
        ),
      ),
    );
  }
}
