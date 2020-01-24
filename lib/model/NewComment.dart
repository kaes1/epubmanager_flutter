class NewComment {
  final int bookId;
  final String message;

  NewComment.fromJson(Map<String, dynamic> json)
      : bookId = json['bookId'],
        message = json['message'];
}