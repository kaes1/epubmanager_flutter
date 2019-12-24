import 'package:epubmanager_flutter/model/Author.dart';
import 'package:epubmanager_flutter/model/Tag.dart';

class Book {
  final int id;
  final String title;
  final Author author;
  final int numberOfRatings;
  final double rating;
  final String publisher;
  final List<Tag> tags;

  Book.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        author = Author.fromJson(json['author']),
        numberOfRatings = json['numberOfRatings'],
        rating = json['rating'],
        publisher = json['publisher'],
        tags = Tag.listFromJson(json['tags']);

  static List<Book> listFromJson(List jsonList) {
    return jsonList.map((tagJson) => Book.fromJson(tagJson)).toList();
  }
}
