import 'package:freezed_annotation/freezed_annotation.dart';

part 'subtask_model.freezed.dart';
part 'subtask_model.g.dart';

@freezed
class SubtaskModel with _$SubtaskModel {
  const factory SubtaskModel({
    required int id,
    required int taskId,
    required String title,
    @Default(false) bool completed,
    required int orderIndex,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SubtaskModel;

  factory SubtaskModel.fromJson(Map<String, dynamic> json) =>
      _$SubtaskModelFromJson(json);
}
