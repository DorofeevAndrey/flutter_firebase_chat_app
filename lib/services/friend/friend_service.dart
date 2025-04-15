import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  // get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  Future<void> sendFriendRequest(String receiverId) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) return;

    final senderId = currentUser.uid;

    // Проверка: уже есть запрос?
    final existingRequest =
        await _firestore
            .collection('friend_requests')
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: receiverId)
            .get();

    if (existingRequest.docs.isEmpty) {
      await _firestore.collection('friend_requests').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'timestamp': Timestamp.now(),
        'status': 'pending',
      });
    } else {
      // Можно обработать повторную попытку: показать сообщение
      throw Exception('Request already sent');
    }
  }

  Future<void> cancelFriendRequest(String receiverId) async {
    final senderId = _auth.currentUser!.uid;

    final requestSnapshot =
        await _firestore
            .collection('friend_requests')
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: receiverId)
            .get();

    for (var doc in requestSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<String?> getFriendRequestStatus(String receiverId) async {
    final senderId = _auth.currentUser!.uid;

    final querySnapshot =
        await _firestore
            .collection('friend_requests')
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: receiverId)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['status']; // например, 'pending'
    }

    return null; // заявка не найдена
  }
}
