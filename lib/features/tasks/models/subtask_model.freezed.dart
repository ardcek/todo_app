// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subtask_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubtaskModel _$SubtaskModelFromJson(Map<String, dynamic> json) {
  return _SubtaskModel.fromJson(json);
}

/// @nodoc
mixin _$SubtaskModel {
  int get id => throw _privateConstructorUsedError;
  int get taskId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;
  int get orderIndex => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SubtaskModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubtaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubtaskModelCopyWith<SubtaskModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubtaskModelCopyWith<$Res> {
  factory $SubtaskModelCopyWith(
    SubtaskModel value,
    $Res Function(SubtaskModel) then,
  ) = _$SubtaskModelCopyWithImpl<$Res, SubtaskModel>;
  @useResult
  $Res call({
    int id,
    int taskId,
    String title,
    bool completed,
    int orderIndex,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$SubtaskModelCopyWithImpl<$Res, $Val extends SubtaskModel>
    implements $SubtaskModelCopyWith<$Res> {
  _$SubtaskModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubtaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? title = null,
    Object? completed = null,
    Object? orderIndex = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            taskId: null == taskId
                ? _value.taskId
                : taskId // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
            orderIndex: null == orderIndex
                ? _value.orderIndex
                : orderIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubtaskModelImplCopyWith<$Res>
    implements $SubtaskModelCopyWith<$Res> {
  factory _$$SubtaskModelImplCopyWith(
    _$SubtaskModelImpl value,
    $Res Function(_$SubtaskModelImpl) then,
  ) = __$$SubtaskModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int taskId,
    String title,
    bool completed,
    int orderIndex,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$SubtaskModelImplCopyWithImpl<$Res>
    extends _$SubtaskModelCopyWithImpl<$Res, _$SubtaskModelImpl>
    implements _$$SubtaskModelImplCopyWith<$Res> {
  __$$SubtaskModelImplCopyWithImpl(
    _$SubtaskModelImpl _value,
    $Res Function(_$SubtaskModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubtaskModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? title = null,
    Object? completed = null,
    Object? orderIndex = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$SubtaskModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        taskId: null == taskId
            ? _value.taskId
            : taskId // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
        orderIndex: null == orderIndex
            ? _value.orderIndex
            : orderIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubtaskModelImpl implements _SubtaskModel {
  const _$SubtaskModelImpl({
    required this.id,
    required this.taskId,
    required this.title,
    this.completed = false,
    required this.orderIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$SubtaskModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubtaskModelImplFromJson(json);

  @override
  final int id;
  @override
  final int taskId;
  @override
  final String title;
  @override
  @JsonKey()
  final bool completed;
  @override
  final int orderIndex;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SubtaskModel(id: $id, taskId: $taskId, title: $title, completed: $completed, orderIndex: $orderIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubtaskModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.completed, completed) ||
                other.completed == completed) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    taskId,
    title,
    completed,
    orderIndex,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SubtaskModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubtaskModelImplCopyWith<_$SubtaskModelImpl> get copyWith =>
      __$$SubtaskModelImplCopyWithImpl<_$SubtaskModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubtaskModelImplToJson(this);
  }
}

abstract class _SubtaskModel implements SubtaskModel {
  const factory _SubtaskModel({
    required final int id,
    required final int taskId,
    required final String title,
    final bool completed,
    required final int orderIndex,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$SubtaskModelImpl;

  factory _SubtaskModel.fromJson(Map<String, dynamic> json) =
      _$SubtaskModelImpl.fromJson;

  @override
  int get id;
  @override
  int get taskId;
  @override
  String get title;
  @override
  bool get completed;
  @override
  int get orderIndex;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SubtaskModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubtaskModelImplCopyWith<_$SubtaskModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
