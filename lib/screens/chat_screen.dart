// import 'dart:developer';
// import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import '../api/apis.dart';
// import '../helper/my_date_util.dart';
// import '../main.dart';
// import '../models/chat_user.dart';
// import '../models/message.dart';
// import '../widgets/message_card.dart';
// import 'view_profile_screen.dart';

// class ChatScreen extends StatefulWidget {
//   final ChatUser user;

//   const ChatScreen({super.key, required this.user});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   //for storing all messages
//   List<Message> _list = [];

//   //for handling message text changes
//   final _textController = TextEditingController();

//   //showEmoji -- for storing value of showing or hiding emoji
//   //isUploading -- for checking if image is uploading or not?
//   bool _showEmoji = false, _isUploading = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: SafeArea(
//         child: WillPopScope(
//           //if emojis are shown & back button is pressed then hide emojis
//           //or else simple close current screen on back button click
//           onWillPop: () {
//             if (_showEmoji) {
//               setState(() => _showEmoji = !_showEmoji);
//               return Future.value(false);
//             } else {
//               return Future.value(true);
//             }
//           },
//           child: Scaffold(
//             //app bar
//             appBar: AppBar(
//               automaticallyImplyLeading: false,
//               flexibleSpace: _appBar(),
//             ),

//             backgroundColor: const Color.fromARGB(255, 234, 248, 255),

//             //body
//             body: Column(
//               children: [
//                 Expanded(
//                   child: StreamBuilder(
//                     stream: APIs.getAllMessages(widget.user),
//                     builder: (context, snapshot) {
//                       switch (snapshot.connectionState) {
//                         //if data is loading
//                         case ConnectionState.waiting:
//                         case ConnectionState.none:
//                           return const SizedBox();

//                         //if some or all data is loaded then show it
//                         case ConnectionState.active:
//                         case ConnectionState.done:
//                           final data = snapshot.data?.docs;
//                           _list = data
//                                   ?.map((e) => Message.fromJson(e.data()))
//                                   .toList() ??
//                               [];

//                           if (_list.isNotEmpty) {
//                             return ListView.builder(
//                                 reverse: true,
//                                 itemCount: _list.length,
//                                 padding: EdgeInsets.only(top: mq.height * .01),
//                                 physics: const BouncingScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   return MessageCard(message: _list[index]);
//                                 });
//                           } else {
//                             return const Center(
//                               child: Text('Say Hii! 👋',
//                                   style: TextStyle(fontSize: 20)),
//                             );
//                           }
//                       }
//                     },
//                   ),
//                 ),

//                 //progress indicator for showing uploading
//                 if (_isUploading)
//                   const Align(
//                       alignment: Alignment.centerRight,
//                       child: Padding(
//                           padding:
//                               EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//                           child: CircularProgressIndicator(strokeWidth: 2))),

//                 //chat input filed
//                 _chatInput(),

//                 //show emojis on keyboard emoji button click & vice versa
//                 if (_showEmoji)
//                   SizedBox(
//                     height: mq.height * .35,
//                     child: EmojiPicker(
//                       textEditingController: _textController,
//                       config: Config(
//                         bgColor: const Color.fromARGB(255, 234, 248, 255),
//                         columns: 8,
//                         emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
//                       ),
//                     ),
//                   )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // app bar widget
//   // Widget _appBar() {
//   //   return InkWell(
//   //       onTap: () {
//   //         Navigator.push(
//   //             context,
//   //             MaterialPageRoute(
//   //                 builder: (_) => ViewProfileScreen(user: widget.user)));
//   //       },
//   //       child: StreamBuilder(
//   //           stream: APIs.getUserInfo(widget.user),
//   //           builder: (context, snapshot) {
//   //             final data = snapshot.data?.docs;
//   //             final list =
//   //                 data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

//   //             return Row(
//   //               children: [
//   //                 //back button
//   //                 IconButton(
//   //                     onPressed: () => Navigator.pop(context),
//   //                     icon:
//   //                         const Icon(Icons.arrow_back, color: Colors.black54)),

//   //                 //user profile picture
//   //                 ClipRRect(
//   //                   borderRadius: BorderRadius.circular(mq.height * .03),
//   //                   child: CachedNetworkImage(
//   //                     width: mq.height * .05,
//   //                     height: mq.height * .05,
//   //                     imageUrl:
//   //                         list.isNotEmpty ? list[0].image : widget.user.image,
//   //                     errorWidget: (context, url, error) => const CircleAvatar(
//   //                         child: Icon(CupertinoIcons.person)),
//   //                   ),
//   //                 ),

//   //                 //for adding some space
//   //                 const SizedBox(width: 10),

//   //                 //user name & last seen time
//   //                 Column(
//   //                   mainAxisAlignment: MainAxisAlignment.center,
//   //                   crossAxisAlignment: CrossAxisAlignment.start,
//   //                   children: [
//   //                     //user name
//   //                     Text(list.isNotEmpty ? list[0].name : widget.user.name,
//   //                         style: const TextStyle(
//   //                             fontSize: 16,
//   //                             color: Colors.black87,
//   //                             fontWeight: FontWeight.w500)),

//   //                     //for adding some space
//   //                     const SizedBox(height: 2),

//   //                     //last seen time of user
//   //                     Text(
//   //                         list.isNotEmpty
//   //                             ? list[0].isOnline
//   //                                 ? 'Online'
//   //                                 : MyDateUtil.getLastActiveTime(
//   //                                     context: context,
//   //                                     lastActive: list[0].lastActive)
//   //                             : MyDateUtil.getLastActiveTime(
//   //                                 context: context,
//   //                                 lastActive: widget.user.lastActive),
//   //                         style: const TextStyle(
//   //                             fontSize: 13, color: Colors.black54)),
//   //                   ],
//   //                 )
//   //               ],
//   //             );
//   //           }));
//   // }
//   Widget _appBar() {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ViewProfileScreen(user: widget.user),
//           ),
//         );
//       },
//       child: StreamBuilder(
//         stream: APIs.getUserInfo(widget.user),
//         builder: (context, snapshot) {
//           final data = snapshot.data?.docs;
//           final list =
//               data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

//           return Row(
//             children: [
//               // Back button
//               IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.arrow_back, color: Colors.black54),
//               ),

//               // User profile picture
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(mq.height * .03),
//                 child: CachedNetworkImage(
//                   width: mq.height * .05,
//                   height: mq.height * .05,
//                   imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
//                   errorWidget: (context, url, error) => const CircleAvatar(
//                     child: Icon(CupertinoIcons.person),
//                   ),
//                 ),
//               ),

//               // Adding some space
//               const SizedBox(width: 10),

//               // User name & last seen time
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // User name
//                   Text(
//                     list.isNotEmpty ? list[0].name : widget.user.name,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),

//                   // Adding some space
//                   const SizedBox(height: 2),

//                   // Last seen time of user
//                   Text(
//                     list.isNotEmpty
//                         ? list[0].isOnline
//                             ? 'Online'
//                             : MyDateUtil.getLastActiveTime(
//                                 context: context,
//                                 lastActive: list[0].lastActive,
//                               )
//                         : MyDateUtil.getLastActiveTime(
//                             context: context,
//                             lastActive: widget.user.lastActive,
//                           ),
//                     style: const TextStyle(fontSize: 13, color: Colors.black54),
//                   ),
//                 ],
//               ),

//               // Adding space between user name and icons
//               const Spacer(),

//               // Phone icon
//               IconButton(
//                 onPressed: () {
//                   // Handle phone icon click
//                 },
//                 icon: const Icon(Icons.phone, color: Colors.black54),
//               ),

//               // Video icon
//               IconButton(
//                 onPressed: () {
//                   // Handle video icon click
//                 },
//                 icon: const Icon(Icons.video_call, color: Colors.black54),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // bottom chat input field
//   Widget _chatInput() {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//           vertical: mq.height * .01, horizontal: mq.width * .025),
//       child: Row(
//         children: [
//           //input field & buttons
//           Expanded(
//             child: Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15)),
//               child: Row(
//                 children: [
//                   //emoji button
//                   IconButton(
//                       onPressed: () {
//                         FocusScope.of(context).unfocus();
//                         setState(() => _showEmoji = !_showEmoji);
//                       },
//                       icon: const Icon(Icons.emoji_emotions,
//                           color: Colors.blueAccent, size: 25)),

//                   Expanded(
//                       child: TextField(
//                     controller: _textController,
//                     keyboardType: TextInputType.multiline,
//                     maxLines: null,
//                     onTap: () {
//                       if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
//                     },
//                     decoration: const InputDecoration(
//                         hintText: 'Type Something...',
//                         hintStyle: TextStyle(color: Colors.blueAccent),
//                         border: InputBorder.none),
//                   )),

//                   //pick image from gallery button
//                   IconButton(
//                       onPressed: () async {
//                         final ImagePicker picker = ImagePicker();

//                         // Picking multiple images
//                         final List<XFile> images =
//                             await picker.pickMultiImage(imageQuality: 70);

//                         // uploading & sending image one by one
//                         for (var i in images) {
//                           log('Image Path: ${i.path}');
//                           setState(() => _isUploading = true);
//                           await APIs.sendChatImage(widget.user, File(i.path));
//                           setState(() => _isUploading = false);
//                         }
//                       },
//                       icon: const Icon(Icons.image,
//                           color: Colors.blueAccent, size: 26)),

//                   //take image from camera button
//                   IconButton(
//                       onPressed: () async {
//                         final ImagePicker picker = ImagePicker();

//                         // Pick an image
//                         final XFile? image = await picker.pickImage(
//                             source: ImageSource.camera, imageQuality: 70);
//                         if (image != null) {
//                           log('Image Path: ${image.path}');
//                           setState(() => _isUploading = true);

//                           await APIs.sendChatImage(
//                               widget.user, File(image.path));
//                           setState(() => _isUploading = false);
//                         }
//                       },
//                       icon: const Icon(Icons.camera_alt_rounded,
//                           color: Colors.blueAccent, size: 26)),

//                   //adding some space
//                   SizedBox(width: mq.width * .02),
//                 ],
//               ),
//             ),

//             // Send video button
//           ),

//           IconButton(
//             onPressed: () async {
//               final ImagePicker picker = ImagePicker();

//               // Pick a video from the gallery
//               final XFile? video =
//                   await picker.pickVideo(source: ImageSource.gallery);

//               if (video != null) {
//                 log('Video Path: ${video.path}');
//                 setState(() => _isUploading = true);

//                 await APIs.sendChatVideo(widget.user, File(video.path));
//                 setState(() => _isUploading = false);
//               }
//             },
//             icon: const Icon(Icons.video_library,
//                 color: Colors.blueAccent, size: 26),
//           ),

//           //send message button
//           MaterialButton(
//             onPressed: () {
//               if (_textController.text.isNotEmpty) {
//                 if (_list.isEmpty) {
//                   //on first message (add user to my_user collection of chat user)
//                   APIs.sendFirstMessage(
//                       widget.user, _textController.text, Type.text);
//                 } else {
//                   //simply send message
//                   APIs.sendMessage(
//                       widget.user, _textController.text, Type.text);
//                 }
//                 _textController.text = '';
//               }
//             },
//             minWidth: 0,
//             padding:
//                 const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
//             shape: const CircleBorder(),
//             color: Colors.green,
//             child: const Icon(Icons.send, color: Colors.white, size: 28),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:we_chat/helper/vediocall.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

import '../api/apis.dart';
import '../helper/audio.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final _textController = TextEditingController();
  bool _showEmoji = false;
  bool _isUploading = false;
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() => _showEmoji = !_showEmoji);
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return MessageCard(message: _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('Say Hi! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                _chatInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProfileScreen(user: widget.user),
          ),
        );
      },
      child: StreamBuilder(
        stream: APIs.getUserInfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black54),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .03),
                child: CachedNetworkImage(
                  width: mq.height * .05,
                  height: mq.height * .05,
                  imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.isNotEmpty ? list[0].name : widget.user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    list.isNotEmpty
                        ? list[0].isOnline
                            ? 'Online'
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: list[0].lastActive)
                        : MyDateUtil.getLastActiveTime(
                            context: context,
                            lastActive: widget.user.lastActive),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              const Spacer(),
              // IconButton(
              //   onPressed: () {
              //     // Handle phone icon click
              //   },
              //   icon: const Icon(Icons.phone, color: Colors.black54),
              // ),
              //   IconButton(
              //     onPressed: () {
                    
              //     },
              //   icon: const Icon(Icons.video_call, color: Colors.black54),
              // ),
            ],
          );
        },
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
        horizontal: mq.width * .025,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _showEmoji = !_showEmoji);
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji)
                          setState(() => _showEmoji = !_showEmoji);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      bool isMe = true;
                      _showBottomSheet(isMe);
                    },
                    icon: const Icon(
                      Icons.add,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() => _isUploading = true);
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(() => _isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blueAccent,
                      size: 26,
                    ),
                  ),
                  SizedBox(width: mq.width * .02),
                ],
              ),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                    widget.user,
                    _textController.text,
                    Type.text,
                  );
                  // player.play(AssetSource('sending_tone.mp3'));
                } else {
                  // player.play(AssetSource('sending_tone.mp3'));

                  APIs.sendMessage(
                    widget.user,
                    _textController.text,
                    Type.text,
                  );
                }
                _textController.text = '';
              }
            },
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              height: 4,
              margin: EdgeInsets.symmetric(
                vertical: mq.height * .015,
                horizontal: mq.width * .4,
              ),
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            _OptionItem(
              icon: const Icon(Icons.image, color: Colors.blue, size: 26),
              name: 'Image',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final List<XFile> images =
                    await picker.pickMultiImage(imageQuality: 70);

                for (var i in images) {
                  log('Image Path: ${i.path}');
                  setState(() => _isUploading = true);
                  await APIs.sendChatImage(widget.user, File(i.path));
                  setState(() => _isUploading = false);
                }
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            const Divider(
              color: Colors.black54,
              endIndent: 16,
              indent: 16,
            ),
            _OptionItem(
              icon: const Icon(
                Icons.video_collection,
                color: Colors.blue,
                size: 26,
              ),
              name: 'Video',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? video = await picker.pickVideo(
                  source: ImageSource.gallery,
                );

                if (video != null) {
                  log('Video Path: ${video.path}');
                  setState(() => _isUploading = true);
                  await APIs.sendChatVideo(widget.user, File(video.path));
                  setState(() => _isUploading = false);
                }
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            const Divider(
              color: Colors.black54,
              endIndent: 16,
              indent: 16,
            ),
            _OptionItem(
              icon: const Icon(
                Icons.audio_file_outlined,
                color: Colors.blue,
                size: 26,
              ),
              name: 'Audio',
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? audio =
                    await picker.pickVideo(source: ImageSource.gallery);

                if (audio != null) {
                  log('Video Path: ${audio.path}');
                  setState(() => _isUploading = true);
                  await APIs.sendChatAudio(widget.user, File(audio.path));
                  setState(() => _isUploading = false);
                }
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                    fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
