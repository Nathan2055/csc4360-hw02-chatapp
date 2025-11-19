import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_entry.dart';

// FirestoreHelper handles all interaction with the Cloud Firestore databases
class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Adds a new user entry
  void addUserEntry(UserEntry user) {
    final docRef = _firestore
        .collection('users')
        .withConverter(
          fromFirestore: UserEntry.fromFirestore,
          toFirestore: (UserEntry userEntry, options) =>
              userEntry.toFirestore(),
        )
        .doc(user.email);
    docRef.set(user);
  }

  // Updates an existing user entry's profile details by getting
  // the existing UserEntry from Cloud Firestore, converting it to a map,
  // applying the profile updates, converting it back to a map,
  // and then saving the result back to Cloud Firestore
  Future<bool> updateUserProfile(
    String emailID,
    String newUsername,
    String newFirstName,
    String newLastName,
  ) async {
    try {
      UserEntry newProfile = await getUserEntryFromEmail(emailID).then((
        result,
      ) {
        if (result != null) {
          Map<String, dynamic> resultMap = result.toFirestore();
          resultMap['username'] = newUsername;
          resultMap['firstName'] = newFirstName;
          resultMap['lastName'] = newLastName;
          return UserEntry.fromMap(resultMap);
        } else {
          throw Exception;
        }
      });

      final docRef = _firestore
          .collection('users')
          .withConverter(
            fromFirestore: UserEntry.fromFirestore,
            toFirestore: (UserEntry userEntry, options) =>
                userEntry.toFirestore(),
          )
          .doc(emailID);
      await docRef.set(newProfile);

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // Gets a user entry from Cloud Firestore based on an email
  Future<UserEntry?> getUserEntryFromEmail(String email) async {
    final docRef = _firestore
        .collection('users')
        .doc(email)
        .withConverter(
          fromFirestore: UserEntry.fromFirestore,
          toFirestore: (UserEntry userEntry, _) => userEntry.toFirestore(),
        );
    final docSnap = await docRef.get();
    final user = docSnap.data();
    return user;
  }

  /*
  Stream<List<UserEntry>> getUserEntryStream() {
    return _firestore
        .collection('users')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => UserEntry.fromSnapshot(doc)).toList(),
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawUserEntryStream() {
    return _firestore.collection('users').snapshots();
  }

  void updateUserEntry(UserEntry userEntry) {
    try {
      _firestore
          .collection('users')
          .doc(userEntry.id)
          .update(userEntry.toMap());
      debugPrint('UserEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void updateUserEntryByID(String id, String name, double price) {
    try {
      _firestore.collection('users').doc(id).update({
        "name": name,
        "price": price,
      });
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void deleteUserEntry(String id) {
    try {
      _firestore.collection('users').doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }
  */
}
