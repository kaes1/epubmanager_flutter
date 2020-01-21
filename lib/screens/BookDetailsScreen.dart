import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../MenuDrawer.dart';

class BookDetailsScreen extends StatelessWidget {
  //todo retrieve bookListEntry for logged in user (if logged in) and display values.
  StateService stateService = GetIt.instance.get<StateService>();

  //todo pass bookId and retrieve book from api??
  final Book book;

  final _possibleRatings = [10, 9, 8, 7, 6, 5, 4, 3, 2, 1];

  BookDetailsScreen({@required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book details')),
      body: Card(
        elevation: 10.0,
        margin: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  book.title,
                  style: TextStyle(fontSize: 20),
                ),
                Text('Author: ' + book.author.name),
                Text('Publisher: ' + book.publisher),
                Text('Rating: ' + book.rating.toString())
              ],
            ),
            if (stateService.isloggedIn())
              Column(
                children: <Widget>[
                  Text('Add to list'),
                  Row(
                    children: <Widget>[
                      Text('Status: '),
                      DropdownButton(
                        items: Status.values.map((status) {
                          return DropdownMenuItem(
                              child: Text(status.toString()), value: status);
                        }).toList(),
                        onChanged: (value) {},
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text('Your rating: '),
                      DropdownButton(
                        items: _possibleRatings.map((rating) {
                          return DropdownMenuItem(
                              child: Text(rating.toString()), value: rating);
                        }).toList(),
                        onChanged: (value) {},
                      )
                    ],
                  ),
                  RaisedButton(
                    onPressed: () {},
                  )
                ],
              )
          ],
        ),
      ),
    );
  }

//  @override
//  State<StatefulWidget> createState() {
//    return BookDetailsScreenState();
//  }

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
