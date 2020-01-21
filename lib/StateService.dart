import 'package:rxdart/rxdart.dart';

class StateService {

  BehaviorSubject _loggedInSubject = BehaviorSubject<bool>.seeded(false);
  bool registerSuccessfulFlag = false;

  Stream getLoggedIn() {
    return _loggedInSubject.stream;
  }

  bool isloggedIn() {
    return _loggedInSubject.value;
  }

  void setLoggedIn(bool loggedIn) {
    this._loggedInSubject.add(loggedIn);
  }

  void setSuccessfulRegisterFlag(bool state){
    this.registerSuccessfulFlag = state;
  }

  bool getSuccessfulRegisterFlag() {
    return this.registerSuccessfulFlag;
  }
}

