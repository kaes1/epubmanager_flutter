import 'package:flutter/material.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:get_it/get_it.dart';
import 'dart:developer';
import '../MenuDrawer.dart';


class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}


class HomeScreenState extends State<HomeScreen> {
  final StateService stateService = GetIt.instance.get<StateService>();

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
            children: <Widget> [
              SizedBox(
                height: 30.0,
              ),
              _createCardItem(Icons.search, 'Browse existing books', '/search'),
              SizedBox(
                height: 15.0,
              ),
              if (this.stateService.isloggedIn())
                _createCardItem(Icons.note_add, 'Add new book', '/book-upload')
              else
                _createCardItem(Icons.exit_to_app, 'Login', '/login'),
              SizedBox(
                height: 15.0,
              ),
              if (this.stateService.isloggedIn())
                _createCardItem(Icons.library_books, 'View my list', '/book-list')
              else
                _createCardItem(Icons.person_add, 'Create new account', '/register'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createCardItem(IconData icon, String text, String route) {
    return InkWell(
      splashColor: Colors.grey,
      onTap: (){
        log('Navigate to $route');
        Navigator.pushReplacementNamed(context, route);
      },
      child: GestureDetector(
        child: Card(
          child: SizedBox(
            height: 120,
            width: 300,
            child: Column(
              children: <Widget> [
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