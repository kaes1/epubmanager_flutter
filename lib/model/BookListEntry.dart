import 'dart:developer';

import 'package:epubmanager_flutter/model/Book.dart';
import 'package:epubmanager_flutter/model/Status.dart';

class BookListEntry {
  final Book book;
  final int rating;
  final Status status;

  BookListEntry.fromJson(Map<String, dynamic> json)
      : status = statusFromString(json['status']),
        book = Book.fromJson(json['book']),
        rating = json['rating'];

  static List<BookListEntry> listFromJson(List jsonList) {
    return jsonList.map((tagJson) => BookListEntry.fromJson(tagJson)).toList();
  }
}