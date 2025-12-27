import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/category_model.dart';
import '../../domain/entities/category.dart';
import '../../../../core/errors/failures.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory({required String title});
  Future<void> deleteCategory(String categoryId);
  Future<CategoryModel> updateCategory(
      {required String categoryId, required String title});
  Future<CategoryModel> getCategoryById(String categoryId);
  Future<void> initializeDefaultCategories();
  Stream<List<CategoryModel>> watchCategories();
}

class FirebaseCategoriesDataSource implements CategoriesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebaseCategoriesDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthFailure('No user logged in');
    }
    return user.uid;
  }

  CollectionReference get _categoriesRef =>
      _firestore.collection('users').doc(_userId).collection('categories');

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot =
          await _categoriesRef.orderBy('createdAt', descending: false).get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get categories: $e');
    }
  }

  @override
  Future<CategoryModel> createCategory({required String title}) async {
    try {
      final now = DateTime.now();
      final categoryData = {
        'title': title,
        'userId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
        'isDefault': false,
        'itemCount': 0,
        'upcycledCount': 0,
        'upstyledCount': 0,
      };

      final docRef = await _categoriesRef.add(categoryData);
      final doc = await docRef.get();

      return CategoryModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to create category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoriesRef.doc(categoryId).delete();
    } catch (e) {
      throw ServerFailure('Failed to delete category: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required String categoryId,
    required String title,
  }) async {
    try {
      await _categoriesRef.doc(categoryId).update({
        'title': title,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final doc = await _categoriesRef.doc(categoryId).get();
      return CategoryModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to update category: $e');
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String categoryId) async {
    try {
      final doc = await _categoriesRef.doc(categoryId).get();

      if (!doc.exists) {
        throw NotFoundFailure('Category not found');
      }

      return CategoryModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundFailure) rethrow;
      throw ServerFailure('Failed to get category: $e');
    }
  }

  @override
  Future<void> initializeDefaultCategories() async {
    try {
      final batch = _firestore.batch();

      for (final categoryTitle in DefaultCategories.categories) {
        // Check if default category already exists
        final existingQuery = await _categoriesRef
            .where('title', isEqualTo: categoryTitle)
            .where('isDefault', isEqualTo: true)
            .limit(1)
            .get();

        if (existingQuery.docs.isEmpty) {
          final docRef = _categoriesRef.doc();
          batch.set(docRef, {
            'title': categoryTitle,
            'userId': _userId,
            'createdAt': FieldValue.serverTimestamp(),
            'isDefault': true,
            'itemCount': 0,
            'upcycledCount': 0,
            'upstyledCount': 0,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      throw ServerFailure('Failed to initialize default categories: $e');
    }
  }

  @override
  Stream<List<CategoryModel>> watchCategories() {
    try {
      return _categoriesRef
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList());
    } catch (e) {
      throw ServerFailure('Failed to watch categories: $e');
    }
  }
}
