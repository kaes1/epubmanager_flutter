class UserRegistrationRequest {
  final String username;
  final String password;

  UserRegistrationRequest(this.username, this.password);

  Map<String, dynamic> toJson() =>
      {
        'username': this.username,
        'password': this.password,
      };
}