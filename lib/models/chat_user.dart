// class ChatUser {
//   ChatUser(
//       {required this.image,
//       required this.about,
//       required this.name,
//       required this.createdAt,
//       required this.isOnline,
//       required this.id,
//       required this.lastActive,
//       required this.email,
//       required this.pushToken,
//       this.groupId,
//       this.groupname});

//   late String image;
//   late String about;
//   late String name;
//   late String createdAt;
//   late bool isOnline;
//   late String id;
//   late String lastActive;
//   late String email;
//   late String pushToken;
//   String? groupId;
//   String? groupname;

//   ChatUser.fromJson(Map<String, dynamic> json) {
//     image = json['image'] ?? '';
//     about = json['about'] ?? '';
//     name = json['name'] ?? '';
//     createdAt = json['created_at'] ?? '';
//     isOnline = json['is_online'] ?? false;
//     id = json['id'] ?? '';
//     lastActive = json['last_active'] ?? '';
//     email = json['email'] ?? '';
//     pushToken = json['push_token'] ?? '';
//     groupId = json['groupId'] ?? '';
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['image'] = image;
//     data['about'] = about;
//     data['name'] = name;
//     data['created_at'] = createdAt;
//     data['is_online'] = isOnline;
//     data['id'] = id;
//     data['last_active'] = lastActive;
//     data['email'] = email;
//     data['push_token'] = pushToken;
//     data['groupId'] = groupId;
//     return data;
//   }

//   static ChatUser fromMap(Map<String, Object> group) {}
// }


// class Group extends ChatUser {
//   Group({
//     required String groupid,
//     required String groupName,
//     required DateTime createdat,
//     required String groupadmin
//     // Include any additional properties specific to the group
//   }) : super(
//           image: '',
//           about: '',
//           name: groupName,
//           createdAt: '',
//           isOnline: false,
//           id: '',
//           lastActive: '',
//           email: '',
//           pushToken: '',
//           groupId: '',
//           groupname: groupName,
//         );
// }

class ChatUser {
  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    this.groupId,
    this.groupname,
  });

  String image;
  String about;
  String name;
  String createdAt;
  bool isOnline;
  String id;
  String lastActive;
  String email;
  String pushToken;
  String? groupId;
  String? groupname;

  ChatUser.fromJson(Map<String, dynamic> json)
      : image = json['image'] ?? '',
        about = json['about'] ?? '',
        name = json['name'] ?? '',
        createdAt = json['created_at'] ?? '',
        isOnline = json['is_online'] ?? false,
        id = json['id'] ?? '',
        lastActive = json['last_active'] ?? '',
        email = json['email'] ?? '',
        pushToken = json['push_token'] ?? '',
        groupId = json['groupId'],
        groupname = json['groupname'];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['is_online'] = isOnline;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['groupId'] = groupId;
    data['groupname'] = groupname;
    return data;
  }

  static ChatUser fromMap(Map<String, Object> map) {
    return ChatUser(
      image: map['image'] as String? ?? '',
      about: map['about'] as String? ?? '',
      name: map['name'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
      isOnline: map['is_online'] as bool? ?? false,
      id: map['id'] as String? ?? '',
      lastActive: map['last_active'] as String? ?? '',
      email: map['email'] as String? ?? '',
      pushToken: map['push_token'] as String? ?? '',
      groupId: map['groupId'] as String?,
      groupname: map['groupname'] as String?,
    );
  }
}

class Group  {
  Group({
    required String groupId,
    required String groupName,
    required DateTime createdAt,
    required String groupAdmin,
    required List<String> members
  });
  
}
