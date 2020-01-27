import 'dart:convert';
import 'dart:developer';

import 'package:epubmanager_flutter/consts/ApiEndpoints.dart';
import 'package:epubmanager_flutter/services/ApiService.dart';
import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/model/NewBook.dart';
import 'package:epubmanager_flutter/model/Tag.dart';
import 'package:get_it/get_it.dart';

class BookService {
  final ApiService _apiService = GetIt.instance.get<ApiService>();

  Future<BooksPage> findBooks(String title, String author, List<String> tags,
      int pageNumber, int pageSize, String sort, String sortDirection) async {
    Map<String, dynamic> queryParameters = {
      'title': title,
      'author': author,
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'sort': sort,
      'sortDirection': sortDirection,
      'tags': tags
    };

    return _apiService
        .get(ApiEndpoints.booksSearch, queryParameters)
        .then((response) {
      return BooksPage.fromJson(response);
    });
  }

  Future<Book> findExactBook(String title, String author) async {
    Map<String, dynamic> queryParameters = {
      'title': title,
      'author': author,
    };

    return _apiService
        .get(ApiEndpoints.booksSearch, queryParameters)
        .then((response) {
      return Book.fromJson(response);
    });
  }

  Future<Book> getBook(int bookId) async {
    return _apiService
        .get(ApiEndpoints.books + '/' + bookId.toString())
        .then((response) {
      return Book.fromJson(response);
    });
  }

  Future<Book> addBook(NewBook newBook) async {
    log(jsonEncode(newBook));
    return _apiService.post(ApiEndpoints.booksAdd, newBook).then((response) {
      return Book.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    });
  }

  Future<List<Tag>> getAllTags() async {
    return _apiService.get(ApiEndpoints.tags).then((response) {
      return Tag.listFromJson(response);
    });
  }
}
