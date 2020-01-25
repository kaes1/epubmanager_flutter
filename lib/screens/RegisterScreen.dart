import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:developer';
import '../MenuDrawer.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:epubmanager_flutter/ApiService.dart';
import 'package:get_it/get_it.dart';
import '../model/UserRegistrationRequest.dart';
import '../model/UserRegistrationResponse.dart';


class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen> {
  ApiService apiService = GetIt.instance.get<ApiService>();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    passwordConfirmController.dispose();
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
                            TextFormField(
                                controller: passwordConfirmController,
                                decoration: InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value != passwordController.text)
                                    return 'Passwords do not match';
                                  else
                                    return null;
                                }),
                            SizedBox(
                              height: 15.0,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(30.0),
                              child: MaterialButton(
                                onPressed: register,
                                color: Colors.deepPurple,
                                minWidth: 200,
                                child: Text(
                                  'REGISTER',
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
                Expanded(child: Text("Already have an account?")),
                GestureDetector(
                  child: Text( "Login",
                      style: TextStyle(color: Colors.deepPurple)),
                  onTap: login,
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
                if(goToLogin)
                 login();
              },
            ),
          ],
        );
      },
    );
  }

  login(){
    log('Navigate to /login');
    Navigator.pushReplacementNamed(context, '/login');
  }

  register(){
    if (formKey.currentState.validate()) {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();

      UserRegistrationRequest userRegistrationRequest = new UserRegistrationRequest(username, password);
      apiService.post(ApiEndpoints.register, userRegistrationRequest)
          .then((response) {
        UserRegistrationResponse userRegistrationResponse = new UserRegistrationResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
        if (userRegistrationResponse.success) {
          _showRegistrationDialog('Registration succedded' ,'${userRegistrationResponse.message}', true);
        } else {
          _showRegistrationDialog('Registration failed' ,'${userRegistrationResponse.message}', false);
        }
      });

    }
  }
}
