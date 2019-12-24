import 'dart:developer';

import 'package:epubmanager_flutter/model/Book.dart';

class BookListEntry {
  final Book book;
  final int rating;
  final String status; //todo change to enum

  BookListEntry.fromJson(Map<String, dynamic> json)
      : status = json['status'],
        book = Book.fromJson(json['book']),
        rating = json['rating'];

  static List<BookListEntry> listFromJson(List jsonList) {
    log('listFromJson called');
    return jsonList.map((tagJson) => BookListEntry.fromJson(tagJson)).toList();
  }
}