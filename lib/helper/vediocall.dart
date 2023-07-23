import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callID}) : super(key: key);
  final String callID ;
  


  @override
  Widget build(BuildContext context) {
    String? user = FirebaseAuth.instance.currentUser!.displayName;
    var userid = FirebaseAuth.instance.currentUser!.uid;
    return ZegoUIKitPrebuiltCall(
      appID:
          368331367, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
      appSign:
          '0c170c39f5dff42625bf7654c05232a8b3c75aa971d6dbf578e65d8e482be5bd', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
      userID: userid,
      userName: user!,
      callID: "$callID",
      // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
      config: ZegoUIKitPrebuiltCallConfig.groupVideoCall()
        // ignore: avoid_types_as_parameter_names
        // ..onOnlySelfInRoom =
        //     (context) => Navigator.of(context).pop(),

    );
  }
}
