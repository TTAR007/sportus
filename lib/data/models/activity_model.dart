import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
sealed class ActivityModel with _$ActivityModel {
  const ActivityModel._();

  const factory ActivityModel({
    required String id,
    required String title,
    required String sportType,
    required DateTime dateTime,
    required String location,
    required int maxParticipants,
    String? description,
    required String hostId,
    required String hostName,
    @Default([]) List<String> participantIds,
    @Default(0) int currentParticipants,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      title: data['title'] as String,
      sportType: data['sportType'] as String,
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] as String,
      maxParticipants: data['maxParticipants'] as int,
      description: data['description'] as String?,
      hostId: data['hostId'] as String,
      hostName: data['hostName'] as String,
      participantIds: List<String>.from(
        (data['participantIds'] as List?) ?? [],
      ),
      currentParticipants: data['currentParticipants'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Converts the model to a map suitable for Firestore writes.
  /// Does NOT include `id` (it's the document ID, not a field).
  /// Does NOT include `createdAt`/`updatedAt` — use FieldValue.serverTimestamp().
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'sportType': sportType,
      'dateTime': Timestamp.fromDate(dateTime),
      'location': location,
      'maxParticipants': maxParticipants,
      'description': description,
      'hostId': hostId,
      'hostName': hostName,
      'participantIds': participantIds,
      'currentParticipants': currentParticipants,
    };
  }
}
