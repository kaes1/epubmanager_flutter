import 'dart:developer';
import 'dart:ffi';
import 'package:get_it/get_it.dart';

import 'package:epubmanager_flutter/StateService.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  final StateService stateService = GetIt.instance.get<StateService>();

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
          if (this.stateService.isloggedIn())
            _createDrawerHeader(Icons.account_circle, 'Logged in as ')
          else
            _createDrawerHeader(Icons.help_outline, 'Not logged in'),
          _createDrawerItem(Icons.home, 'Home', '/', context),
          divider(),
          _createDrawerItem(Icons.search, 'Browse books', '/search', context),
          divider(),
          if (!this.stateService.isloggedIn())
            _createDrawerItem(Icons.exit_to_app, 'Login', '/login', context)
          else
            _createDrawerItem(Icons.exit_to_app, 'Logout', '/login', context),
          divider(),
          if (!this.stateService.isloggedIn())
            _createDrawerItem(Icons.person_add, 'Register', '/register', context),
          if (!this.stateService.isloggedIn()) divider(),
          if (this.stateService.isloggedIn())
            _createDrawerItem(
                Icons.note_add, 'Add book', '/book-upload', context),
          if (this.stateService.isloggedIn()) divider(),
          if (this.stateService.isloggedIn())
            _createDrawerItem(Icons.list, 'My List', '/book-list', context),
          if (this.stateService.isloggedIn()) divider(),
        ],
      ),
    );
  }

  Divider divider() {
    return Divider(thickness: 1);
  }

  Widget _createDrawerHeader(IconData icon, String text){
    return UserAccountsDrawerHeader(
      currentAccountPicture: new CircleAvatar(
          backgroundColor: Colors.white,
          //backgroundColor: Colors.deepPurple,
          child: new Icon(
            icon,
            color: Colors.deepPurple[400],
            //color:Colors.white,
            size: 70,
          )
      ),
      accountName: Text(
        text,
        style: TextStyle(
            color: Colors.white,
            //color: Colors.black,
            fontSize: 18
        ),
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple[400]
      ),
    );
  }

  Widget _createDrawerItem(
      IconData icon, String text, String route, BuildContext context) {
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
      onTap: () {
        log('Navigate to $route');
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}
