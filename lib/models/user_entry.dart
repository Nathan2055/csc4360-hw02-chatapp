import 'package:cloud_firestore/cloud_firestore.dart';

// Representation of one registered user
// Includes an id, a username, a first name, a last name, a user role, and a DateTime of registration
class UserEntry {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime registeredOn;

  UserEntry({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.registeredOn,
  });

  // Convert the item to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'registeredOn': registeredOn,
    };
  }

  // Create an item from a Firestore document snapshot
  factory UserEntry.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return UserEntry(
      id: snapshot.id,
      username: data['username'],
      email: data['email'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      role: data['role'],
      registeredOn: data['registeredOn'].toDate(),
    );
  }
}
