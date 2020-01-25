class NewComment {
  final int bookId;
  final String message;

  NewComment(this.bookId, this.message);

  Map<String, dynamic> toJson() =>
      {
        'bookId': this.bookId,
        'message': this.message,
      };
}