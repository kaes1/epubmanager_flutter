import 'package:epubmanager_flutter/consts/AppRoutes.dart';
import 'package:epubmanager_flutter/exception/ConnectionException.dart';
import 'package:epubmanager_flutter/screens/NoConnectionDialog.dart';
import 'package:epubmanager_flutter/services/AuthenticationService.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'MenuDrawer.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final AuthenticationService _authService =
      GetIt.instance.get<AuthenticationService>();

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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: RaisedButton(
                                    onPressed: _login,
                                    child: Text('LOGIN',
                                        style: TextStyle(fontSize: 16.0)),
                                  ),
                                ),
                              ],
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
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onTap: _navigateToRegister,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showLoginFailedDialog(BuildContext context) {
    showDialog(
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
                      child: Text("Wrong username or password."),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            child: new Text('OK'),
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

  _login() {
    if (formKey.currentState.validate()) {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();
      _authService
          .login(username, password)
          .then((response) {
            Navigator.pushReplacementNamed(context, AppRoutes.bookList);
          })
          .catchError((error) => NoConnectionDialog.show(context),
              test: (e) => e is ConnectionException)
          .catchError((error) => _showLoginFailedDialog(context));
    }
  }

  _navigateToRegister() {
    Navigator.pushReplacementNamed(context, AppRoutes.register);
  }
}
