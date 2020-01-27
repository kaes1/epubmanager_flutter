import 'dart:developer';

import 'package:epubmanager_flutter/AuthenticationService.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../MenuDrawer.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final AuthenticationService _authService =
  GetIt.instance.get<AuthenticationService>();

  //TODO display message when login not successful.
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuDrawer(),
      appBar: AppBar(
        title: Text('Please login'),
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(15.0),
          children: <Widget>[
            Center(
              child: Card(
                  elevation: 8.0,
                  margin: EdgeInsets.all(15.0),
                  child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  labelText: 'Username'),
                              validator: (value) {
                                if (value.isEmpty)
                                  return 'Username cannot be empty';
                                else
                                  return null;
                              },
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock),
                                    labelText: 'Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Password cannot be empty';
                                  else if (value.length < 3)
                                    return 'Password needs to be at least 3 characters long';
                                  else
                                    return null;
                                }),
                            SizedBox(
                              height: 15.0,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(30.0),
                              child: MaterialButton(
                                onPressed: login,
                                color: Colors.deepPurple,
                                minWidth: 200,
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ))),
            ),
            SizedBox(
              height: 25.0,
            ),
            Row(
              children: <Widget>[
                Expanded(child: Text("Don't have an account?")),
                GestureDetector(
                  child: Text("Register",
                      style: TextStyle(color: Colors.deepPurple)),
                  onTap: register,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _loginFailedDialog(BuildContext context) async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Login failed',
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
                      child:  Text("Wrong username or password."),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: new Text('OK'),
                            color: Colors.deepPurple,
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        });
  }

  login() {
    if (formKey.currentState.validate()) {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();
      _authService.login(username, password).then((response) {
        if (response.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/book-list');
        } else {
          _loginFailedDialog(context);
        }
      });
    }
  }

  register() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  logout() {
    _authService.logout();
  }
}
