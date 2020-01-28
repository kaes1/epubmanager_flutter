import 'package:epubmanager_flutter/consts/ApiEndpoints.dart';
import 'package:epubmanager_flutter/model/BookListEdit.dart';
import 'package:epubmanager_flutter/model/BookListEntry.dart';
import 'package:epubmanager_flutter/model/Status.dart';
import 'package:epubmanager_flutter/services/ApiService.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

class BookListService {
  final ApiService _apiService = GetIt.instance.get<ApiService>();

  Future<BookListEntry> getBookListEntry(int bookId) {
    return _apiService.get(ApiEndpoints.bookList).then((response) {
      return BookListEntry.listFromJson(response)
          .firstWhere((entry) => entry.book.id == bookId, orElse: () => null);
    });
  }

  Future<List<BookListEntry>> getBookList() {
    return _apiService.get(ApiEndpoints.bookList).then((response) {
      return BookListEntry.listFromJson(response);
    });
  }

  Future editBookListEntry(int bookId, int rating, Status status) {
    BookListEdit bookListEdit =
        new BookListEdit(bookId, rating, describeEnum(status));
    return _apiService.post(ApiEndpoints.bookList, bookListEdit);
  }

  Future<Response> deleteBookListEntry(int bookId) {
    return _apiService.delete('${ApiEndpoints.bookList}/$bookId');
  }
}
