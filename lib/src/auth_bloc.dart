import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:passwordless_demo/src/auth_validators.dart';
import 'package:passwordless_demo/src/constants.dart';
import 'package:passwordless_demo/src/repository.dart';
import 'package:rxdart/rxdart.dart';

// Define all possible states for the auth form.
enum AuthStatus { emailAuth, phoneAuth, emailLinkSent, smsSent, isLoading }

class AuthBloc with AuthValidators {
  final _repository = Repository();
  final _email = BehaviorSubject<String>();
  final _dialCode = BehaviorSubject<String>();
  final _phone = BehaviorSubject<String>();
  final _authStatus = BehaviorSubject<AuthStatus>();
  final _verificationId = BehaviorSubject<String>();

// Add data to stream, validate inputs
  Observable<String> get email => _email.stream.transform(validateEmail);
  Observable<String> get phone => _phone.stream.transform(validatePhone);
  Observable<String> get dialCode => _dialCode.stream;
  Observable<String> get verificationID => _verificationId.stream;
  Observable<AuthStatus> get authStatus => _authStatus.stream;

// get value
  String get getEmail => _email.value;
  String get getPhone => _phone.value;
  String get getDialCode => _dialCode.value;
  String get getVerificationId => _verificationId.value;
  AuthStatus get getAuthStatus => _authStatus.value;

// change data
  Function(String) get changeEmail => _email.sink.add;
  Function(String) get changePhone => _phone.sink.add;
  Function(String) get changeDialCode => _dialCode.sink.add;
  Function(String) get changeVerificationId => _verificationId.sink.add;
  Function(AuthStatus) get changeAuthStatus => _authStatus.sink.add;

// remove accidental spaces from the input
  Future<void> sendSignInWithEmailLink() {
    return _repository
        .sendSignInWithEmailLink(_email.value.replaceAll(" ", ""));
  }

  Future<AuthResult> signInWIthEmailLink(email, link) {
    return _repository.signInWithEmailLink(email, link);
  }

  Future<FirebaseUser> getCurrentUser() {
    return _repository.getCurrentUser();
  }

  Future<void> storeUserEmail() {
    return _repository.setEmail(_email.value.replaceAll(" ", ""));
  }

  Future<void> clearUserEmailFromStorage() {
    return _repository.clearEmail();
  }

  Future<String> getUserEmailFromStorage() {
    return _repository.getEmail();
  }

  Future<AuthResult> signInWithCredential(AuthCredential credential) {
    return _repository.signInWithCredential(credential);
  }

  Future<void> verifyPhoneNumber(
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      PhoneCodeSent codeSent,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed) {
    // For the full phone number we need to concat the dialcode and the number entered by the user
    String phoneNumber = _dialCode.value + _phone.value.replaceAll(" ", "");
    return _repository.verifyPhoneNumber(
        phoneNumber,
        codeAutoRetrievalTimeout,
        codeSent,
        Duration(seconds: Constants.timeOutDuration),
        verificationCompleted,
        verificationFailed);
  }

  dispose() async {
    await _email.drain();
    _email.close();
    await _phone.drain();
    _phone.close();
    await _authStatus.drain();
    _authStatus.close();
    await _dialCode.drain();
    _dialCode.close();
    await _verificationId.drain();
    _verificationId.close();
  }
}
