import 'dart:developer';

import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MenuDrawer extends StatelessWidget {
  final StateService _stateService = GetIt.instance.get<StateService>();
  final ApiService _apiService = GetIt.instance.get<ApiService>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 60,
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.book,
                            color: Colors.white,
                            size: 40,
                          ),
                          Text(
                            'epubmanager',
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          )
                        ])
                  ]),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),
          ),
          if (this._stateService.isloggedIn())
            _createDrawerHeader(Icons.account_circle, 'Logged in as ${_stateService.getUsername()}')
          else
            _createDrawerHeader(Icons.help_outline, 'Not logged in'),
          _createDrawerItem(Icons.home, 'Home', () => _navigate('/', context)),
          _divider(),
          _createDrawerItem(Icons.search, 'Browse books', () => _navigate('/search', context)),
          _divider(),
          if (this._stateService.isloggedIn())
            _createDrawerItem(
                Icons.note_add, 'Add book', () => _navigate('/book-upload', context)),
          if (this._stateService.isloggedIn()) _divider(),
          if (this._stateService.isloggedIn())
            _createDrawerItem(Icons.list, 'My List', () => _navigate('/book-list', context)),
          if (this._stateService.isloggedIn()) _divider(),
          if (!this._stateService.isloggedIn())
            _createDrawerItem(Icons.exit_to_app, 'Login', () => _navigate('/login', context))
          else
            _createDrawerItem(Icons.exit_to_app, 'Logout', () => _logout(context)),
          _divider(),
          if (!this._stateService.isloggedIn())
            _createDrawerItem(
                Icons.person_add, 'Register',() => _navigate('/register', context)),
          if (!this._stateService.isloggedIn()) _divider(),
        ],
      ),
    );
  }

  Divider _divider() {
    return Divider(thickness: 1);
  }

  Widget _createDrawerHeader(IconData icon, String text) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: new CircleAvatar(
          backgroundColor: Colors.white,
          //backgroundColor: Colors.deepPurple,
          child: new Icon(
            icon,
            color: Colors.deepPurple[400],
            //color:Colors.white,
            size: 70,
          )),
      accountName: Text(
        text,
        style: TextStyle(
            color: Colors.white,
            //color: Colors.black,
            fontSize: 18),
      ),
      decoration: BoxDecoration(color: Colors.deepPurple[400]),
    );
  }

  Widget _createDrawerItem(
      IconData icon, String text, Function onTap) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
      onTap: onTap
    );
  }

  _navigate(String route, BuildContext context) {
    log('Navigate to $route');
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, route);
  }

  Function _logout(BuildContext context) {
    //todo add apiservice things
    _apiService.post(ApiEndpoints.logout, null).then((response) {});

    _apiService.forgetSessionCookie();
    _stateService.setUsername('');
    _stateService.setLoggedIn(false);

    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, '/login');

  }
}
