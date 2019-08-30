import 'package:flutter/material.dart';
import 'package:passwordless_demo/src/constants.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Center(
          child: Text(Constants.thankYou),
        ),
      ),
    );
  }
}
