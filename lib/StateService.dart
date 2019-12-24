import 'package:rxdart/rxdart.dart';

class StateService {

  BehaviorSubject _loggedInSubject = BehaviorSubject<bool>.seeded(false);

  Stream getLoggedIn() {
    return _loggedInSubject.stream;
  }

  bool isloggedIn() {
    return _loggedInSubject.value;
  }

  void setLoggedIn(bool loggedIn) {
    this._loggedInSubject.add(loggedIn);
  }

}

