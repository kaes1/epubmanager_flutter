import 'package:epubmanager_flutter/consts/ApiEndpoints.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:epubmanager_flutter/model/Comment.dart';
import 'package:epubmanager_flutter/model/NewComment.dart';
import 'package:epubmanager_flutter/screens/EditBookListDialog.dart';
import 'package:epubmanager_flutter/services/ApiService.dart';
import 'package:epubmanager_flutter/services/BookListService.dart';
import 'package:epubmanager_flutter/services/BookService.dart';
import 'package:epubmanager_flutter/services/StateService.dart';
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

  BookListEntry _bookListEntry;
  Book _book;

  List<Comment> _commentList = [];

  @override
  void initState() {
    super.initState();
    _fetchBook();
    if (_stateService.isLoggedIn()) {
      _fetchBookListEntry();
    }
    _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book details')),
      body: ListView(
        children: <Widget>[
          if (_book == null)
            Center(heightFactor: 10, child: CircularProgressIndicator())
          else
            _bookDetailsCard(),
          if (_book != null) _buildCommentsList()
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
                Text('Publisher: ' + (_book.publisher ?? '-'),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                Text('Rating: ' + (_book.rating?.toStringAsFixed(2) ?? '-'),
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
                        Expanded(
                          child: RaisedButton(
                              child: _bookListEntry == null
                                  ? new Text('ADD TO MY LIST')
                                  : new Text('EDIT LIST ENTRY'),
                              onPressed: () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EditBookListDialog(
                                      _book.id,
                                      _bookListEntry,
                                      onClose: () => _fetchDisplayedInfo(),
                                    );
                                  })),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: RaisedButton(
                            child: new Text('ADD COMMENT'),
                            onPressed: () {
                              _addCommentDialog(context);
                            },
                          ),
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
    if (_commentList == null || _commentList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 25),
        child: new Center(
          child:
              Text('No comments yet', style: TextStyle(color: Colors.red, fontSize: 18)),
        ),
      );
    } else {
      return Column(
        children: _commentList
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
                            copy: true,
                            paste: true,
                            cut: true,
                            selectAll: false),
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
                          hintText: 'Leave a comment...',
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
                              onPressed: () => Navigator.of(context).pop(),
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

  void _fetchDisplayedInfo() {
    _fetchBook();
    _fetchBookListEntry();
  }

  void _fetchBook() {
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
        _commentList = Comment.listFromJson(response);
        _commentList.sort((c1, c2) {
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
          title: RichText(
              text: TextSpan(children: <TextSpan>[
            TextSpan(
                text: this.comment.author,
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            TextSpan(
                text: ' commented on ', style: TextStyle(color: Colors.black)),
            TextSpan(
                text: this.comment.datePosted.substring(0, 10),
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ])),
          subtitle: Row(
            children: <Widget>[
              Icon(Icons.format_quote, color: Colors.deepPurple),
              Flexible(
                child: Text(this.comment.message.trim(),
                    style: TextStyle(color: Colors.black)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
