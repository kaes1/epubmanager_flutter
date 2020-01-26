import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/AuthenticationService.dart';
import 'package:epubmanager_flutter/book/BookListService.dart';
import 'package:epubmanager_flutter/book/BookService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/screens/BookDetailsScreen.dart';
import 'package:epubmanager_flutter/screens/BookListScreen.dart';
import 'package:epubmanager_flutter/screens/BookSearchScreen.dart';
import 'package:epubmanager_flutter/screens/BookUploadScreen.dart';
import 'package:epubmanager_flutter/screens/HomeScreen.dart';
import 'package:epubmanager_flutter/screens/LoginScreen.dart';
import 'package:epubmanager_flutter/screens/RegisterScreen.dart';
import 'package:epubmanager_flutter/screens/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  //todo remove this line when app is finished.
  WidgetsFlutterBinding.ensureInitialized();
  GetIt.instance.registerSingleton<StateService>(StateService());
  GetIt.instance.registerSingleton<ApiService>(ApiService());
  GetIt.instance.registerSingleton<BookListService>(BookListService());
  GetIt.instance.registerSingleton<BookService>(BookService());
  GetIt.instance.registerSingleton<AuthenticationService>(AuthenticationService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/book-list': (context) => BookListScreen(),
        '/book-upload': (context) => BookUploadScreen(),
        '/search': (context) => BookSearchScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      title: 'epubmanager',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
    );
  }
}
