import 'dart:convert';

class NewBook {
  final String title;
  final String author;
  final String publisher;
  final String language;
  final List<String> tagNames;

  NewBook(this.title, this.author, this.publisher, this.language, this.tagNames);

  Map<String, dynamic> toJson() =>
      {
        'title': this.title,
        'author': this.author,
        'publisher': this.publisher,
        'language': this.language,
        'tagNames': this.tagNames
      };
}