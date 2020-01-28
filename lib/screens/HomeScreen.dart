import 'dart:async';

import 'package:epubmanager_flutter/consts/AppRoutes.dart';
import 'package:epubmanager_flutter/services/StateService.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'MenuDrawer.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final StateService _stateService = GetIt.instance.get<StateService>();

  StreamSubscription _loggedInSubscription;
  StreamSubscription _serverAddressSubscription;

  String _serverAddress;

  @override
  void initState() {
    super.initState();
    //Refresh state when loggedIn changes.
    _loggedInSubscription =
        _stateService.getLoggedIn().listen((loggedIn) => setState(() {}));

    _serverAddressSubscription = _stateService.getServerAddress().listen(
        (serverAddress) => setState(() => _serverAddress = serverAddress));
  }

  @override
  void dispose() {
    super.dispose();
    _loggedInSubscription.cancel();
    _serverAddressSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: MenuDrawer(),
        appBar: AppBar(
          title: (_serverAddress == null || _serverAddress.isEmpty)
              ? Text('No server connection!')
              : Text('What would you like to do?'),
        ),
        body: (_serverAddress == null || _serverAddress.isEmpty)
            ? _noServerAddressBody()
            : _actionCardsBody());
  }

  _noServerAddressBody() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
          child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
            ),
            children: [
              TextSpan(text: 'Please set server address in '),
              TextSpan(
                  text: 'settings ',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    }),
              WidgetSpan(
                  child: Icon(Icons.settings,
                      color: Theme.of(context).primaryColor)),
              TextSpan(text: '.'),
            ]),
      )),
    );
  }

  _actionCardsBody() {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: ListView(
        children: <Widget>[
          if (this._stateService.isLoggedIn())
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 30),
                child: Text('Welcome ${_stateService.getUsername()}!',
                    style: TextStyle(fontSize: 20.0, color: Colors.black)),
              ),
            ),
          _createCardItem(Icons.search, 'Browse existing books', '/search'),
          if (this._stateService.isLoggedIn())
            _createCardItem(Icons.note_add, 'Add new book', '/book-upload')
          else
            _createCardItem(Icons.exit_to_app, 'Login', '/login'),
          if (this._stateService.isLoggedIn())
            _createCardItem(Icons.library_books, 'View my list', '/book-list')
          else
            _createCardItem(
                Icons.person_add, 'Create new account', '/register'),
        ],
      ),
    );
  }

  Widget _createCardItem(IconData icon, String text, String route) {
    return InkWell(
      splashColor: Colors.grey,
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: GestureDetector(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        icon,
                        size: 30.0,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
