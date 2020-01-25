class BookListEdit {
  final int bookId;
  final int rating;
  final String status;

  BookListEdit(this.bookId, this.rating, this.status);

  Map<String, dynamic> toJson() =>
      {
        'bookId': this.bookId,
        'rating': this.rating,
        'status': this.status,
      };
}