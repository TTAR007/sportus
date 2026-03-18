import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/app_exception.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  ActivityRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('activities');

  // ---------------------------------------------------------------------------
  // Stream — real-time activity list
  // ---------------------------------------------------------------------------

  Stream<List<ActivityModel>> streamActivities({
    String? sportTypeFilter,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _collection
        .where('deletedAt', isNull: true)
        .where('dateTime', isGreaterThan: Timestamp.now())
        .orderBy('dateTime')
        .limit(limit);

    if (sportTypeFilter != null) {
      query = query.where('sportType', isEqualTo: sportTypeFilter);
    }

    return query.snapshots().map(
          (snap) =>
              snap.docs.map(ActivityModel.fromFirestore).toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Stream — user's activities (hosted or joined)
  // ---------------------------------------------------------------------------

  Stream<List<ActivityModel>> streamUserActivities(String userId) {
    final hostedQuery = _collection
        .where('deletedAt', isNull: true)
        .where('hostId', isEqualTo: userId)
        .orderBy('dateTime', descending: true);

    final joinedQuery = _collection
        .where('deletedAt', isNull: true)
        .where('participantIds', arrayContains: userId)
        .orderBy('dateTime', descending: true);

    // Merge both streams via a StreamController. Either stream emitting
    // triggers a re-merge so the UI always reflects the latest data.
    final controller = StreamController<List<ActivityModel>>();
    List<ActivityModel> hostedList = [];
    List<ActivityModel> joinedList = [];

    void merge() {
      final Map<String, ActivityModel> deduped = {};
      for (final a in hostedList) {
        deduped[a.id] = a;
      }
      for (final a in joinedList) {
        deduped[a.id] = a;
      }
      final list = deduped.values.toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      controller.add(list);
    }

    final sub1 = hostedQuery.snapshots().listen((snap) {
      hostedList = snap.docs.map(ActivityModel.fromFirestore).toList();
      merge();
    });

    final sub2 = joinedQuery.snapshots().listen((snap) {
      joinedList = snap.docs.map(ActivityModel.fromFirestore).toList();
      merge();
    });

    controller.onCancel = () {
      sub1.cancel();
      sub2.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // ---------------------------------------------------------------------------
  // Read — single activity
  // ---------------------------------------------------------------------------

  Future<Either<AppException, ActivityModel>> getActivity(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) {
        return Left(AppException.notFound());
      }
      return Right(ActivityModel.fromFirestore(doc));
    } on FirebaseException catch (e) {
      return Left(AppException.firebase(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<Either<AppException, ActivityModel>> createActivity({
    required String title,
    required String sportType,
    required DateTime dateTime,
    required String location,
    required int maxParticipants,
    String? description,
    required String hostId,
    required String hostName,
  }) async {
    try {
      final docRef = await _collection.add({
        'title': title,
        'sportType': sportType,
        'dateTime': Timestamp.fromDate(dateTime),
        'location': location,
        'maxParticipants': maxParticipants,
        'description': description,
        'hostId': hostId,
        'hostName': hostName,
        'participantIds': <String>[],
        'currentParticipants': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deletedAt': null,
      });

      final snap = await docRef.get();
      return Right(ActivityModel.fromFirestore(snap));
    } on FirebaseException catch (e) {
      return Left(AppException.firebase(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<Either<AppException, void>> updateActivity(
    String id, {
    String? title,
    String? sportType,
    DateTime? dateTime,
    String? location,
    int? maxParticipants,
    String? description,
  }) async {
    try {
      // If maxParticipants is being reduced, verify it's still valid.
      if (maxParticipants != null) {
        final doc = await _collection.doc(id).get();
        if (!doc.exists) return Left(AppException.notFound());
        final model = ActivityModel.fromFirestore(doc);
        if (maxParticipants < model.currentParticipants) {
          return Left(AppException.validation(
            'Cannot set max participants below current count '
            '(${model.currentParticipants}).',
          ));
        }
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (title != null) updates['title'] = title;
      if (sportType != null) updates['sportType'] = sportType;
      if (dateTime != null) {
        updates['dateTime'] = Timestamp.fromDate(dateTime);
      }
      if (location != null) updates['location'] = location;
      if (maxParticipants != null) {
        updates['maxParticipants'] = maxParticipants;
      }
      if (description != null) updates['description'] = description;

      await _collection.doc(id).update(updates);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(AppException.firebase(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Soft-delete
  // ---------------------------------------------------------------------------

  Future<Either<AppException, void>> deleteActivity(String id) async {
    try {
      await _collection.doc(id).update({
        'deletedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(AppException.firebase(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Join — transactional
  // ---------------------------------------------------------------------------

  Future<Either<AppException, void>> joinActivity(
    String activityId,
    String userId,
  ) async {
    try {
      await _firestore.runTransaction((tx) async {
        final ref = _collection.doc(activityId);
        final snap = await tx.get(ref);

        if (!snap.exists) throw AppException.notFound();

        final model = ActivityModel.fromFirestore(snap);

        if (model.currentParticipants >= model.maxParticipants) {
          throw AppException.activityFull();
        }
        if (model.participantIds.contains(userId)) {
          throw AppException.alreadyJoined();
        }

        tx.update(ref, {
          'participantIds': FieldValue.arrayUnion([userId]),
          'currentParticipants': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } on FirebaseException catch (e) {
      return Left(AppException.firebase(e.code, e.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Leave — transactional
  // ---------------------------------------------------------------------------

  Future<Either<AppException, void>> leaveActivity(
    String activityId,
    String userId,
  ) async {
    try {
      await _firestore.runTransaction((tx) async {
        final ref = _collection.doc(activityId);
        final snap = await tx.get(ref);

        if (!snap.exists) throw AppException.notFound();

        final model = ActivityModel.fromFirestore(snap);

        if (!model.participantIds.contains(userId)) {
          return; // User is not a participant — no-op
        }

        tx.update(ref, {
          'participantIds': FieldValue.arrayRemove([userId]),
          'currentParticipants': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } on FirebaseException catch (e) {
      return Left(AppException.firebase(e.code, e.message));
    }
  }
}
