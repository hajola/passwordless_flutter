import 'package:firebase_auth/firebase_auth.dart';
import 'package:passwordless_demo/src/constants.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendSignInWithEmailLink(String email) async {
    return _auth.sendSignInWithEmailLink(
        email: email,
        url: Constants.projectUrl,
        androidInstallIfNotAvailable: true,
        androidMinimumVersion: '21',
        // TODO: replace name
        androidPackageName: 'com.example.passwordlessdemo',
        handleCodeInApp: true,
        // TODO: replace id
        iOSBundleID: 'com.example.passwordlessdemo');
  }

  Future<AuthResult> signInWithEmailLink(String email, String link) async {
    return _auth.signInWithEmailAndLink(email: email, link: link);
  }

  Future<void> verifyPhoneNumber(
      String phone,
      PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
      PhoneCodeSent codeSent,
      Duration duration,
      PhoneVerificationCompleted verificationCompleted,
      PhoneVerificationFailed verificationFailed) async {
    return _auth.verifyPhoneNumber(
        phoneNumber: phone,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        codeSent: codeSent,
        timeout: duration,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed);
  }

  Future<AuthResult> signInWithCredential(AuthCredential credential) async {
    return _auth.signInWithCredential(credential);
  }

  Future<FirebaseUser> getCurrentUser() {
    return _auth.currentUser();
  }
}
