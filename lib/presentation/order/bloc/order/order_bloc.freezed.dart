// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderEvent {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderEvent()';
}


}

/// @nodoc
class $OrderEventCopyWith<$Res>  {
$OrderEventCopyWith(OrderEvent _, $Res Function(OrderEvent) __);
}


/// Adds pattern-matching-related methods to [OrderEvent].
extension OrderEventPatterns on OrderEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Started value)?  started,TResult Function( _AddPaymentMethod value)?  addPaymentMethod,TResult Function( _AddNominalBayar value)?  addNominalBayar,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _AddPaymentMethod() when addPaymentMethod != null:
return addPaymentMethod(_that);case _AddNominalBayar() when addNominalBayar != null:
return addNominalBayar(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Started value)  started,required TResult Function( _AddPaymentMethod value)  addPaymentMethod,required TResult Function( _AddNominalBayar value)  addNominalBayar,}){
final _that = this;
switch (_that) {
case _Started():
return started(_that);case _AddPaymentMethod():
return addPaymentMethod(_that);case _AddNominalBayar():
return addNominalBayar(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Started value)?  started,TResult? Function( _AddPaymentMethod value)?  addPaymentMethod,TResult? Function( _AddNominalBayar value)?  addNominalBayar,}){
final _that = this;
switch (_that) {
case _Started() when started != null:
return started(_that);case _AddPaymentMethod() when addPaymentMethod != null:
return addPaymentMethod(_that);case _AddNominalBayar() when addNominalBayar != null:
return addNominalBayar(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String paymentMethod,  List<OrderItem> orders,  String customerName)?  addPaymentMethod,TResult Function( int nominal)?  addNominalBayar,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _AddPaymentMethod() when addPaymentMethod != null:
return addPaymentMethod(_that.paymentMethod,_that.orders,_that.customerName);case _AddNominalBayar() when addNominalBayar != null:
return addNominalBayar(_that.nominal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String paymentMethod,  List<OrderItem> orders,  String customerName)  addPaymentMethod,required TResult Function( int nominal)  addNominalBayar,}) {final _that = this;
switch (_that) {
case _Started():
return started();case _AddPaymentMethod():
return addPaymentMethod(_that.paymentMethod,_that.orders,_that.customerName);case _AddNominalBayar():
return addNominalBayar(_that.nominal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String paymentMethod,  List<OrderItem> orders,  String customerName)?  addPaymentMethod,TResult? Function( int nominal)?  addNominalBayar,}) {final _that = this;
switch (_that) {
case _Started() when started != null:
return started();case _AddPaymentMethod() when addPaymentMethod != null:
return addPaymentMethod(_that.paymentMethod,_that.orders,_that.customerName);case _AddNominalBayar() when addNominalBayar != null:
return addNominalBayar(_that.nominal);case _:
  return null;

}
}

}

/// @nodoc


class _Started implements OrderEvent {
  const _Started();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Started);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderEvent.started()';
}


}




/// @nodoc


class _AddPaymentMethod implements OrderEvent {
  const _AddPaymentMethod(this.paymentMethod,  List<OrderItem> orders, this.customerName): _orders = orders;
  

 final  String paymentMethod;
 final  List<OrderItem> _orders;
 List<OrderItem> get orders {
  if (_orders is EqualUnmodifiableListView) return _orders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_orders);
}

 final  String customerName;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddPaymentMethodCopyWith<_AddPaymentMethod> get copyWith => __$AddPaymentMethodCopyWithImpl<_AddPaymentMethod>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddPaymentMethod&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&const DeepCollectionEquality().equals(other.orders, _orders)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,paymentMethod,const DeepCollectionEquality().hash(_orders),customerName);
}

@override
String toString() {
    return 'OrderEvent.addPaymentMethod(paymentMethod: $paymentMethod, orders: $orders, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$AddPaymentMethodCopyWith<$Res> implements $OrderEventCopyWith<$Res> {
  factory _$AddPaymentMethodCopyWith(_AddPaymentMethod value, $Res Function(_AddPaymentMethod) _then) = __$AddPaymentMethodCopyWithImpl;
@useResult
$Res call({
 String paymentMethod, List<OrderItem> orders, String customerName
});




}
/// @nodoc
class __$AddPaymentMethodCopyWithImpl<$Res>
    implements _$AddPaymentMethodCopyWith<$Res> {
  __$AddPaymentMethodCopyWithImpl(this._self, this._then);

  final _AddPaymentMethod _self;
  final $Res Function(_AddPaymentMethod) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paymentMethod = null,Object? orders = null,Object? customerName = null,}) {
  return _then(_AddPaymentMethod(
null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,null == orders ? _self._orders : orders // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _AddNominalBayar implements OrderEvent {
  const _AddNominalBayar(this.nominal);
  

 final  int nominal;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddNominalBayarCopyWith<_AddNominalBayar> get copyWith => __$AddNominalBayarCopyWithImpl<_AddNominalBayar>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddNominalBayar&&(identical(other.nominal, nominal) || other.nominal == nominal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,nominal);
}

@override
String toString() {
    return 'OrderEvent.addNominalBayar(nominal: $nominal)';
}


}

/// @nodoc
abstract mixin class _$AddNominalBayarCopyWith<$Res> implements $OrderEventCopyWith<$Res> {
  factory _$AddNominalBayarCopyWith(_AddNominalBayar value, $Res Function(_AddNominalBayar) _then) = __$AddNominalBayarCopyWithImpl;
@useResult
$Res call({
 int nominal
});




}
/// @nodoc
class __$AddNominalBayarCopyWithImpl<$Res>
    implements _$AddNominalBayarCopyWith<$Res> {
  __$AddNominalBayarCopyWithImpl(this._self, this._then);

  final _AddNominalBayar _self;
  final $Res Function(_AddNominalBayar) _then;

/// Create a copy of OrderEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? nominal = null,}) {
  return _then(_AddNominalBayar(
null == nominal ? _self.nominal : nominal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$OrderState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderState()';
}


}

/// @nodoc
class $OrderStateCopyWith<$Res>  {
$OrderStateCopyWith(OrderState _, $Res Function(OrderState) __);
}


/// Adds pattern-matching-related methods to [OrderState].
extension OrderStatePatterns on OrderState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Success():
return success(_that);case _Error():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<OrderItem> products,  int totalQuantity,  int totalPrice,  String paymentMethod,  int nominalBayar,  int idKasir,  String namaKasir,  String customerName)?  success,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.products,_that.totalQuantity,_that.totalPrice,_that.paymentMethod,_that.nominalBayar,_that.idKasir,_that.namaKasir,_that.customerName);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<OrderItem> products,  int totalQuantity,  int totalPrice,  String paymentMethod,  int nominalBayar,  int idKasir,  String namaKasir,  String customerName)  success,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Success():
return success(_that.products,_that.totalQuantity,_that.totalPrice,_that.paymentMethod,_that.nominalBayar,_that.idKasir,_that.namaKasir,_that.customerName);case _Error():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<OrderItem> products,  int totalQuantity,  int totalPrice,  String paymentMethod,  int nominalBayar,  int idKasir,  String namaKasir,  String customerName)?  success,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.products,_that.totalQuantity,_that.totalPrice,_that.paymentMethod,_that.nominalBayar,_that.idKasir,_that.namaKasir,_that.customerName);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements OrderState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderState.initial()';
}


}




/// @nodoc


class _Loading implements OrderState {
  const _Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'OrderState.loading()';
}


}




/// @nodoc


class _Success implements OrderState {
  const _Success( List<OrderItem> products, this.totalQuantity, this.totalPrice, this.paymentMethod, this.nominalBayar, this.idKasir, this.namaKasir, this.customerName): _products = products;
  

 final  List<OrderItem> _products;
 List<OrderItem> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

 final  int totalQuantity;
 final  int totalPrice;
 final  String paymentMethod;
 final  int nominalBayar;
 final  int idKasir;
 final  String namaKasir;
 final  String customerName;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&const DeepCollectionEquality().equals(other.products, _products)&&(identical(other.totalQuantity, totalQuantity) || other.totalQuantity == totalQuantity)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.nominalBayar, nominalBayar) || other.nominalBayar == nominalBayar)&&(identical(other.idKasir, idKasir) || other.idKasir == idKasir)&&(identical(other.namaKasir, namaKasir) || other.namaKasir == namaKasir)&&(identical(other.customerName, customerName) || other.customerName == customerName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_products),totalQuantity,totalPrice,paymentMethod,nominalBayar,idKasir,namaKasir,customerName);
}

@override
String toString() {
    return 'OrderState.success(products: $products, totalQuantity: $totalQuantity, totalPrice: $totalPrice, paymentMethod: $paymentMethod, nominalBayar: $nominalBayar, idKasir: $idKasir, namaKasir: $namaKasir, customerName: $customerName)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $OrderStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 List<OrderItem> products, int totalQuantity, int totalPrice, String paymentMethod, int nominalBayar, int idKasir, String namaKasir, String customerName
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? products = null,Object? totalQuantity = null,Object? totalPrice = null,Object? paymentMethod = null,Object? nominalBayar = null,Object? idKasir = null,Object? namaKasir = null,Object? customerName = null,}) {
  return _then(_Success(
null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,null == totalQuantity ? _self.totalQuantity : totalQuantity // ignore: cast_nullable_to_non_nullable
as int,null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,null == nominalBayar ? _self.nominalBayar : nominalBayar // ignore: cast_nullable_to_non_nullable
as int,null == idKasir ? _self.idKasir : idKasir // ignore: cast_nullable_to_non_nullable
as int,null == namaKasir ? _self.namaKasir : namaKasir // ignore: cast_nullable_to_non_nullable
as String,null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Error implements OrderState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode {
    return Object.hash(runtimeType,message);
}

@override
String toString() {
    return 'OrderState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $OrderStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of OrderState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
