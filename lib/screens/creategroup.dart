import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CreateGroup extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
   CreateGroup({ Key? key});

  String groupId = FirebaseFirestore.instance.collection('groups').doc().id;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          // Group does not exist or data is not available
          return const Center(child: Text('Group Not Found'));
        }

        final groupData = snapshot.data!.data() as Map<String, dynamic>;
        final groupName = groupData['groupName'] as String;
        final groupAdmin = groupData['groupAdmin'] as String;
        final members = groupData['members'] as List<dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: Text(groupName),
          ),
          body: Column(
            children: [
              Text('Group Admin: $groupAdmin'),
              const SizedBox(height: 16),
              const Text('Members:'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index] as String;
                    return ListTile(
                      title: Text(member),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
