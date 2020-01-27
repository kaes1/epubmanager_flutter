import 'dart:convert';
import 'dart:developer';

import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/StateService.dart';
import 'package:epubmanager_flutter/model/UserInfo.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class AuthenticationService {
  final StateService _stateService = GetIt.instance.get<StateService>();
  final ApiService _apiService = GetIt.instance.get<ApiService>();

  AuthenticationService() {
    _stateService.getCookie().listen((address) {
      _fetchUserInfo();
    });
  }

  Future<Response> login(String username, String password) {
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    log('Trying to login with username: $username, password: $password, authorization: $basicAuth');

    return _apiService
        .getWithBasicAuth(ApiEndpoints.login, basicAuth)
        .then((response) {
      if (response.statusCode == 200) {
        log('Login success!');
        _fetchUserInfo();
        _stateService.setLoggedIn(true);
      } else {
        _stateService.setLoggedIn(false);
      }
      return response;
    });
  }

  void logout() {
    log('Logging out!');
    _apiService.post(ApiEndpoints.logout, null).then((response) {});
    _stateService.setLoggedIn(false);
    _stateService.setUsername('');
    _stateService.setCookie('');
  }

  void _fetchUserInfo() {
    log('Fetching user info!');
    this._apiService.get(ApiEndpoints.userInfo).then((response) {
      UserInfo userInfo = UserInfo.fromJson(response);
      log('Fetched userInfo ${userInfo.username}:${userInfo.loggedIn}');

      _stateService.setUsername(userInfo.username);
      _stateService.setLoggedIn(userInfo.loggedIn);
    });
  }
}
