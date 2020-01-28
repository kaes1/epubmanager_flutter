import 'package:epubmanager_flutter/consts/AppRoutes.dart';
import 'package:epubmanager_flutter/screens/BookListScreen.dart';
import 'package:epubmanager_flutter/screens/BookSearchScreen.dart';
import 'package:epubmanager_flutter/screens/BookUploadScreen.dart';
import 'package:epubmanager_flutter/screens/HomeScreen.dart';
import 'package:epubmanager_flutter/screens/LoginScreen.dart';
import 'package:epubmanager_flutter/screens/RegisterScreen.dart';
import 'package:epubmanager_flutter/screens/SettingsScreen.dart';
import 'package:epubmanager_flutter/services/ApiService.dart';
import 'package:epubmanager_flutter/services/AuthenticationService.dart';
import 'package:epubmanager_flutter/services/BookListService.dart';
import 'package:epubmanager_flutter/services/BookService.dart';
import 'package:epubmanager_flutter/services/StateService.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
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
        AppRoutes.home: (context) => HomeScreen(),
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.register: (context) => RegisterScreen(),
        AppRoutes.bookList: (context) => BookListScreen(),
        AppRoutes.bookUpload: (context) => BookUploadScreen(),
        AppRoutes.search: (context) => BookSearchScreen(),
        AppRoutes.settings: (context) => SettingsScreen(),
      },
      title: 'epubmanager',
      theme: ThemeData(
          primaryColor: Colors.deepPurple,
          buttonTheme: ButtonThemeData(
              buttonColor: Colors.deepPurple,
              textTheme: ButtonTextTheme.primary)),
      navigatorObservers: <NavigatorObserver>[routeObserver],
    );
  }
}
