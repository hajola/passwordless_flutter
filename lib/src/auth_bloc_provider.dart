import 'package:flutter/material.dart';
import 'package:passwordless_demo/src/auth_bloc.dart';

class AuthBlocProvider extends InheritedWidget {
  final bloc = AuthBloc();

  AuthBlocProvider({Key key, Widget child}) : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static AuthBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(AuthBlocProvider)
            as AuthBlocProvider)
        .bloc;
  }
}
