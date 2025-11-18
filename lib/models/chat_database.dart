import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/chat_entry.dart';

class ChatDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void addChatEntry(String collection, ChatEntry chatEntry) {
    try {
      _firestore.collection(collection).add(chatEntry.toMap());
    } catch (e) {
      debugPrint('Error creating item: $e');
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

  void updateChatEntry(String collection, ChatEntry chatEntry) {
    try {
      _firestore
          .collection(collection)
          .doc(chatEntry.id)
          .update(chatEntry.toMap());
      debugPrint('ChatEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void updateChatEntryByID(
    String collection,
    String id,
    String name,
    double price,
  ) {
    try {
      _firestore.collection(collection).doc(id).update({
        "name": name,
        "price": price,
      });
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  void deleteChatEntry(String collection, String id) {
    try {
      _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  // Firestore query for search
  Stream<QuerySnapshot<Object?>>? searchProducts(
    String collection,
    String query,
  ) {
    try {
      var result = _firestore
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
  Stream<QuerySnapshot<Object?>>? filterProductsByPrice(
    String collection,
    double minPrice,
    double maxPrice,
  ) {
    try {
      var result = _firestore
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
