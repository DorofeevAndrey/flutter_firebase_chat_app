import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/pages/notification/notification_page.dart';

import 'add_friend_page.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NotificationPage()),
            );
          },
          icon: Icon(Icons.notifications),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFriendPage()),
              );
            },
            icon: Icon(Icons.add),
          ),
        ],
        title: Text("Friends"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 0,
      ),
      // body: _buildFriendsList(),
    );
  }

  // Widget _buildFriendsList() {
  //   return StreamBuilder(
  //     stream: _chatService.getUsersStream(),
  //     builder: (context, snapshot) {
  //       // error
  //       if (snapshot.hasError) {
  //         return const Text("Error");
  //       }

  //       // loading...
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Text("Loading...");
  //       }

  //       // no data
  //       if (!snapshot.hasData) {
  //         return const Center(child: Text("No users found"));
  //       } else {
  //         return ListView(
  //           children: [
  //             SizedBox(height: 10), // Отступ сверху
  //             ...snapshot.data!.map<Widget>(
  //               (userData) => _buildUserListItem(userData, context),
  //             ),
  //           ],
  //         );
  //       }

  //       // return list view
  //     },
  //   );
  // }
}
