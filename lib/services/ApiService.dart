import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:epubmanager_flutter/exception/ConnectionException.dart';
import 'package:epubmanager_flutter/services/StateService.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final StateService _stateService = GetIt.instance.get<StateService>();

  final Duration _timeoutDuration = Duration(seconds: 3);

  Uri _serverUri;
  Map<String, String> _headers = {"content-type": "application/json"};

  ApiService() {
    _stateService
        .getServerAddress()
        .listen((serverAddress) => _serverUri = Uri.parse(serverAddress));
    _stateService.getSessionCookie().listen((cookie) => _headers['cookie'] = cookie);
  }

  void _updateCookieHeader(Response response) {
    String setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      int index = setCookie.indexOf(';');
      _stateService
          .setSessionCookie((index != -1) ? setCookie.substring(0, index) : setCookie);
    }
  }

  void _handleHttpErrors(Response response) {
    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      _stateService.setLoggedIn(false);
      throw 'Authorization error ${response.statusCode}';
    }

    if (response.statusCode >= 400) {
      throw 'Error ${response.statusCode}';
    }
  }

  Future<dynamic> get(String path,
      [Map<String, dynamic> queryParameters]) async {
    log('ApiService get for $path called.');
    try {
      Response response = await http.get(_serverUri.resolveUri(
          Uri(path: path, queryParameters: queryParameters)), headers: _headers)
          .timeout(Duration(seconds: 3));
      _updateCookieHeader(response);
      _handleHttpErrors(response);
      return json.decode(utf8.decode(response.bodyBytes));
    } catch (e) {
      return Future.error(ConnectionException());
    }
  }

  Future<Response> getWithBasicAuth(String path, String basicAuth) async {
    Map<String, String> headers = Map.from(_headers);
    headers['authorization'] = basicAuth;
    try {
      Response response = await http
          .get(_serverUri.resolve(path), headers: headers)
          .timeout(_timeoutDuration);
      _updateCookieHeader(response);
      _handleHttpErrors(response);
      return response;
    } catch (e) {
      return Future.error(ConnectionException());
    }
  }

  Future<Response> post(String path, body) async {
    log('ApiService post for $path called.');

    try {
      Response response = await http
          .post(_serverUri.resolve(path),
          headers: _headers, body: jsonEncode(body))
          .timeout(_timeoutDuration);
      _updateCookieHeader(response);
      _handleHttpErrors(response);
      return response;
    } catch (e) {
      return Future.error(ConnectionException());
    }
  }

  Future<Response> delete(String path) async {
    try {
      Response response = await http
          .delete(_serverUri.resolve(path), headers: _headers)
          .timeout(_timeoutDuration);
      _updateCookieHeader(response);
      _handleHttpErrors(response);
      return response;
    } catch (e) {
      return Future.error(ConnectionException());
    }
  }

}
