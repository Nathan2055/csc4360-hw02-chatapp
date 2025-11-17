import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/chat_entry.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'products';

  Future<String> addChatEntry(ChatEntry chatEntry) async {
    try {
      var docRef = await _firestore
          .collection(collectionName)
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

  Stream<List<ChatEntry>> getChatEntryStream() {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => ChatEntry.fromSnapshot(doc)).toList(),
        );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRawChatEntryStream() {
    return _firestore.collection(collectionName).snapshots();
  }

  Future<void> updateChatEntry(ChatEntry chatEntry) async {
    try {
      await _firestore
          .collection(collectionName)
          .doc(chatEntry.id)
          .update(chatEntry.toMap());
      debugPrint('ChatEntry updated');
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> updateChatEntryByID(String id, String name, double price) async {
    try {
      await _firestore.doc(id).update({"name": name, "price": price});
    } catch (e) {
      debugPrint('Error updating item: $e');
    }
  }

  Future<void> deleteChatEntry(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting item: $e');
    }
  }

  // Firestore query for search
  Future<Stream<QuerySnapshot<Object?>>?> searchProducts(String query) async {
    try {
      var result = await _firestore
          .collection(collectionName)
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
    double minPrice,
    double maxPrice,
  ) async {
    try {
      var result = await _firestore
          .collection(collectionName)
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
