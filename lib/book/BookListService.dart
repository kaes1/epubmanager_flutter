import 'dart:convert';

import 'package:epubmanager_flutter/ApiService.dart';
import 'package:epubmanager_flutter/model/BookListEdit.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:epubmanager_flutter/model/BooksPage.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:get_it/get_it.dart';
import 'package:epubmanager_flutter/ApiEndpoints.dart';
import 'package:http/http.dart';

class BookListService {
  ApiService apiService = GetIt.instance.get<ApiService>();




  Future<BookListEntry> getBookListEntry(int bookId) {
    return apiService.get(ApiEndpoints.bookList).then((response) {
      return BookListEntry.listFromJson(
          response).firstWhere((entry) => entry.book.id == bookId, orElse: () => null);
    });
  }


  Future<List<BookListEntry>> getBookList() {
    return apiService.get(ApiEndpoints.bookList).then((response) {
        return BookListEntry.listFromJson(
            response);
    });
  }

//  void fetchBookList() {
//    //TODO fetch book list and return OR save in this service.
//    apiService.get(ApiEndpoints.bookList).then((response) {});
//  }


  Future editBookListEntry(int bookId, int rating, String status) {
    BookListEdit bookListEdit = new BookListEdit(bookId, rating, status);
    return apiService.post(ApiEndpoints.bookList, bookListEdit);
  }

  Future<Response> deleteBookListEntry(int bookId) {
    return apiService
        .delete('${ApiEndpoints.bookList}/$bookId');
  }
}
