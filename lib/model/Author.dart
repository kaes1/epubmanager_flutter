class Author {
  final int id;
  final String name;

  Author.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
