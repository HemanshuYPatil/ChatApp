import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';

class Dialogs {
  static void showSnackbar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.blue.withOpacity(.8),
        behavior: SnackBarBehavior.floating));
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }

  void shareToApps(String roomId) async {
    await FlutterShare.share(
      title: 'Video Call Invite',
      text:
          'Hey There, Lets Connect via Video call in App using code : $roomId',
    );
  }

   
}
