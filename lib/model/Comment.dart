class Comment {
  final int id;
  final String author;
  final String message;
  final DateTime datePosted;

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        author = json['author'],
        message = json['message'],
        datePosted = json['datePosted'];
}