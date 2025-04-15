import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

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
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          _buildNotificationCard(
            context,
            title: "New Friend Request",
            subtitle: "alex@example.com sent you a friend request",
            onAccept: () {},
            onReject: () {},
          ),
          _buildNotificationCard(
            context,
            title: "Request Accepted",
            subtitle: "john@example.com accepted your friend request",
            onTap: () {}, // Перейти к чату
          ),
          // ...можно загрузить динамически из Firestore
        ],
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
      margin: const EdgeInsets.symmetric(vertical: 5),

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
