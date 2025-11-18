import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_entry.dart';

class UserDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'users';

  void addUserEntryNew(UserEntry user) {
    final docRef = _firestore
        .collection(collectionName)
        .withConverter(
          fromFirestore: UserEntry.fromFirestore,
          toFirestore: (UserEntry userEntry, options) =>
              userEntry.toFirestore(),
        )
        .doc(user.email);
    docRef.set(user);
  }

  void addUserEntryUnstruct(
    String username,
    String email,
    String firstName,
    String lastName,
  ) {
    try {
      _firestore.collection(collectionName).add({
        'username': username,
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': 'user',
        'registeredOn': DateTime.now().toString(),
      });
    } catch (e) {
      debugPrint('Error creating item: $e');
    }
  }

  void addUserEntry(UserEntry userEntry) {
    try {
      _firestore.collection(collectionName).add(userEntry.toMap());
    } catch (e) {
      debugPrint('Error creating item: $e');
    }
  }

  UserEntry? getUserEntryFromEmail(String email) {
    try {
      _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .get()
          .then((querySnapshot) {
            print("Successfully completed");
            for (var docSnapshot in querySnapshot.docs) {
              return UserEntry.fromSnapshot(docSnapshot);
            }
          });
    } catch (e) {
      debugPrint('Error creating item: $e');
      return null;
    }
    return null;
  }

  Stream<List<UserEntry>> getUserEntryStream() {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserEntry.fromSnapshot(doc)).toList(),
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawUserEntryStream() {
    return _firestore.collection(collectionName).snapshots();
  }

  void updateUserEntry(UserEntry userEntry) {
    try {
      _firestore
          .collection(collectionName)
          .doc(userEntry.id)
          .update(userEntry.toMap());
      debugPrint('UserEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void updateUserEntryByID(String id, String name, double price) {
    try {
      _firestore.collection(collectionName).doc(id).update({
        "name": name,
        "price": price,
      });
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void deleteUserEntry(String id) {
    try {
      _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }
}
