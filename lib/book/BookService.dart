import 'dart:convert';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:get_it/get_it.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart';

class BookService {
  ApiService apiService = GetIt.instance.get<ApiService>();




  Future<BooksPage> findBooks(String title, String author, List<String> tags, int pageNumber,
      int pageSize, String sort, String sortDirection) {
    Map<String, dynamic> queryParameters = {
      'title': title,
      'author': author,
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'sort': sort,
      'sortDirection': sortDirection,
      'tags': tags
    };

    return apiService
        .get(ApiEndpoints.booksSearch, queryParameters)
        .then((response) {
          return BooksPage.fromJson(response);
        });
  }
}
