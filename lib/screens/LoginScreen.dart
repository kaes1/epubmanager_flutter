import 'dart:convert';
import 'dart:developer';

import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
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
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  ApiService apiService = GetIt.instance.get<ApiService>();
  final StateService stateService = GetIt.instance.get<StateService>();

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
                                decoration: InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Username'),
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
                                  decoration: InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Password'),
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
                      child: Text( "Register",
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

  login() {
    if (formKey.currentState.validate()) {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();
      String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));
      log('Trying to login with username: ${username}, password: ${password}, authorization: $basicAuth');

      apiService
          .getWithBasicAuth(ApiEndpoints.login, basicAuth)
          .then((response) {
        log('StatusCode: ${response.statusCode}');
        if (response.statusCode == 200) {
          stateService.setLoggedIn(true);
          log('Login success!');
          Navigator.pushReplacementNamed(context, '/book-list');
        } else {
          stateService.setLoggedIn(false);
        }
      });
    }
  }

  register(){
    log('Navigate to /register');
    Navigator.pushReplacementNamed(context, '/register');
  }

  logout() {
    apiService.post(ApiEndpoints.logout, null).then((response) {
      log('StatusCode for logout: ${response.statusCode}');
      stateService.setLoggedIn(false);
    });
  }

}
