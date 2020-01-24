import 'package:epubmanager_flutter/model/Book.dart';

class BooksPage {
  final List<Book> content;
  final int totalPages;
  final int totalElements;
  final int size;

  BooksPage.fromJson(Map<String, dynamic> json)
      : content = Book.listFromJson(json['content']),
        totalPages = json['totalPages'],
        totalElements = json['totalElements'],
        size = json['size'];


}