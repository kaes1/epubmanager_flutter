import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class ApiService {
  //oladyr IP using WIFI in DS Barbara
  //final Uri serverUri = Uri.parse('http://192.168.0.103:8080');
  //oladyr IP using phone as access point
  final Uri serverUri = Uri.parse('http://192.168.43.71:8080');

  //KS IP
  //final Uri serverUri = Uri.parse('http://192.168.0.120:8080');

  Map<String, String> _headers = {"content-type" : "application/json"};

  void _updateHeaders(Response response) {
    String setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      int index = setCookie.indexOf(';');
      _headers['cookie'] =
          (index != -1) ? setCookie.substring(0, index) : setCookie;
    }
  }

  //todo handle bad responses (401, 403 etc)

  Future<Response> get(String path, [Map<String, dynamic> queryParameters]) async {
    final Response response = await http.get(
        serverUri.resolveUri(Uri(path: path, queryParameters: queryParameters)),
        headers: _headers);
    _updateHeaders(response);
    return response;
  }

  Future<Response> getWithBasicAuth(String path, String basicAuth) async {
    Map<String, String> headers = Map.from(_headers);
    headers['authorization'] = basicAuth;
    final Response response =
        await http.get(serverUri.resolve(path), headers: headers);
    _updateHeaders(response);
    return response;
  }

  Future<Response> post(String path, body) async {
    _headers.forEach((key,value) => log(key +':'+value) );
    final Response response =
        await http.post(serverUri.resolve(path), headers: _headers, body: jsonEncode(body));
    _updateHeaders(response);
    return response;
  }

  Future<Response> delete(String path) async {
    final Response response =
        await http.delete(serverUri.resolve(path), headers: {});
    _updateHeaders(response);
    return response;
  }
}
