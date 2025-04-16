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

  // Отправка заявки в друзья
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

  // Отмена заявки в друзья
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

  // Получение статуса заявки на основе senderId и receiverId
  Future<String?> getFriendRequestStatus(String receiverId) async {
    final senderId = _auth.currentUser!.uid;

    // Проверка заявки с учетом обеих сторон (senderId и receiverId)
    final querySnapshot =
        await _firestore
            .collection('friend_requests')
            .where('senderId', isEqualTo: senderId)
            .where('receiverId', isEqualTo: receiverId)
            .get();

    final reverseSnapshot =
        await _firestore
            .collection('friend_requests')
            .where('senderId', isEqualTo: receiverId)
            .where('receiverId', isEqualTo: senderId)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['status'];
    } else if (reverseSnapshot.docs.isNotEmpty) {
      return reverseSnapshot.docs.first['status'];
    }

    return null; // Заявка не найдена
  }

  // Получение всех заявок для текущего пользователя (например, для отображения уведомлений)
  Future<List<Map<String, dynamic>>> getNotificationsForUser() async {
    final receiverId = _auth.currentUser!.uid;

    try {
      final querySnapshot =
          await _firestore
              .collection('friend_requests')
              .where('receiverId', isEqualTo: receiverId)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'senderId': data['senderId'],
          'status': data['status'],
          'timestamp': data['timestamp'],
        };
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Принятие заявки в друзья
  Future<void> acceptFriendRequest(String senderId, String receiverId) async {
    try {
      final requestSnapshot =
          await _firestore
              .collection('friend_requests')
              .where('senderId', isEqualTo: senderId)
              .where('receiverId', isEqualTo: receiverId)
              .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.update({'status': 'accepted'});
      }
    } catch (e) {
      rethrow;
    }
  }

  // Отклонение заявки в друзья
  Future<void> rejectFriendRequest(String senderId, String receiverId) async {
    try {
      final requestSnapshot =
          await _firestore
              .collection('friend_requests')
              .where('senderId', isEqualTo: senderId)
              .where('receiverId', isEqualTo: receiverId)
              .get();

      for (var doc in requestSnapshot.docs) {
        await doc.reference.update({'status': 'rejected'});
      }
    } catch (e) {
      rethrow;
    }
  }

  // Получаем всех друзей currnetUser где он отправитель и получатель, немного не очень, но думаю должно работать
  Future<List<Map<String, dynamic>>> getFriends() async {
    final currentUserId = _auth.currentUser!.uid;

    try {
      final querySnapshot =
          await _firestore
              .collection('friend_requests')
              .where('status', isEqualTo: 'accepted')
              .where('senderId', isEqualTo: currentUserId)
              .get();

      final receivedSnapshot =
          await _firestore
              .collection('friend_requests')
              .where('status', isEqualTo: 'accepted')
              .where('receiverId', isEqualTo: currentUserId)
              .get();

      final allRequests = [...querySnapshot.docs, ...receivedSnapshot.docs];
      final friendsList = <Map<String, dynamic>>[];

      for (var doc in allRequests) {
        final data = doc.data();
        final senderId = data['senderId'];
        final receiverId = data['receiverId'];

        // Получаем id друга (не текущего пользователя)
        final friendId = senderId == currentUserId ? receiverId : senderId;

        // Запрашиваем email друга из коллекции users
        final userDoc =
            await _firestore.collection('Users').doc(friendId).get();
        final friendEmail = userDoc.data()!['email'];

        friendsList.add({'uid': friendId, 'email': friendEmail});
      }

      return friendsList;
    } catch (e) {
      rethrow;
    }
  }
}
