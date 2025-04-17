import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/screens/chat/chat_page.dart';
import 'package:flutter_firebase_chat_app/services/auth/auth_service.dart';
import 'package:flutter_firebase_chat_app/services/friend/friend_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = _authService.getCurrentUser()!.uid;
  }

  Future<void> _handleAccept(String senderId) async {
    await _friendService.acceptFriendRequest(senderId, currentUserId);
    setState(() {});
  }

  Future<void> _handleReject(String senderId) async {
    await _friendService.rejectFriendRequest(senderId, currentUserId);
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    return await _friendService.getNotificationsForUser();
  }

  Future<String?> getEmailByUid(String senderId) async {
    try {
      final userSnapshot =
          await _firestore.collection('Users').doc(senderId).get();

      if (userSnapshot.exists) {
        return userSnapshot.data()?['email'];
      } else {
        return null; // Если пользователь не найден
      }
    } catch (e) {
      print('Error fetching email: $e');
      return null; // Обработка ошибок
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final senderId = notification['senderId'];
              final status = notification['status'];

              return FutureBuilder<String?>(
                future: getEmailByUid(senderId),
                builder: (context, emailSnapshot) {
                  if (emailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // Показать индикатор загрузки
                  }

                  if (emailSnapshot.hasError) {
                    return Text('Error: ${emailSnapshot.error}');
                  }

                  final senderEmail =
                      emailSnapshot.data ?? 'Unknown'; // Если email не найден

                  return _buildNotificationCard(
                    context,
                    title: "Friend Request",
                    subtitle: "$senderEmail sent you a friend request",
                    onAccept:
                        status == 'pending'
                            ? () => _handleAccept(senderId)
                            : null,
                    onReject:
                        status == 'pending'
                            ? () => _handleReject(senderId)
                            : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChatPage(
                                receiverEmail: senderEmail,
                                receiverID: senderId,
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    VoidCallback? onAccept,
    VoidCallback? onReject,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).colorScheme.secondary,
      elevation: 0,
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing:
            (onAccept != null && onReject != null)
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: onAccept,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Color.fromARGB(255, 244, 76, 54),
                      ),
                      onPressed: onReject,
                    ),
                  ],
                )
                : const Icon(Icons.chat_bubble_outline),
        onTap: onTap,
      ),
    );
  }
}
