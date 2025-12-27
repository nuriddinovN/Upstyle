import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:up_style/features/auth/data/models/user_model.dart';
import '../../../../core/errors/failures.dart';

abstract class CreatorsRemoteDataSource {
  Future<List<UserModel>> getCreators({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  });
  Future<UserModel> getCreatorById(String creatorId);
  Future<void> becomeCreator({
    required String bio,
    required List<String> specializations,
  });
  Future<void> switchToCreatorMode();
  Future<void> switchToUserMode();
  Future<List<UserModel>> searchCreators(String query);
}

class FirebaseCreatorsDataSource implements CreatorsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseCreatorsDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw AuthFailure('No user logged in');
    return user.uid;
  }

  @override
  Future<List<UserModel>> getCreators({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('isCreator', isEqualTo: true)
          .orderBy('creatorInfo.rating', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerFailure('Failed to get creators: $e');
    }
  }

  @override
  Future<UserModel> getCreatorById(String creatorId) async {
    try {
      final doc = await _firestore.collection('users').doc(creatorId).get();

      if (!doc.exists) {
        throw NotFoundFailure('Creator not found');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundFailure) rethrow;
      throw ServerFailure('Failed to get creator: $e');
    }
  }

  @override
  Future<void> becomeCreator({
    required String bio,
    required List<String> specializations,
  }) async {
    try {
      // Create the creator info map manually (domain entity doesn't have toMap)
      final creatorInfoMap = {
        'specializations': specializations,
        'rating': 0.0,
        'itemsHelped': 0,
        'responseTime': '< 24 hours',
        'bio': bio,
        'becameCreatorAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(_userId).update({
        'isCreator': true,
        'role': 'creator',
        'creatorInfo': creatorInfoMap,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to become creator: $e');
    }
  }

  @override
  Future<void> switchToCreatorMode() async {
    try {
      await _firestore.collection('users').doc(_userId).update({
        'role': 'creator',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to switch to creator mode: $e');
    }
  }

  @override
  Future<void> switchToUserMode() async {
    try {
      await _firestore.collection('users').doc(_userId).update({
        'role': 'user',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerFailure('Failed to switch to user mode: $e');
    }
  }

  @override
  Future<List<UserModel>> searchCreators(String query) async {
    try {
      // Search by name (case-insensitive search requires composite index)
      final snapshot = await _firestore
          .collection('users')
          .where('isCreator', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerFailure('Failed to search creators: $e');
    }
  }
}
