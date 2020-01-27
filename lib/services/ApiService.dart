import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:epubmanager_flutter/services/StateService.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final StateService _stateService = GetIt.instance.get<StateService>();

  Uri _serverUri;
  Map<String, String> _headers = {"content-type": "application/json"};

  ApiService() {
    _stateService
        .getServerAddress()
        .listen((serverAddress) => _serverUri = Uri.parse(serverAddress));
    _stateService.getCookie().listen((cookie) => _headers['cookie'] = cookie);
  }

  void _updateCookieHeader(Response response) {
    String setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      int index = setCookie.indexOf(';');
      _stateService
          .setCookie((index != -1) ? setCookie.substring(0, index) : setCookie);
    }
  }

  Future<dynamic> get(String path,
      [Map<String, dynamic> queryParameters]) async {
    log('ApiService get for $path called.');
    try {
      final Response response = await http
          .get(
              _serverUri.resolveUri(
                  Uri(path: path, queryParameters: queryParameters)),
              headers: _headers)
          .timeout(Duration(seconds: 3));
      _updateCookieHeader(response);

      if (response.statusCode == HttpStatus.forbidden ||
          response.statusCode == HttpStatus.unauthorized) {
        _stateService.setLoggedIn(false);
        return Future.error('Authorization error ${response.statusCode}');
      }

      if (response.statusCode > 400) {
        return Future.error('Error ${response.statusCode}');
      }
      return json.decode(utf8.decode(response.bodyBytes));
    } on SocketException {
      return Future.error('SocketException for $path');
    } on TimeoutException {
      return Future.error('TimeoutException for $path');
    }
  }

  Future<Response> getWithBasicAuth(String path, String basicAuth) async {
    Map<String, String> headers = Map.from(_headers);
    headers['authorization'] = basicAuth;
    final Response response = await http
        .get(_serverUri.resolve(path), headers: headers)
        .timeout(Duration(seconds: 3));
    _updateCookieHeader(response);
    return response;
  }

  Future<dynamic> post(String path, body) async {
    log('ApiService post for $path called.');
    final Response response = await http
        .post(_serverUri.resolve(path),
            headers: _headers, body: jsonEncode(body))
        .timeout(Duration(seconds: 3));
    _updateCookieHeader(response);

    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      _stateService.setLoggedIn(false);
      return Future.error('Authorization error ${response.statusCode}');
    }

    if (response.statusCode >= 400) {
      return Future.error('Error ${response.statusCode}');
    }

    return response;
  }

  Future<Response> delete(String path) async {
    final Response response = await http
        .delete(_serverUri.resolve(path), headers: _headers)
        .timeout(Duration(seconds: 3));
    _updateCookieHeader(response);
    return response;
  }
}
