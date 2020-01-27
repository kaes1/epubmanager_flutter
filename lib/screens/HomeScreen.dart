import 'dart:async';
import 'dart:developer';

import 'package:epubmanager_flutter/StateService.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../MenuDrawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final StateService _stateService = GetIt.instance.get<StateService>();

  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    //Refresh state when loggedIn changes.
    _subscription = _stateService.getLoggedIn().listen((loggedIn) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('What would you like to do?'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10.0,
              ),
              if (this._stateService.isLoggedIn())
                RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(
                      text: 'Welcome ',
                      style: TextStyle(fontSize: 20.0, color: Colors.black)),
                  TextSpan(
                      text: _stateService.getUsername(),
                      style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.black,
//                          fontWeight: FontWeight.bold
                      )),
                  TextSpan(
                      text: '!',
                      style: TextStyle(fontSize: 20.0, color: Colors.black))
                ])),
              SizedBox(
                height: 30.0,
              ),
              _createCardItem(Icons.search, 'Browse existing books', '/search'),
              SizedBox(
                height: 15.0,
              ),
              if (this._stateService.isLoggedIn())
                _createCardItem(Icons.note_add, 'Add new book', '/book-upload')
              else
                _createCardItem(Icons.exit_to_app, 'Login', '/login'),
              SizedBox(
                height: 15.0,
              ),
              if (this._stateService.isLoggedIn())
                _createCardItem(
                    Icons.library_books, 'View my list', '/book-list')
              else
                _createCardItem(
                    Icons.person_add, 'Create new account', '/register'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createCardItem(IconData icon, String text, String route) {
    return InkWell(
      splashColor: Colors.grey,
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: GestureDetector(
        child: Card(
          child: SizedBox(
            height: 120,
            width: 300,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20.0,
                ),
                Icon(
                  icon,
                  size: 30.0,
                  color: Colors.black,
                ),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
