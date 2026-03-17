// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    _ActivityModel(
      id: json['id'] as String,
      title: json['title'] as String,
      sportType: json['sportType'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      description: json['description'] as String?,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      participantIds:
          (json['participantIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$ActivityModelToJson(_ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'sportType': instance.sportType,
      'dateTime': instance.dateTime.toIso8601String(),
      'location': instance.location,
      'maxParticipants': instance.maxParticipants,
      'description': instance.description,
      'hostId': instance.hostId,
      'hostName': instance.hostName,
      'participantIds': instance.participantIds,
      'currentParticipants': instance.currentParticipants,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
