import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/chat_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addChatEntry(String collection, ChatEntry chatEntry) async {
    try {
      var docRef = await _firestore
          .collection(collection)
          .add(chatEntry.toMap());
      print('Chat entry created');
      String id = docRef.id;
      print("Document written with ID: ");
      return id;
    } catch (e) {
      debugPrint('Error creating item: $e');
      return '';
    }
  }

  Stream<List<ChatEntry>> getChatEntryStream(String collection) {
    return _firestore
        .collection(collection)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatEntry.fromSnapshot(doc)).toList(),
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawChatEntryStream(
    String collection,
  ) {
    return _firestore.collection(collection).snapshots();
  }

  Future<void> updateChatEntry(String collection, ChatEntry chatEntry) async {
    try {
      await _firestore
          .collection(collection)
          .doc(chatEntry.id)
          .update(chatEntry.toMap());
      debugPrint('ChatEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> updateChatEntryByID(
    String collection,
    String id,
    String name,
    double price,
  ) async {
    try {
      await _firestore.collection(collection).doc(id).update({
        "name": name,
        "price": price,
      });
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteChatEntry(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  // Firestore query for search
  Future<Stream<QuerySnapshot<Object?>>?> searchProducts(
    String collection,
    String query,
  ) async {
    try {
      var result = await _firestore
          .collection(collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots();
      return result;
    } catch (e) {
      debugPrint('Error searching items: $e');
      return null;
    }
  }

  // Firestore query for price filter
  Future<Stream<QuerySnapshot<Object?>>?> filterProductsByPrice(
    String collection,
    double minPrice,
    double maxPrice,
  ) async {
    try {
      var result = await _firestore
          .collection(collection)
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .snapshots();
      return result;
    } catch (e) {
      debugPrint('Error filtering items: $e');
      return null;
    }
  }
}
