import 'dart:convert';
import 'dart:developer';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/Comment.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart';
import '../MenuDrawer.dart';


class BookDetailsScreen extends StatefulWidget {

  final Book book;
  BookDetailsScreen({@required this.book});

  @override
  State<StatefulWidget> createState() {
    return BookDetailsScreenState(this.book);
  }
}


class BookDetailsScreenState extends State<BookDetailsScreen>{
  //todo retrieve bookListEntry for logged in user (if logged in) and display values.
  StateService stateService = GetIt.instance.get<StateService>();
  ApiService apiService = GetIt.instance.get<ApiService>();

  //todo pass bookId and retrieve book from api??

  final _possibleRatings = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  final _possibleStatuses = ['COMPLETED', 'READING', 'PLAN TO READ'];

  Book  bookObject;
  BookDetailsScreenState(this.bookObject);

  List<Comment> commentList = [];

  void initState() {
    super.initState();

    apiService.get(ApiEndpoints.comments + '/' + bookObject.id.toString()).then((response) {
      setState(() {
        commentList = Comment.listFromJson(
            json.decode(utf8.decode(response.bodyBytes)));
      });
      log('response.body: ${json.decode(utf8.decode(response.bodyBytes))}');
      log('comment length: ${commentList.length}');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Book details')),
      body: new Column(
        children: <Widget>[
          _bookDetailsCard(),
          new Expanded(
            child: Container(
              child: _buildCommentsList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _bookDetailsCard(){
    return new Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        height: 250,
        width: 400,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  bookObject.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23),
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text('Author: ' + bookObject.author.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                Text('Publisher: ' + bookObject.publisher, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                Text('Rating: ' + bookObject.rating.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
              ],
            ),
            if (stateService.isloggedIn())
              Column(
                children: <Widget>[
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child:  Row(
                      children: <Widget>[
                        RaisedButton(
                          child: new Text('ADD TO MY LIST'),
                          onPressed: () {_addToListDialog(context);},
                          color: Colors.deepPurple,
                          textColor: Colors.white,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        RaisedButton(
                          child: new Text('ADD COMMENT'),
                          onPressed: () {_addCommentDialog(context);},
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

  Widget _buildCommentsList(){
    if(commentList == null || commentList.isEmpty){
      return new Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50.0,
            ),
            Text('No comments to display', style: TextStyle(color: Colors.red)),
          ],
        ),
      );
    } else {
      return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: commentList.map((comment) => new CommentsListItem(comment)).toList(),
      );
    }
  }

  _addCommentDialog(BuildContext context) async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Comment', textAlign: TextAlign.center,),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container (
                        child: new TextField(
                          decoration: new InputDecoration(
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: new EdgeInsets.only(
                                left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                            hintText: ' add review',
                            hintStyle: new TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12.0,
                              fontFamily: 'helvetica_neue_light',
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 23.0),
                      child: Row(
                        children: <Widget>[
                          RaisedButton(
                            child: new Text('ADD'),
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {

                            },
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          RaisedButton(
                            child: new Text('CANCEL'),
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
    );
  }


  _addToListDialog(BuildContext context) async {

    int selectedRating;
    String selectedStatus;

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add to list', textAlign: TextAlign.center,),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('Status: '),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 49.0),
                      child: Row(
                        children: <Widget>[
                          DropdownButton(
                            value: selectedStatus,
                            items: _possibleStatuses.map((status) {
                              return DropdownMenuItem(
                                  child: Text(status), value: status);
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedStatus = value);
                            },
                          )
                        ],
                      ),
                    ),
                    Text('Your rating: '),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 90.0),
                      child: Row(
                        children: <Widget>[
                          DropdownButton(
                            value: selectedRating,
                            items: _possibleRatings.map((rating) {
                              return DropdownMenuItem(
                                  child: Text(rating.toString()), value: rating);
                            }).toList(),
                            onChanged: (value) {
                              setState(() => selectedRating = value);
                            },
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 23.0),
                      child: Row(
                        children: <Widget>[
                          RaisedButton(
                            child: new Text('ADD'),
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {

                            },
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          RaisedButton(
                            child: new Text('CANCEL'),
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
    );
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          title: Text(
            this.comment.author + ' commented on ' + this.comment.datePosted,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Row(
            children: <Widget>[
              Icon(Icons.format_quote, color: Colors.deepPurple),
              Text(this.comment.message, style: TextStyle(color: Colors.black))
            ],
          ),
        ),
      ),
    );
  }
}
