import 'package:rxdart/rxdart.dart';

class StateService {

  BehaviorSubject _loggedInSubject = BehaviorSubject<bool>.seeded(false);
  bool _registerSuccessfulFlag = false;

  String _username = '';

  Stream getLoggedIn() {
    return _loggedInSubject.stream;
  }

  bool isloggedIn() {
    return _loggedInSubject.value;
  }

  void setLoggedIn(bool loggedIn) {
    _loggedInSubject.add(loggedIn);
  }

  void setUsername(String username) {
     _username = username;
  }

  String getUsername() {
    return _username;
  }

  void setSuccessfulRegisterFlag(bool state){
    _registerSuccessfulFlag = state;
  }

  bool getSuccessfulRegisterFlag() {
    return _registerSuccessfulFlag;
  }
}

