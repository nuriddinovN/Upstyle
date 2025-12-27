import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:up_style/features/warderobe/data/models/fashionclip_models.dart';
import 'package:uuid/uuid.dart';
import '../models/item_model.dart';
import '../models/paginated_items.dart';
import '../../domain/entities/item.dart';
import '../../../../core/errors/failures.dart';

abstract class ItemsRemoteDataSource {
  Future<ItemModel> createItem({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
  });

  // ADD THIS NEW METHOD
  Future<ItemModel> createItemWithAnalysis({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
    required FashionAnalysis analysis,
  });

  Future<PaginatedItems> getItems(ItemQuery query);
  Future<ItemModel> getItemById(String itemId);
  Future<ItemModel> updateItem({
    required String itemId,
    String? name,
    String? description,
    String? categoryId,
    String? color,
    File? imageFile,
  });

  Future<void> deleteItem(String itemId);
  Stream<PaginatedItems> watchItems(ItemQuery query);
  Future<List<ItemModel>> getItemsByCategory(String categoryId);
  Future<ItemModel> saveTransformedItem(ItemModel item);
}

class FirebaseItemsDataSource implements ItemsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  static const _uuid = Uuid();

  FirebaseItemsDataSource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthFailure('No user logged in');
    }
    return user.uid;
  }

  CollectionReference get _itemsRef =>
      _firestore.collection('users').doc(_userId).collection('items');

  @override
  Future<ItemModel> createItem({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
  }) async {
    try {
      // Upload image first
      final imageUrl = await _uploadImage(imageFile);

      final now = DateTime.now();
      final itemData = {
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'userId': _userId,
        'color': color,
        'imageUrl': imageUrl,
        'isUpcycled': false,
        'isUpStyled': false,
        'originalItemId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _itemsRef.add(itemData);
      final doc = await docRef.get();

      // Update category item count
      await _updateCategoryCount(categoryId, increment: true);

      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to create item: $e');
    }
  }

  // ADD THIS NEW METHOD
  @override
  Future<ItemModel> createItemWithAnalysis({
    required String name,
    required String description,
    required String categoryId,
    required String color,
    required File imageFile,
    required FashionAnalysis analysis,
  }) async {
    try {
      // Upload image first
      final imageUrl = await _uploadImage(imageFile);

      final now = DateTime.now();
      final itemData = {
        'name': name,
        'description': description,
        'categoryId': categoryId,
        'userId': _userId,
        'color': color,
        'imageUrl': imageUrl,
        'isUpcycled': false,
        'isUpStyled': false,
        'originalItemId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        // ADD ALL FASHIONCLIP FIELDS CONDITIONALLY
        'category': analysis.category,
        'subCategory': analysis.subCategory,
        if (analysis.gender != null) 'gender': analysis.gender,
        if (analysis.primaryColor != null)
          'primaryColor': analysis.primaryColor,
        if (analysis.secondaryColor != null)
          'secondaryColor': analysis.secondaryColor,
        if (analysis.accentColor != null) 'accentColor': analysis.accentColor,
        if (analysis.pattern != null) 'pattern': analysis.pattern,
        if (analysis.material != null) 'material': analysis.material,
        if (analysis.fit != null) 'fit': analysis.fit,
        if (analysis.silhouette != null) 'silhouette': analysis.silhouette,
        if (analysis.neckline != null) 'neckline': analysis.neckline,
        if (analysis.sleeve != null) 'sleeve': analysis.sleeve,
        if (analysis.length != null) 'length': analysis.length,
        if (analysis.rise != null) 'rise': analysis.rise,
        if (analysis.closureType != null) 'closureType': analysis.closureType,
        if (analysis.style != null) 'style': analysis.style,
        if (analysis.occasion != null) 'occasion': analysis.occasion,
        if (analysis.season != null) 'season': analysis.season,
        if (analysis.bodyShape != null) 'bodyShape': analysis.bodyShape,
        if (analysis.aestheticKeywords != null)
          'aestheticKeywords': analysis.aestheticKeywords,
        if (analysis.detailFeatures != null)
          'detailFeatures': analysis.detailFeatures,
        if (analysis.upcyclingPotential != null)
          'upcyclingPotential': analysis.upcyclingPotential,
        if (analysis.upcyclingType != null)
          'upcyclingType': analysis.upcyclingType,
        if (analysis.repairability != null)
          'repairability': analysis.repairability,
        if (analysis.sustainability != null)
          'sustainability': analysis.sustainability,
        if (analysis.visibleAccessories != null)
          'visibleAccessories': analysis.visibleAccessories,
      };

      final docRef = await _itemsRef.add(itemData);
      final doc = await docRef.get();

      // Update category item count
      await _updateCategoryCount(categoryId, increment: true);

      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to create item with analysis: $e');
    }
  }

  @override
  Future<PaginatedItems> getItems(ItemQuery query) async {
    try {
      Query<Object?> firestoreQuery = _itemsRef;

      // Apply filters
      if (query.filter.categoryId != null) {
        firestoreQuery = firestoreQuery.where('categoryId',
            isEqualTo: query.filter.categoryId);
      }

      if (query.filter.color != null) {
        firestoreQuery =
            firestoreQuery.where('color', isEqualTo: query.filter.color);
      }

      if (query.filter.onlyUpcycled == true) {
        firestoreQuery = firestoreQuery.where('isUpcycled', isEqualTo: true);
      }

      if (query.filter.onlyUpStyled == true) {
        firestoreQuery = firestoreQuery.where('isUpStyled', isEqualTo: true);
      }

      // Apply sorting
      switch (query.sortBy) {
        case ItemSortOption.dateDesc:
          firestoreQuery =
              firestoreQuery.orderBy('createdAt', descending: true);
          break;
        case ItemSortOption.dateAsc:
          firestoreQuery =
              firestoreQuery.orderBy('createdAt', descending: false);
          break;
        case ItemSortOption.name:
          firestoreQuery = firestoreQuery.orderBy('name');
          break;
        case ItemSortOption.color:
          firestoreQuery = firestoreQuery.orderBy('color');
          break;
      }

      // Apply pagination
      if (query.lastItemId != null) {
        final lastDoc = await _itemsRef.doc(query.lastItemId).get();
        firestoreQuery = firestoreQuery.startAfterDocument(lastDoc);
      }

      firestoreQuery = firestoreQuery
          .limit(query.limit + 1); // +1 to check if there are more

      final querySnapshot = await firestoreQuery.get();
      final docs = querySnapshot.docs;

      final hasMore = docs.length > query.limit;
      final items = docs
          .take(query.limit)
          .map((doc) => ItemModel.fromFirestore(doc))
          .toList();

      final nextPageToken = hasMore && items.isNotEmpty ? items.last.id : null;

      // Get total count (this could be expensive, consider caching)
      final totalSnapshot = await _itemsRef.count().get();
      final totalCount = totalSnapshot.count ?? 0;

      return PaginatedItems(
        items: items,
        hasMore: hasMore,
        nextPageToken: nextPageToken,
        totalCount: totalCount,
      );
    } catch (e) {
      throw ServerFailure('Failed to get items: $e');
    }
  }

  @override
  Future<ItemModel> getItemById(String itemId) async {
    try {
      final doc = await _itemsRef.doc(itemId).get();

      if (!doc.exists) {
        throw NotFoundFailure('Item not found');
      }

      return ItemModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundFailure) rethrow;
      throw ServerFailure('Failed to get item: $e');
    }
  }

  @override
  Future<ItemModel> updateItem({
    required String itemId,
    String? name,
    String? description,
    String? categoryId,
    String? color,
    File? imageFile,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (categoryId != null) updates['categoryId'] = categoryId;
      if (color != null) updates['color'] = color;

      if (imageFile != null) {
        // Delete old image and upload new one
        final oldDoc = await _itemsRef.doc(itemId).get();
        if (oldDoc.exists) {
          final oldItem = ItemModel.fromFirestore(oldDoc);
          await _deleteImage(oldItem.imageUrl);
        }

        final newImageUrl = await _uploadImage(imageFile);
        updates['imageUrl'] = newImageUrl;
      }

      await _itemsRef.doc(itemId).update(updates);

      final doc = await _itemsRef.doc(itemId).get();
      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to update item: $e');
    }
  }

  @override
  Future<void> deleteItem(String itemId) async {
    try {
      final doc = await _itemsRef.doc(itemId).get();
      if (doc.exists) {
        final item = ItemModel.fromFirestore(doc);

        // Delete image from storage
        await _deleteImage(item.imageUrl);

        // Update category count
        await _updateCategoryCount(item.categoryId, increment: false);

        // Delete item document
        await _itemsRef.doc(itemId).delete();
      }
    } catch (e) {
      throw ServerFailure('Failed to delete item: $e');
    }
  }

  @override
  Stream<PaginatedItems> watchItems(ItemQuery query) {
    // For simplicity, we'll return a stream that emits the current items
    // In a production app, you might want to implement real-time updates
    return Stream.fromFuture(getItems(query));
  }

  @override
  Future<List<ItemModel>> getItemsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _itemsRef
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ItemModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerFailure('Failed to get items by category: $e');
    }
  }

  @override
  Future<ItemModel> saveTransformedItem(ItemModel item) async {
    try {
      final docRef = await _itemsRef.add(item.toFirestore());
      final doc = await docRef.get();

      // Update category counts
      await _updateCategoryCount(item.categoryId, increment: true);

      if (item.isUpcycled) {
        await _updateCategoryCount(item.categoryId, incrementUpcycled: true);
      }

      if (item.isUpStyled) {
        await _updateCategoryCount(item.categoryId, incrementUpStyled: true);
      }

      return ItemModel.fromFirestore(doc);
    } catch (e) {
      throw ServerFailure('Failed to save transformed item: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref = _storage
          .ref()
          .child('users')
          .child(_userId)
          .child('items')
          .child(fileName);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw ServerFailure('Failed to upload image: $e');
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) return;

      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Ignore errors when deleting images (file might not exist)
    }
  }

  Future<void> _updateCategoryCount(
    String categoryId, {
    bool increment = false,
    bool incrementUpcycled = false,
    bool incrementUpStyled = false,
  }) async {
    try {
      final categoryRef = _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .doc(categoryId);

      final updates = <String, dynamic>{};

      if (increment != false) {
        updates['itemCount'] = FieldValue.increment(increment ? 1 : -1);
      }

      if (incrementUpcycled) {
        updates['upcycledCount'] = FieldValue.increment(1);
      }

      if (incrementUpStyled) {
        updates['upstyledCount'] = FieldValue.increment(1);
      }

      if (updates.isNotEmpty) {
        await categoryRef.update(updates);
      }
    } catch (e) {
      // Don't fail the main operation if category update fails
    }
  }
}
