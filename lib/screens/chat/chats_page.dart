import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/components/user_tile.dart';
import 'package:flutter_firebase_chat_app/screens/chat/chat_page.dart';
import 'package:flutter_firebase_chat_app/screens/notification/notification_page.dart';
import 'package:flutter_firebase_chat_app/services/friend/friend_service.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});

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
        title: Text("Chats"),
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
              return Center(child: Text("No chats found"));
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
                            (context) => ChatPage(
                              receiverEmail: friend['email'],
                              receiverID: friend['uid'],
                            ),
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
