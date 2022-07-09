// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String,
      isReminder: json['isReminder'] as bool,
      isDone: json['isDone'] as bool,
      notificationId: json['notificationId'] as int?,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'title': instance.title,
      'isReminder': instance.isReminder,
      'isDone': instance.isDone,
      'notificationId': instance.notificationId,
    };
