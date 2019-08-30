import 'package:country_code_picker/country_code_picker.dart';
import 'package:country_code_picker/country_codes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:passwordless_demo/src/app_screen.dart';
import 'package:passwordless_demo/src/auth_bloc.dart';
import 'package:passwordless_demo/src/auth_bloc_provider.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:passwordless_demo/src/constants.dart';
import 'package:pin_view/pin_view.dart';

class AuthScreen extends StatefulWidget {
  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  AuthBloc _bloc;
  Locale _myLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = AuthBlocProvider.of(context);
    this.initDynamicLinks();
    _myLocale = Localizations.localeOf(context);

    /// We need to reflect the initial selection of the dialcode, in case the phone's selected locale
    /// matches the phone dial code, which is the majority of the cases.
    /// We do this by loading up a list of dialcodes and their respected country code, from there
    /// we find the matching dialcode for the phone's locale.
    List<CountryCode> elements = codes
        .map((s) => CountryCode(
              name: "",
              code: s['code'],
              dialCode: s['dial_code'],
              flagUri: "",
            ))
        .toList();
    String dialCode =
        elements.firstWhere((c) => c.code == _myLocale.countryCode).dialCode;
    _bloc.changeDialCode(dialCode);
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      /// Change status to a loading state, so user would not get confused even for a second.
      _bloc.changeAuthStatus(AuthStatus.isLoading);
      _bloc
          .signInWIthEmailLink(
              await _bloc.getUserEmailFromStorage(), deepLink.toString())
          .whenComplete(() => _authCompleted());
    }
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          StreamBuilder(
              stream: _bloc.authStatus,
              builder: (context, snapshot) {
                switch (snapshot.data) {
                  case (AuthStatus.emailAuth):
                    return _authForm(true);
                    break;
                  case (AuthStatus.phoneAuth):
                    return _authForm(false);
                    break;
                  case (AuthStatus.emailLinkSent):
                    return Center(child: Text(Constants.sentEmail));
                    break;
                  case (AuthStatus.smsSent):
                    return _smsCodeInputField();
                    break;
                  case (AuthStatus.isLoading):
                    return Center(child: CircularProgressIndicator());
                    break;
                  default:
                    // By default we will show the email auth form
                    return _authForm(true);
                    break;
                }
              })
        ],
      ),
    );
  }

  /// Widget is specfied for auth method by [isEmail] value.
  /// If its false, a form for phone auth is given.
  /// This is to make it easier for the email and phone auth forms to be more similar looking.
  /// Keeping that in mind we'll try to share all the widgets to a reasonable extent.
  Widget _authForm(bool isEmail) {
    return StreamBuilder(
        stream: isEmail ? _bloc.email : _bloc.phone,
        builder: (context, snapshot) {
          return Column(children: <Widget>[
            isEmail
                ? _emailInputField(snapshot.error)
                : _phoneInputField(snapshot.error),
            SizedBox(height: 32),
            RaisedButton(
              onPressed: snapshot.hasData
                  ? (isEmail
                      ? _authenticateUserWithEmail
                      : _authenticateUserWithPhone)
                  : null,
              child: Text(
                Constants.submit.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
              color: Colors.blue,
            ),
            SizedBox(height: 32),
            GestureDetector(
                onTap: () => _bloc.changeAuthStatus(
                    isEmail ? AuthStatus.phoneAuth : AuthStatus.emailAuth),
                child: Text(
                  isEmail
                      ? Constants.usePhone.toUpperCase()
                      : Constants.useEmail.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )),
          ]);
        });
  }

  /// The method takes in an [error] message from our validator.
  Widget _emailInputField(String error) {
    return TextField(
      onChanged: _bloc.changeEmail,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(fontSize: 20),
      decoration: InputDecoration(
        hintText: Constants.enterEmail,
        errorText: error,
        labelText: Constants.labelEmail,
        labelStyle: TextStyle(
          color: Colors.blue,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Besides the user entering their phone number, we also need to know the user's country code
  /// for that we are gonna use a library CountryCodePicker.
  /// The method takes in an [error] message from our validator.
  Widget _phoneInputField(String error) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: CountryCodePicker(
                onChanged: (countryCode) =>
                    _bloc.changeDialCode(countryCode.dialCode),
                initialSelection: _myLocale.countryCode,
                favorite: [_myLocale.countryCode],
                showCountryOnly: false,
                alignLeft: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              onChanged: _bloc.changePhone,
              keyboardType: TextInputType.phone,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                hintText: Constants.enterPhone,
                errorText: error,
                labelText: Constants.labelPhone,
                labelStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smsCodeInputField() {
    return Column(children: <Widget>[
      PinView(
          count: 6, // describes the field number
          margin: EdgeInsets.all(2.5), // margin between the fields
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
          submit: (String smsCode) {
            AuthCredential credential = PhoneAuthProvider.getCredential(
                verificationId: _bloc.getVerificationId, smsCode: smsCode);
            _bloc.signInWithCredential(credential).then((result) =>
                // You could potentially find out if the user is new
                // and if so, pass that info on, to maybe do a tutorial
                // if (result.additionalUserInfo.isNewUser)
                _authCompleted());
          }),
    ]);
  }

  void _authenticateUserWithEmail() {
    _bloc.sendSignInWithEmailLink().whenComplete(() => _bloc
        .storeUserEmail()
        .whenComplete(() => _bloc.changeAuthStatus(AuthStatus.emailLinkSent)));
  }

  void _authenticateUserWithPhone() {
    PhoneVerificationFailed verificationFailed = (AuthException authException) {
      _bloc.changeAuthStatus(AuthStatus.phoneAuth);
      _showSnackBar(Constants.verificationFailed);
      //TODO: show error to user.
      print(
          'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };

    PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _bloc
          .signInWithCredential(phoneAuthCredential)
          .then((result) => _authCompleted());
      print('Received phone auth credential: $phoneAuthCredential');
    };

    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _bloc.changeVerificationId(verificationId);
      print(
          'Please check your phone for the verification code. $verificationId');
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      print("auto retrieval timeout");
    };

    _bloc.changeAuthStatus(AuthStatus.smsSent);
    _bloc.verifyPhoneNumber(codeAutoRetrievalTimeout, codeSent,
        verificationCompleted, verificationFailed);
  }

  _showSnackBar(String error) {
    final snackBar = SnackBar(content: Text(error));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  _authCompleted() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AppScreen()));
  }
}
