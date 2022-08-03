import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:totem/models/index.dart';
import 'package:totem/services/index.dart';

class UserAccountStateProvider {
  StreamSubscription? _authStateSubscription;
  StreamSubscription? _userProfileSubscription;
  StreamSubscription? _accountStateSubscription;
  final TotemRepository repository;
  late BehaviorSubject<UserAuthAccountState> streamController;
  UserAuthAccountState _currentState = const UserAuthAccountState();

  UserAccountStateProvider(
      {required Stream<AuthUser?> authStream, required this.repository}) {
    streamController = BehaviorSubject<UserAuthAccountState>();
    streamController.add(_currentState);
    _authStateSubscription = authStream.listen((authUser) {
      if (authUser != null) {
        // fetch the user profile data
        _userProfileSubscription =
            repository.userProfileStream().listen((userProfile) {
          _currentState = _currentState.copyWith(userProfile: userProfile);
          if (_currentState.isLoggedIn) {
            streamController.add(_currentState);
          }
        });
        _accountStateSubscription =
            repository.userAccountStateStream().listen((accountState) {
          _currentState = _currentState.copyWith(accountState: accountState);
          if (_currentState.isLoggedIn) {
            streamController.add(_currentState);
          }
        });
      } else {
        _userProfileSubscription?.cancel();
        _accountStateSubscription?.cancel();
        _currentState = const UserAuthAccountState();
        streamController.add(_currentState);
      }
    });
  }

  void dispose() {
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    _accountStateSubscription?.cancel();
    streamController.close();
  }

  Stream<UserAuthAccountState> get stream => streamController.stream;
}
