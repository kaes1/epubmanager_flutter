import 'package:flutter/material.dart';
import 'dart:developer';
import '../MenuDrawer.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen> {
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

  login(){
    log('Navigate to /login');
    Navigator.pushReplacementNamed(context, '/login');
  }

  register(){
    if (formKey.currentState.validate()) {
      String username = usernameController.text.trim();
      String password = passwordController.text.trim();
    }
  }
}
