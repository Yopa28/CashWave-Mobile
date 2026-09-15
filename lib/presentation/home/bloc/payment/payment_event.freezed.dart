// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentEvent {

 String get idPelanggan;
/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentEventCopyWith<PaymentEvent> get copyWith => _$PaymentEventCopyWithImpl<PaymentEvent>(this as PaymentEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentEvent&&(identical(other.idPelanggan, _this.idPelanggan) || other.idPelanggan == _this.idPelanggan));
}


@override
int get hashCode {
  final _this = this as PaymentEvent;
  return Object.hash(runtimeType,_this.idPelanggan);
}

@override
String toString() {
  final _this = this as PaymentEvent;
  return 'PaymentEvent(idPelanggan: ${_this.idPelanggan})';
}


}

/// @nodoc
abstract mixin class $PaymentEventCopyWith<$Res>  {
  factory $PaymentEventCopyWith(PaymentEvent value, $Res Function(PaymentEvent) _then) = _$PaymentEventCopyWithImpl;
@useResult
$Res call({
 String idPelanggan
});




}
/// @nodoc
class _$PaymentEventCopyWithImpl<$Res>
    implements $PaymentEventCopyWith<$Res> {
  _$PaymentEventCopyWithImpl(this._self, this._then);

  final PaymentEvent _self;
  final $Res Function(PaymentEvent) _then;

/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idPelanggan = null,}) {
  return _then(PaymentEvent.bayarPdam(
idPelanggan: null == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentEvent].
extension PaymentEventPatterns on PaymentEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _BayarPdam value)?  bayarPdam,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BayarPdam() when bayarPdam != null:
return bayarPdam(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _BayarPdam value)  bayarPdam,}){
final _that = this;
switch (_that) {
case _BayarPdam():
return bayarPdam(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _BayarPdam value)?  bayarPdam,}){
final _that = this;
switch (_that) {
case _BayarPdam() when bayarPdam != null:
return bayarPdam(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String idPelanggan)?  bayarPdam,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BayarPdam() when bayarPdam != null:
return bayarPdam(_that.idPelanggan);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String idPelanggan)  bayarPdam,}) {final _that = this;
switch (_that) {
case _BayarPdam():
return bayarPdam(_that.idPelanggan);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String idPelanggan)?  bayarPdam,}) {final _that = this;
switch (_that) {
case _BayarPdam() when bayarPdam != null:
return bayarPdam(_that.idPelanggan);case _:
  return null;

}
}

}

/// @nodoc


class _BayarPdam implements PaymentEvent {
  const _BayarPdam({required this.idPelanggan});
  

@override final  String idPelanggan;

/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BayarPdamCopyWith<_BayarPdam> get copyWith => __$BayarPdamCopyWithImpl<_BayarPdam>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _BayarPdam&&(identical(other.idPelanggan, idPelanggan) || other.idPelanggan == idPelanggan));
}


@override
int get hashCode {
    return Object.hash(runtimeType,idPelanggan);
}

@override
String toString() {
    return 'PaymentEvent.bayarPdam(idPelanggan: $idPelanggan)';
}


}

/// @nodoc
abstract mixin class _$BayarPdamCopyWith<$Res> implements $PaymentEventCopyWith<$Res> {
  factory _$BayarPdamCopyWith(_BayarPdam value, $Res Function(_BayarPdam) _then) = __$BayarPdamCopyWithImpl;
@override @useResult
$Res call({
 String idPelanggan
});




}
/// @nodoc
class __$BayarPdamCopyWithImpl<$Res>
    implements _$BayarPdamCopyWith<$Res> {
  __$BayarPdamCopyWithImpl(this._self, this._then);

  final _BayarPdam _self;
  final $Res Function(_BayarPdam) _then;

/// Create a copy of PaymentEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idPelanggan = null,}) {
  return _then(_BayarPdam(
idPelanggan: null == idPelanggan ? _self.idPelanggan : idPelanggan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
