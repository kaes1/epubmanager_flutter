import 'dart:convert';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:get_it/get_it.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:http/http.dart';

class BookListService {
  ApiService apiService = GetIt.instance.get<ApiService>();



  void fetchBookList() {
    //TODO fetch book list and return OR save in this service.
    apiService.get(ApiEndpoints.bookList).then((response) {});
  }


  Future editBookListEntry(int bookId, int rating, Status status) {
    //TODO create bookListEdit DTO
    var bookListEdit = null;
    return apiService.post(ApiEndpoints.bookList, bookListEdit);
  }

  Future<Response> deleteBookListEntry(int bookId) {
    return apiService
        .delete('${ApiEndpoints.bookList}/$bookId');
  }
}
