import 'package:flutter/material.dart';

class Notify {
  static void dismissible(BuildContext context, String message) {
    var messenger = ScaffoldMessenger.of(context);

    messenger.removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          messenger.hideCurrentSnackBar();
        },
      ),
    ));
  }

  static void normal(BuildContext context, String message) {
    var messenger = ScaffoldMessenger.of(context);

    messenger.removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
