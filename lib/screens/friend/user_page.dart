import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_app/services/friend/friend_service.dart';

class UserPage extends StatefulWidget {
  final String userEmail;

  const UserPage({super.key, required this.userEmail});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final FriendService _friendService = FriendService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _requestStatus;

  @override
  void initState() {
    super.initState();
    _loadFriendRequestStatus();
  }

  // функция получения статуса запроса в друзья
  Future<void> _loadFriendRequestStatus() async {
    final userSnapshot =
        await _firestore
            .collection('Users')
            .where('email', isEqualTo: widget.userEmail)
            .get();

    if (userSnapshot.docs.isNotEmpty) {
      final receiverId = userSnapshot.docs.first.id;
      final status = await _friendService.getFriendRequestStatus(receiverId);

      setState(() {
        _requestStatus = status; // может быть null, 'pending', 'accepted'
      });
    }
  }

  // функция отправки запроса в друзья
  Future<void> _handleFriendRequest(BuildContext context) async {
    try {
      // Получааем id по email
      final userSnapshot =
          await _firestore
              .collection('Users')
              .where('email', isEqualTo: widget.userEmail)
              .get();

      // если есть то вызываем функцию
      if (userSnapshot.docs.isNotEmpty) {
        final receiverId = userSnapshot.docs.first.id;
        await _friendService.sendFriendRequest(receiverId);

        setState(() {
          _requestStatus = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent to ${widget.userEmail}')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.userEmail),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),

      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        padding: EdgeInsets.all(5),
        child: ListTile(
          title: Text(
            getTileText(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: getTileIcon(),
          onTap: () {
            if (_requestStatus == null) {
              _handleFriendRequest(context);
            } else if (_requestStatus == 'pending') {
              _showCancelDialog(context);
            }
          },
        ),
      ),
    );
  }

  String getTileText() {
    switch (_requestStatus) {
      case 'pending':
        return 'Request Pending';
      case 'accepted':
        return 'Already Friends';
      default:
        return 'Add to Friends';
    }
  }

  Icon getTileIcon() {
    switch (_requestStatus) {
      case 'pending':
        return const Icon(Icons.hourglass_top);
      case 'accepted':
        return const Icon(Icons.check, color: Colors.green);
      default:
        return const Icon(Icons.person_add);
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              "Cancel Request",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            content: const Text(
              "Are you sure you want to cancel the friend request?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "No",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Закрываем диалог

                  final userSnapshot =
                      await _firestore
                          .collection('Users')
                          .where('email', isEqualTo: widget.userEmail)
                          .get();

                  if (userSnapshot.docs.isNotEmpty) {
                    final receiverId = userSnapshot.docs.first.id;
                    await _friendService.cancelFriendRequest(receiverId);

                    setState(() {
                      _requestStatus = null; // Сбросим статус
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Friend request canceled")),
                    );
                  }
                },
                child: const Text(
                  "Yes",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
    );
  }
}
