class Tag {
  final int id;
  final String name;

  Tag.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  static List<Tag> listFromJson(List jsonList) {
    return jsonList.map((tagJson) => Tag.fromJson(tagJson)).toList();
  }
}