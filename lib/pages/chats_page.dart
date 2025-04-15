import 'package:flutter/material.dart';

import '../components/user_tile.dart';
import '../services/auth/auth_service.dart';
import '../services/chat/chat_service.dart';
import 'chat_page.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({super.key});

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // no data
        if (!snapshot.hasData) {
          return const Center(child: Text("No users found"));
        } else {
          return ListView(
            children:
                snapshot.data!
                    .map<Widget>(
                      (userData) => _buildUserListItem(userData, context),
                    )
                    .toList(),
          );
        }

        // return list view
      },
    );
  }

  // build individual list tile
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // display all users except current user
    if (userData["uid"] != authService.getCurrentUser()!.uid) {
      return UserTile(
        title: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
                    receiverEmail: userData["email"],
                    receiverID: userData["uid"],
                  ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
