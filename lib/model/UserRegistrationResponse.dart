class UserRegistrationResponse {
  final bool success;
  final String message;

  UserRegistrationResponse.fromJson(Map<String, dynamic> json)
      : success = json['success'],
        message = json['message'];
}