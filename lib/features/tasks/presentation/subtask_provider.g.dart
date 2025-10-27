// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subtask_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$subtaskProgressHash() => r'a7cc25609e8ba3c006fe2de284ea5639658d691c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [subtaskProgress].
@ProviderFor(subtaskProgress)
const subtaskProgressProvider = SubtaskProgressFamily();

/// See also [subtaskProgress].
class SubtaskProgressFamily extends Family<AsyncValue<SubtaskProgress>> {
  /// See also [subtaskProgress].
  const SubtaskProgressFamily();

  /// See also [subtaskProgress].
  SubtaskProgressProvider call(int taskId) {
    return SubtaskProgressProvider(taskId);
  }

  @override
  SubtaskProgressProvider getProviderOverride(
    covariant SubtaskProgressProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subtaskProgressProvider';
}

/// See also [subtaskProgress].
class SubtaskProgressProvider
    extends AutoDisposeFutureProvider<SubtaskProgress> {
  /// See also [subtaskProgress].
  SubtaskProgressProvider(int taskId)
    : this._internal(
        (ref) => subtaskProgress(ref as SubtaskProgressRef, taskId),
        from: subtaskProgressProvider,
        name: r'subtaskProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subtaskProgressHash,
        dependencies: SubtaskProgressFamily._dependencies,
        allTransitiveDependencies:
            SubtaskProgressFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  SubtaskProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  Override overrideWith(
    FutureOr<SubtaskProgress> Function(SubtaskProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SubtaskProgressProvider._internal(
        (ref) => create(ref as SubtaskProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SubtaskProgress> createElement() {
    return _SubtaskProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubtaskProgressProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubtaskProgressRef on AutoDisposeFutureProviderRef<SubtaskProgress> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _SubtaskProgressProviderElement
    extends AutoDisposeFutureProviderElement<SubtaskProgress>
    with SubtaskProgressRef {
  _SubtaskProgressProviderElement(super.provider);

  @override
  int get taskId => (origin as SubtaskProgressProvider).taskId;
}

String _$subtaskNotifierHash() => r'e9de0c6b0ccea9de5d6541647d3857e8ccd84f88';

abstract class _$SubtaskNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<SubtaskModel>> {
  late final int taskId;

  FutureOr<List<SubtaskModel>> build(int taskId);
}

/// See also [SubtaskNotifier].
@ProviderFor(SubtaskNotifier)
const subtaskNotifierProvider = SubtaskNotifierFamily();

/// See also [SubtaskNotifier].
class SubtaskNotifierFamily extends Family<AsyncValue<List<SubtaskModel>>> {
  /// See also [SubtaskNotifier].
  const SubtaskNotifierFamily();

  /// See also [SubtaskNotifier].
  SubtaskNotifierProvider call(int taskId) {
    return SubtaskNotifierProvider(taskId);
  }

  @override
  SubtaskNotifierProvider getProviderOverride(
    covariant SubtaskNotifierProvider provider,
  ) {
    return call(provider.taskId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'subtaskNotifierProvider';
}

/// See also [SubtaskNotifier].
class SubtaskNotifierProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          SubtaskNotifier,
          List<SubtaskModel>
        > {
  /// See also [SubtaskNotifier].
  SubtaskNotifierProvider(int taskId)
    : this._internal(
        () => SubtaskNotifier()..taskId = taskId,
        from: subtaskNotifierProvider,
        name: r'subtaskNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$subtaskNotifierHash,
        dependencies: SubtaskNotifierFamily._dependencies,
        allTransitiveDependencies:
            SubtaskNotifierFamily._allTransitiveDependencies,
        taskId: taskId,
      );

  SubtaskNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.taskId,
  }) : super.internal();

  final int taskId;

  @override
  FutureOr<List<SubtaskModel>> runNotifierBuild(
    covariant SubtaskNotifier notifier,
  ) {
    return notifier.build(taskId);
  }

  @override
  Override overrideWith(SubtaskNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SubtaskNotifierProvider._internal(
        () => create()..taskId = taskId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        taskId: taskId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<SubtaskNotifier, List<SubtaskModel>>
  createElement() {
    return _SubtaskNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SubtaskNotifierProvider && other.taskId == taskId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, taskId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SubtaskNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<List<SubtaskModel>> {
  /// The parameter `taskId` of this provider.
  int get taskId;
}

class _SubtaskNotifierProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          SubtaskNotifier,
          List<SubtaskModel>
        >
    with SubtaskNotifierRef {
  _SubtaskNotifierProviderElement(super.provider);

  @override
  int get taskId => (origin as SubtaskNotifierProvider).taskId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
