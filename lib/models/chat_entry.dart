import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of one chat posting
// Includes an id, a message, a username, and a DateTime of posting
class ChatEntry {
  final String id;
  final String message;
  final String username;
  final DateTime createdAt;

  ChatEntry({
    required this.id,
    required this.message,
    required this.username,
    required this.createdAt,
  });

  // Convert the item to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'username': username,
      'createdAt': createdAt,
    };
  }

  // Create an item from a Firestore document snapshot
  factory ChatEntry.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return ChatEntry(
      id: snapshot.id,
      message: data['message'],
      username: data['username'],
      createdAt: data['createdAt'].toDate(),
    );
  }
}
