// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubtaskModelImpl _$$SubtaskModelImplFromJson(Map<String, dynamic> json) =>
    _$SubtaskModelImpl(
      id: (json['id'] as num).toInt(),
      taskId: (json['taskId'] as num).toInt(),
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
      orderIndex: (json['orderIndex'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$SubtaskModelImplToJson(_$SubtaskModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'taskId': instance.taskId,
      'title': instance.title,
      'completed': instance.completed,
      'orderIndex': instance.orderIndex,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
