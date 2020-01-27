import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:epubmanager_flutter/StateService.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final StateService _stateService = GetIt.instance.get<StateService>();

  //KS IP
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

  //todo handle bad responses (401, 403 etc)

  Future<dynamic> get(String path,
      [Map<String, dynamic> queryParameters]) async {
    log('ApiService get for $path called!');
    try {
      final Response response = await http
          .get(
              _serverUri.resolveUri(
                  Uri(path: path, queryParameters: queryParameters)),
              headers: _headers)
          .timeout(Duration(seconds: 3));
      _updateCookieHeader(response);

      log('ApiService get response status code: ${response.statusCode}');

      if (response.statusCode == HttpStatus.forbidden ||
          response.statusCode == HttpStatus.unauthorized) {
        log('Detected ${response.statusCode}!');
        _stateService.setLoggedIn(false);
        return Future.error('Authorization error ${response.statusCode}');
      }

      if (response.statusCode > 400) {
        log('Detected ${response.statusCode}!');
        return Future.error('Error ${response.statusCode}');
      }
      return json.decode(utf8.decode(response.bodyBytes));
    } on SocketException catch (exception) {
      log('Detected ${exception.toString()}!');
      return Future.error('SocketException for $path');
    } on TimeoutException catch (exception) {
      log('Detected ${exception.toString()}!');
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
    final Response response = await http
        .post(_serverUri.resolve(path),
            headers: _headers, body: jsonEncode(body))
        .timeout(Duration(seconds: 3));
    _updateCookieHeader(response);

    if (response.statusCode == HttpStatus.forbidden ||
        response.statusCode == HttpStatus.unauthorized) {
      log('Detected ${response.statusCode}!');
      _stateService.setLoggedIn(false);
      return Future.error('Authorization error ${response.statusCode}');
    }

    if (response.statusCode >= 400) {
      log('Detected ${response.statusCode}!');
      return Future.error('Error ${response.statusCode}');
    }

    return json.decode(utf8.decode(response.bodyBytes));
  }

  Future<dynamic> delete(String path) async {
    final Response response = await http
        .delete(_serverUri.resolve(path), headers: _headers)
        .timeout(Duration(seconds: 3));
    _updateCookieHeader(response);
    return json.decode(utf8.decode(response.bodyBytes));
  }
}
