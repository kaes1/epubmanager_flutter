import 'package:epubmanager_flutter/consts/AppRoutes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoConnectionDialog extends StatelessWidget {
  static show(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return NoConnectionDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cannot connect to server'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(text: 'Please check the device\'s '),
                  TextSpan(
                      text: 'internet connection',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: ' and set server address in '),
                  TextSpan(
                      text: 'settings ',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        }),
                  WidgetSpan(
                      child: Icon(Icons.settings,
                          color: Theme.of(context).primaryColor)),
                  TextSpan(text: '.'),
                ]),
          )
        ],
      ),
      actions: <Widget>[
        RaisedButton(
          child: Text('CLOSE'),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
