import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/components/my_textfield.dart';
import 'package:flutter_firebase_chat_app/components/user_tile.dart';
import 'package:flutter_firebase_chat_app/services/friend/friend_service.dart';

import '../../services/auth/auth_service.dart';
import 'user_page.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final FriendService _friendService = FriendService();
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        searchText = _emailController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text("Add Friend"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          MyTextfield(
            hintText: "Enter email to invite a friend...",
            obscureText: false,
            controller: _emailController,
          ),
          _buildUserList(),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Expanded(
      child: StreamBuilder(
        stream: _friendService.getUsersStream(),
        builder: (context, snapshot) {
          // error
          if (snapshot.hasError) {
            return const Text("Error");
          }

          // loading...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Icon(Icons.circle_notifications);
          }

          // no data
          if (!snapshot.hasData) {
            return const Center(child: Text("No users found"));
          }

          // Фильтрация пользователей по email
          final filteredUsers =
              snapshot.data!
                  .where(
                    (userData) =>
                        userData["uid"] != _authService.getCurrentUser()!.uid &&
                        userData["email"].toString().toLowerCase().contains(
                          searchText,
                        ),
                  )
                  .take(10)
                  .toList();

          return ListView(
            children: [
              SizedBox(height: 10), // Отступ сверху
              ...filteredUsers.map<Widget>(
                (userData) => _buildUserListItem(userData, context),
              ),
            ],
          );
        },
      ),
    );
  }

  // build individual list tile
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // display all users except current user
    if (userData["uid"] != _authService.getCurrentUser()!.uid) {
      return UserTile(
        title: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserPage(userEmail: userData["email"]),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
