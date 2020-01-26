import 'dart:developer';

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StateService {
  BehaviorSubject _loggedInSubject = BehaviorSubject<bool>.seeded(false);
  BehaviorSubject _cookieSubject = BehaviorSubject<String>();
  BehaviorSubject _serverAddressSubject = BehaviorSubject<String>();

  String _username = '';

  StateService() {
    loadSharedPreferences();
  }

  void loadSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setServerAddress(
//KS IP using WIFI in DS Barbara
        sharedPreferences.get('serverAddress') ?? 'http://192.168.0.120:8080');
//oladyr IP using WIFI in DS Barbara
//        sharedPreferences.get('serverAddress') ?? 'http://192.168.0.103:8080');
//oladyr IP using phone as access point
//        sharedPreferences.get('serverAddress') ?? 'http://192.168.43.71:8080');

    setCookie(sharedPreferences.get('cookie') ?? '');
    setUsername(sharedPreferences.get('username') ?? '');
  }

  Stream getLoggedIn() {
    return _loggedInSubject.stream;
  }

  bool isLoggedIn() {
    return _loggedInSubject.value;
  }

  void setLoggedIn(bool loggedIn) {
    _loggedInSubject.add(loggedIn);
  }

  String getUsername() {
    return _username;
  }

  void setUsername(String username) {
    _username = username;
    SharedPreferences.getInstance().then((sharedPreferences) =>
        sharedPreferences.setString('username', username));
  }

  Stream getServerAddress() {
    return _serverAddressSubject.stream;
  }

  void setServerAddress(String serverAddress) {
    if (serverAddress != _serverAddressSubject.value) {
      SharedPreferences.getInstance().then((sharedPreferences) {
        sharedPreferences.setString('serverAddress', serverAddress);
        _serverAddressSubject.add(serverAddress);
      });
    }
  }

  void setCookie(String cookie) {
    if (cookie != _cookieSubject.value) {
      SharedPreferences.getInstance().then((sharedPreferences) {
        sharedPreferences.setString('cookie', cookie);
        _cookieSubject.add(cookie);
      });
    }
  }

  Stream getCookie() {
    return _cookieSubject.stream;
  }
}
