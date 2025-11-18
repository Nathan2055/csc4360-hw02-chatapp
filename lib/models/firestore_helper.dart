import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_entry.dart';

class FirestoreHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'users';

  void addUserEntry(UserEntry user) {
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

  // Get the existing UserEntry from Firebase, convert it to a map,
  // apply the profile updates, convert it back, and then save the result
  // back to Firebase
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
          .collection(collectionName)
          .withConverter(
            fromFirestore: UserEntry.fromFirestore,
            toFirestore: (UserEntry userEntry, options) =>
                userEntry.toFirestore(),
          )
          .doc(emailID);
      await docRef.set(newProfile);

      // TODO: add an extra check here?

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<UserEntry?> getUserEntryFromEmail(String email) async {
    final docRef = _firestore
        .collection(collectionName)
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
  */
}
