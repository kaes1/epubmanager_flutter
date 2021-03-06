import 'dart:convert';

import 'package:epubmanager_flutter/consts/ApiEndpoints.dart';
import 'package:epubmanager_flutter/consts/AppRoutes.dart';
import 'package:epubmanager_flutter/exception/ConnectionException.dart';
import 'package:epubmanager_flutter/screens/NoConnectionDialog.dart';
import 'package:epubmanager_flutter/services/ApiService.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../model/UserRegistrationRequest.dart';
import '../model/UserRegistrationResponse.dart';
import 'MenuDrawer.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = GetIt.instance.get<ApiService>();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  final _minPasswordLength = 5;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
        title: Text('Create your account'),
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
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _usernameController,
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
                                controller: _passwordController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock),
                                    labelText: 'Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Password cannot be empty';
                                  else if (value.length < _minPasswordLength)
                                    return 'Password needs to be at least 5 characters long';
                                  else
                                    return null;
                                }),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                                controller: _passwordConfirmController,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.lock),
                                    labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value != _passwordController.text)
                                    return 'Passwords do not match';
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
                                    onPressed: _register,
                                    child: Text('REGISTER',
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
                Expanded(child: Text("Already have an account?")),
                GestureDetector(
                  child: Text("Login",
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onTap: _navigateToLogin,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRegistrationDialog(String title, String message, bool goToLogin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
                if (goToLogin) _navigateToLogin();
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  _register() {
    if (_formKey.currentState.validate()) {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      UserRegistrationRequest userRegistrationRequest =
          new UserRegistrationRequest(username, password);
      _apiService
          .post(ApiEndpoints.register, userRegistrationRequest)
          .then((response) {
        UserRegistrationResponse userRegistrationResponse =
            new UserRegistrationResponse.fromJson(
                json.decode(utf8.decode(response.bodyBytes)));
        if (userRegistrationResponse.success) {
          _showRegistrationDialog('Registration succedded',
              '${userRegistrationResponse.message}', true);
        } else {
          _showRegistrationDialog('Registration failed',
              '${userRegistrationResponse.message}', false);
        }
      }).catchError((error) => NoConnectionDialog.show(context),
              test: (e) => e is ConnectionException);
    }
  }
}
