import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store/core/logging/app_logger.dart';

/// Contract for cloud document persistence abstraction.
abstract interface class FirestoreService {
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId);
  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data, {bool merge = true});
  Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data);
  Future<void> deleteDocument(String collection, String documentId);
  Stream<Map<String, dynamic>?> streamDocument(String collection, String documentId);
  Stream<List<Map<String, dynamic>>> streamCollection(String collection);
  CollectionReference<Map<String, dynamic>> collection(String collectionPath);
}

/// Firebase Cloud Firestore implementation.
class FirestoreServiceImpl implements FirestoreService {
  FirestoreServiceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _firestore.collection(collectionPath);
  }

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.data();
    } catch (e, st) {
      AppLogger.error('Firestore getDocument failed [$collection/$documentId]', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data, SetOptions(merge: merge));
    } catch (e, st) {
      AppLogger.error('Firestore setDocument failed [$collection/$documentId]', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e, st) {
      AppLogger.error('Firestore updateDocument failed [$collection/$documentId]', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e, st) {
      AppLogger.error('Firestore deleteDocument failed [$collection/$documentId]', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<Map<String, dynamic>?> streamDocument(String collection, String documentId) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Stream<List<Map<String, dynamic>>> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
        );
  }
}
