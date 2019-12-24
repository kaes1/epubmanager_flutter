class UserInfo {
  final bool loggedIn;
  final String username;

  UserInfo.fromJson(Map<String, dynamic> json)
      : loggedIn = json['loggedIn'],
        username = json['username'];
}
