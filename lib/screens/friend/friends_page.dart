import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/components/user_tile.dart';
import 'package:flutter_firebase_chat_app/screens/notification/notification_page.dart';
import 'package:flutter_firebase_chat_app/services/friend/friend_service.dart';
import 'add_friend_page.dart';
import 'user_page.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});

  final FriendService _friendService = FriendService();

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
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _friendService.getFriends(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No friends found"));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final friend = snapshot.data![index];
                return UserTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => UserPage(userEmail: friend['email']),
                      ),
                    );
                  },
                  title: friend['email'],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
