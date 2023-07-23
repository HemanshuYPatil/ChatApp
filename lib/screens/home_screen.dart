// import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:we_chat/helper/vediocall.dart';
import 'package:we_chat/screens/creategroup.dart';
import '../helper/database.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/group_user_card.dart';
import 'auth/helper.dart';
import 'profile_screen.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  String userName = "";
  String email = "";
  Stream? groups;
  String groupName = "";
  String roomId = "";
  String? fetchedRoomId;

  get value => null;

  @override
  void initState() {
    // roomId = generateRandomRoomId();
    super.initState();
    APIs.getSelfInfo();
    fetchRoomId();

    SystemChannels.lifecycle.setMessageHandler((message) {
      // log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text('Chats'),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              IconButton(
                onPressed: () {
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(1, 0, 0, 0),
                    items: [
                      const PopupMenuItem(
                        value: _MenuValues.newgroup,
                        child: Text('Create Room'),
                      ),
                      const PopupMenuItem(
                        value: _MenuValues.joingroup,
                        child: Text('Join Room'),
                      ),
                      const PopupMenuItem(
                        value: _MenuValues.profile,
                        child: Text('Account'),
                      ),
                      const PopupMenuItem(
                        value: _MenuValues.settings,
                        child: Text('Settings'),
                      ),
                    ],
                    elevation: 8.0,
                  ).then((value) {
                    if (value == _MenuValues.profile) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )),
                      );
                    } else if (value == _MenuValues.settings) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => settingscreen()),
                      );
                    } else if (value == _MenuValues.newgroup) {
                      // QuickAlert.show(
                      //   context: context,
                      //   type: QuickAlertType.confirm,
                      //   text: 'Are you sure to create a vedio call room',
                      //   confirmBtnText: 'Yes',
                      //   cancelBtnText: 'No',
                      //   confirmBtnColor: Colors.green,
                      //   onConfirmBtnTap: () async {
                      //     // roomcreate();
                      //   },
                      // );
                      loading();
                    } else if (value == _MenuValues.joingroup) {
                      joinGroup();
                    }
                  });
                },
                icon: const Icon(Icons.more_vert),
              )
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
                onPressed: () {
                  addChatUserDialog();
                },
                child: const Icon(Icons.add_comment_rounded)),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                              child: CircularProgressIndicator());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            // log("List: $_list");
                            return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChatUserCard(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'No Connections Found!',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),
                MaterialButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }

  // void roomcreate() {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.confirm,
  //     title: 'Room Created',
  //     text: 'Room Id : $roomId',
  //     confirmBtnText: 'Join',
  //     barrierDismissible: false,
  //     cancelBtnText: 'Share ',
  //     confirmBtnColor: Colors.blue,
  //     onConfirmBtnTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (_) => CallPage(
  //                   callID: roomId,
  //                 )),
  //       );
  //     },
  //     onCancelBtnTap: () {
  //       shareToApps(roomId);
  //     },
  //   ).whenComplete(() => null);
  // }
  void roomcreate() async {
    final String roomId = generateRandomRoomId();
    final DateTime createdOn = DateTime.now();

    await FirebaseFirestore.instance.collection('rooms').add({
      'Room_Admin':FirebaseAuth.instance.currentUser!.displayName,
      'User_Id':FirebaseAuth.instance.currentUser!.uid, 
      'roomId': roomId,
      'createdOn': createdOn,
    });

    // ignore: use_build_context_synchronously
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Room Created',
      text: 'Room Id : $roomId',
      confirmBtnText: 'Join',
      barrierDismissible: false,
      cancelBtnText: 'Share ',
      confirmBtnColor: Colors.blue,
      onConfirmBtnTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallPage(
              callID: roomId,
            ),
          ),
        );
      },
      onCancelBtnTap: () {
        shareToApps(roomId);
      },
    ).whenComplete(() => null);
  }

  



  void fetchRoomId() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> roomSnapshot =
          await FirebaseFirestore.instance
              .collection('rooms')
              .orderBy('createdOn', descending: true)
              .limit(1)
              .get();

      if (roomSnapshot.docs.isNotEmpty) {
        final String roomId = roomSnapshot.docs[0]['roomId'];
        setState(() {
          fetchedRoomId = roomId;
        });
      } else {
        setState(() {
          fetchedRoomId = "No Rooms Found";
        });
      }
    } catch (e) {
      setState(() {
        fetchedRoomId = "Error Fetching Room ID";
      });
      print("Error fetching room ID: $e");
    }
  }

  void loading() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.loading,
      title: 'Groupiee',
      text: 'Creating Room...',
      autoCloseDuration: Duration(milliseconds: 7000),
    ).whenComplete(() => roomcreate());
  }

  // Future<void> joining() async {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.loading,
  //     title: 'Groupiee',
  //     text: 'Joining Room...',
  //     autoCloseDuration: Duration(milliseconds: 6000),
  //   ).whenComplete(() => Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (_) => CallPage(
  //                   callID: ,
  //                 )),
  //       ));
  // }

  // String generateRandomString(int len) {
  //   var r = Random();
  //   const chars =
  //       'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  //   return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  // }

  Future<void> joinGroup() async {
    String? groupId;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(
                    Icons.video_chat_rounded,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Join Room')
                ],
              ),
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => groupId = value,
                decoration: InputDecoration(
                    hintText: 'Room Id',
                    prefixIcon: const Icon(Icons.video_chat_rounded,
                        color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              actions: [
                MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),
                MaterialButton(
                    onPressed: () async {
                      fetchRoomId();
                      Navigator.pop(context);
                      if (groupId!.isEmpty) {
                        Dialogs.showSnackbar(context, "Fields are empty");
                      } else if (groupId == fetchedRoomId) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.loading,
                          title: 'Groupiee',
                          text: 'Joining Room...',
                          autoCloseDuration: Duration(milliseconds: 6000),
                        ).whenComplete(() => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CallPage(
                                  callID: fetchedRoomId!,
                                ),
                              ),
                            ));
                      } else {
                        Dialogs.showSnackbar(context, "Invalid Room ID");
                      }
                    },
                    child: const Text(
                      'Join',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }

  String generateRandomRoomId() {
    final random = Random();
    // Generate a random number between 1000 and 9999 (inclusive)
    final roomId = random.nextInt(9000) + 1000;
    return roomId.toString();
  }

  void shareToApps(String roomId) async {
    await FlutterShare.share(
      title: 'Video Call Invite',
      text:
          'Welcome! Experience seamless real-time video communication within our app. Lets connect video call via code : $roomId',
    );
  }
}

enum _MenuValues { profile, settings, newgroup, joingroup }
