import 'dart:developer';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/Comment.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart' as ApiEndpoints;
import '../MenuDrawer.dart';


class BookDetailsScreen extends StatelessWidget{
  //todo retrieve bookListEntry for logged in user (if logged in) and display values.
  StateService stateService = GetIt.instance.get<StateService>();
  ApiService apiService = GetIt.instance.get<ApiService>();

  //todo pass bookId and retrieve book from api??

  final _possibleRatings = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];
  final _possibleStatuses = ['COMPLETED', 'READING', 'PLAN TO READ'];

  final Book book;
  BookDetailsScreen({@required this.book});



  @override
  Widget build(BuildContext context) {

//    StateSetter setState;
//
//    apiService.get(ApiEndpoints.bookList).then((response) {
//      setState(() {
//        bookList = BookListEntry.listFromJson(
//            json.decode(utf8.decode(response.bodyBytes)));
//      });
//      log('response.body: ${json.decode(utf8.decode(response.bodyBytes))}');
//      log('bookList length: ${bookList.length}');
//    });


    return Scaffold(
      appBar: AppBar(title: Text('Book details')),
      body: Center(
        child: Card(
          elevation: 10.0,
          margin: EdgeInsets.all(15.0),
          child: Container(
            width: 400,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 15.0,
                    ),
                    Text(
                      book.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 23),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Text('Author: ' + book.author.name, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                    Text('Publisher: ' + book.publisher, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                    Text('Rating: ' + book.rating.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 16))
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
                              onPressed: () {},
                              color: Colors.deepPurple,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                SizedBox(
                  height: 32.0,
                ),
                new Text('Comments', style: TextStyle(fontSize: 20)),
                SizedBox(
                  height: 15.0,
                ),
                _buildCommentsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsList(){
    return new Text('No comments to display', style: TextStyle(color: Colors.red));
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


//  @override
//  State<StatefulWidget> createState() {
//    return BookDetailsScreenState();
//  }

}

class ChildItem extends StatelessWidget {
  final Comment comment;

  ChildItem(this.comment);

  @override
  Widget build(BuildContext context) {

    return new ListTile(title: Text(this.comment.author + ' commented on ' + this.comment.datePosted.toString(), style: TextStyle(fontSize: 15)),
        subtitle: Text(this.comment.message, style: TextStyle(fontSize: 15)));
  }
}

//class BookDetailsScreenState extends State<BookDetailsScreen> {
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      drawer: MenuDrawer(),
//      appBar: AppBar(),
//    );
//  }
//}
