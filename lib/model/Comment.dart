class Comment {
  final int id;
  final String author;
  final String message;
  final String datePosted;

  Comment.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        author = json['author'],
        message = json['message'],
        datePosted = (json['datePosted']).toString().substring(0,10);

  static List<Comment> listFromJson(List jsonList) {
    return jsonList.map((tagJson) => Comment.fromJson(tagJson)).toList();
  }
}