// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaymentEvent {
  String get idPelanggan => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String idPelanggan) bayarPdam,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String idPelanggan)? bayarPdam,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String idPelanggan)? bayarPdam,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_BayarPdam value) bayarPdam,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BayarPdam value)? bayarPdam,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BayarPdam value)? bayarPdam,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaymentEventCopyWith<PaymentEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaymentEventCopyWith<$Res> {
  factory $PaymentEventCopyWith(
    PaymentEvent value,
    $Res Function(PaymentEvent) then,
  ) = _$PaymentEventCopyWithImpl<$Res, PaymentEvent>;
  @useResult
  $Res call({String idPelanggan});
}

/// @nodoc
class _$PaymentEventCopyWithImpl<$Res, $Val extends PaymentEvent>
    implements $PaymentEventCopyWith<$Res> {
  _$PaymentEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? idPelanggan = null}) {
    return _then(
      _value.copyWith(
            idPelanggan: null == idPelanggan
                ? _value.idPelanggan
                : idPelanggan // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BayarPdamImplCopyWith<$Res>
    implements $PaymentEventCopyWith<$Res> {
  factory _$$BayarPdamImplCopyWith(
    _$BayarPdamImpl value,
    $Res Function(_$BayarPdamImpl) then,
  ) = __$$BayarPdamImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String idPelanggan});
}

/// @nodoc
class __$$BayarPdamImplCopyWithImpl<$Res>
    extends _$PaymentEventCopyWithImpl<$Res, _$BayarPdamImpl>
    implements _$$BayarPdamImplCopyWith<$Res> {
  __$$BayarPdamImplCopyWithImpl(
    _$BayarPdamImpl _value,
    $Res Function(_$BayarPdamImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? idPelanggan = null}) {
    return _then(
      _$BayarPdamImpl(
        idPelanggan: null == idPelanggan
            ? _value.idPelanggan
            : idPelanggan // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$BayarPdamImpl implements _BayarPdam {
  const _$BayarPdamImpl({required this.idPelanggan});

  @override
  final String idPelanggan;

  @override
  String toString() {
    return 'PaymentEvent.bayarPdam(idPelanggan: $idPelanggan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BayarPdamImpl &&
            (identical(other.idPelanggan, idPelanggan) ||
                other.idPelanggan == idPelanggan));
  }

  @override
  int get hashCode => Object.hash(runtimeType, idPelanggan);

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BayarPdamImplCopyWith<_$BayarPdamImpl> get copyWith =>
      __$$BayarPdamImplCopyWithImpl<_$BayarPdamImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String idPelanggan) bayarPdam,
  }) {
    return bayarPdam(idPelanggan);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String idPelanggan)? bayarPdam,
  }) {
    return bayarPdam?.call(idPelanggan);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String idPelanggan)? bayarPdam,
    required TResult orElse(),
  }) {
    if (bayarPdam != null) {
      return bayarPdam(idPelanggan);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_BayarPdam value) bayarPdam,
  }) {
    return bayarPdam(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_BayarPdam value)? bayarPdam,
  }) {
    return bayarPdam?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_BayarPdam value)? bayarPdam,
    required TResult orElse(),
  }) {
    if (bayarPdam != null) {
      return bayarPdam(this);
    }
    return orElse();
  }
}

abstract class _BayarPdam implements PaymentEvent {
  const factory _BayarPdam({required final String idPelanggan}) =
      _$BayarPdamImpl;

  @override
  String get idPelanggan;

  /// Create a copy of PaymentEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BayarPdamImplCopyWith<_$BayarPdamImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
