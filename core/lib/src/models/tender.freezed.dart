// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tender.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Tender _$TenderFromJson(Map<String, dynamic> json) {
  return _Tender.fromJson(json);
}

/// @nodoc
mixin _$Tender {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'title_en')
  String get titleEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'title_am')
  String get titleAm => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_en')
  String get organizationEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'organization_am')
  String get organizationAm => throw _privateConstructorUsedError;
  DateTime get deadline => throw _privateConstructorUsedError;
  @JsonKey(name: 'posted_date')
  DateTime get postedDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'cpo_amount')
  double? get cpoAmount => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_grade')
  String? get minGrade => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_en')
  String get locationEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'location_am')
  String get locationAm => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;

  /// Serializes this Tender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TenderCopyWith<Tender> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TenderCopyWith<$Res> {
  factory $TenderCopyWith(Tender value, $Res Function(Tender) then) =
      _$TenderCopyWithImpl<$Res, Tender>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'title_en') String titleEn,
    @JsonKey(name: 'title_am') String titleAm,
    String category,
    @JsonKey(name: 'organization_en') String organizationEn,
    @JsonKey(name: 'organization_am') String organizationAm,
    DateTime deadline,
    @JsonKey(name: 'posted_date') DateTime postedDate,
    @JsonKey(name: 'cpo_amount') double? cpoAmount,
    String status,
    @JsonKey(name: 'min_grade') String? minGrade,
    @JsonKey(name: 'location_en') String locationEn,
    @JsonKey(name: 'location_am') String locationAm,
    @JsonKey(name: 'is_featured') bool isFeatured,
  });
}

/// @nodoc
class _$TenderCopyWithImpl<$Res, $Val extends Tender>
    implements $TenderCopyWith<$Res> {
  _$TenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titleEn = null,
    Object? titleAm = null,
    Object? category = null,
    Object? organizationEn = null,
    Object? organizationAm = null,
    Object? deadline = null,
    Object? postedDate = null,
    Object? cpoAmount = freezed,
    Object? status = null,
    Object? minGrade = freezed,
    Object? locationEn = null,
    Object? locationAm = null,
    Object? isFeatured = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            titleEn: null == titleEn
                ? _value.titleEn
                : titleEn // ignore: cast_nullable_to_non_nullable
                      as String,
            titleAm: null == titleAm
                ? _value.titleAm
                : titleAm // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationEn: null == organizationEn
                ? _value.organizationEn
                : organizationEn // ignore: cast_nullable_to_non_nullable
                      as String,
            organizationAm: null == organizationAm
                ? _value.organizationAm
                : organizationAm // ignore: cast_nullable_to_non_nullable
                      as String,
            deadline: null == deadline
                ? _value.deadline
                : deadline // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            postedDate: null == postedDate
                ? _value.postedDate
                : postedDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            cpoAmount: freezed == cpoAmount
                ? _value.cpoAmount
                : cpoAmount // ignore: cast_nullable_to_non_nullable
                      as double?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            minGrade: freezed == minGrade
                ? _value.minGrade
                : minGrade // ignore: cast_nullable_to_non_nullable
                      as String?,
            locationEn: null == locationEn
                ? _value.locationEn
                : locationEn // ignore: cast_nullable_to_non_nullable
                      as String,
            locationAm: null == locationAm
                ? _value.locationAm
                : locationAm // ignore: cast_nullable_to_non_nullable
                      as String,
            isFeatured: null == isFeatured
                ? _value.isFeatured
                : isFeatured // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TenderImplCopyWith<$Res> implements $TenderCopyWith<$Res> {
  factory _$$TenderImplCopyWith(
    _$TenderImpl value,
    $Res Function(_$TenderImpl) then,
  ) = __$$TenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'title_en') String titleEn,
    @JsonKey(name: 'title_am') String titleAm,
    String category,
    @JsonKey(name: 'organization_en') String organizationEn,
    @JsonKey(name: 'organization_am') String organizationAm,
    DateTime deadline,
    @JsonKey(name: 'posted_date') DateTime postedDate,
    @JsonKey(name: 'cpo_amount') double? cpoAmount,
    String status,
    @JsonKey(name: 'min_grade') String? minGrade,
    @JsonKey(name: 'location_en') String locationEn,
    @JsonKey(name: 'location_am') String locationAm,
    @JsonKey(name: 'is_featured') bool isFeatured,
  });
}

/// @nodoc
class __$$TenderImplCopyWithImpl<$Res>
    extends _$TenderCopyWithImpl<$Res, _$TenderImpl>
    implements _$$TenderImplCopyWith<$Res> {
  __$$TenderImplCopyWithImpl(
    _$TenderImpl _value,
    $Res Function(_$TenderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Tender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? titleEn = null,
    Object? titleAm = null,
    Object? category = null,
    Object? organizationEn = null,
    Object? organizationAm = null,
    Object? deadline = null,
    Object? postedDate = null,
    Object? cpoAmount = freezed,
    Object? status = null,
    Object? minGrade = freezed,
    Object? locationEn = null,
    Object? locationAm = null,
    Object? isFeatured = null,
  }) {
    return _then(
      _$TenderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        titleEn: null == titleEn
            ? _value.titleEn
            : titleEn // ignore: cast_nullable_to_non_nullable
                  as String,
        titleAm: null == titleAm
            ? _value.titleAm
            : titleAm // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationEn: null == organizationEn
            ? _value.organizationEn
            : organizationEn // ignore: cast_nullable_to_non_nullable
                  as String,
        organizationAm: null == organizationAm
            ? _value.organizationAm
            : organizationAm // ignore: cast_nullable_to_non_nullable
                  as String,
        deadline: null == deadline
            ? _value.deadline
            : deadline // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        postedDate: null == postedDate
            ? _value.postedDate
            : postedDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        cpoAmount: freezed == cpoAmount
            ? _value.cpoAmount
            : cpoAmount // ignore: cast_nullable_to_non_nullable
                  as double?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        minGrade: freezed == minGrade
            ? _value.minGrade
            : minGrade // ignore: cast_nullable_to_non_nullable
                  as String?,
        locationEn: null == locationEn
            ? _value.locationEn
            : locationEn // ignore: cast_nullable_to_non_nullable
                  as String,
        locationAm: null == locationAm
            ? _value.locationAm
            : locationAm // ignore: cast_nullable_to_non_nullable
                  as String,
        isFeatured: null == isFeatured
            ? _value.isFeatured
            : isFeatured // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TenderImpl implements _Tender {
  const _$TenderImpl({
    required this.id,
    @JsonKey(name: 'title_en') required this.titleEn,
    @JsonKey(name: 'title_am') required this.titleAm,
    required this.category,
    @JsonKey(name: 'organization_en') required this.organizationEn,
    @JsonKey(name: 'organization_am') required this.organizationAm,
    required this.deadline,
    @JsonKey(name: 'posted_date') required this.postedDate,
    @JsonKey(name: 'cpo_amount') this.cpoAmount,
    required this.status,
    @JsonKey(name: 'min_grade') this.minGrade,
    @JsonKey(name: 'location_en') required this.locationEn,
    @JsonKey(name: 'location_am') required this.locationAm,
    @JsonKey(name: 'is_featured') this.isFeatured = false,
  });

  factory _$TenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$TenderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'title_en')
  final String titleEn;
  @override
  @JsonKey(name: 'title_am')
  final String titleAm;
  @override
  final String category;
  @override
  @JsonKey(name: 'organization_en')
  final String organizationEn;
  @override
  @JsonKey(name: 'organization_am')
  final String organizationAm;
  @override
  final DateTime deadline;
  @override
  @JsonKey(name: 'posted_date')
  final DateTime postedDate;
  @override
  @JsonKey(name: 'cpo_amount')
  final double? cpoAmount;
  @override
  final String status;
  @override
  @JsonKey(name: 'min_grade')
  final String? minGrade;
  @override
  @JsonKey(name: 'location_en')
  final String locationEn;
  @override
  @JsonKey(name: 'location_am')
  final String locationAm;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  @override
  String toString() {
    return 'Tender(id: $id, titleEn: $titleEn, titleAm: $titleAm, category: $category, organizationEn: $organizationEn, organizationAm: $organizationAm, deadline: $deadline, postedDate: $postedDate, cpoAmount: $cpoAmount, status: $status, minGrade: $minGrade, locationEn: $locationEn, locationAm: $locationAm, isFeatured: $isFeatured)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.titleEn, titleEn) || other.titleEn == titleEn) &&
            (identical(other.titleAm, titleAm) || other.titleAm == titleAm) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.organizationEn, organizationEn) ||
                other.organizationEn == organizationEn) &&
            (identical(other.organizationAm, organizationAm) ||
                other.organizationAm == organizationAm) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.postedDate, postedDate) ||
                other.postedDate == postedDate) &&
            (identical(other.cpoAmount, cpoAmount) ||
                other.cpoAmount == cpoAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.minGrade, minGrade) ||
                other.minGrade == minGrade) &&
            (identical(other.locationEn, locationEn) ||
                other.locationEn == locationEn) &&
            (identical(other.locationAm, locationAm) ||
                other.locationAm == locationAm) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    titleEn,
    titleAm,
    category,
    organizationEn,
    organizationAm,
    deadline,
    postedDate,
    cpoAmount,
    status,
    minGrade,
    locationEn,
    locationAm,
    isFeatured,
  );

  /// Create a copy of Tender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TenderImplCopyWith<_$TenderImpl> get copyWith =>
      __$$TenderImplCopyWithImpl<_$TenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TenderImplToJson(this);
  }
}

abstract class _Tender implements Tender {
  const factory _Tender({
    required final String id,
    @JsonKey(name: 'title_en') required final String titleEn,
    @JsonKey(name: 'title_am') required final String titleAm,
    required final String category,
    @JsonKey(name: 'organization_en') required final String organizationEn,
    @JsonKey(name: 'organization_am') required final String organizationAm,
    required final DateTime deadline,
    @JsonKey(name: 'posted_date') required final DateTime postedDate,
    @JsonKey(name: 'cpo_amount') final double? cpoAmount,
    required final String status,
    @JsonKey(name: 'min_grade') final String? minGrade,
    @JsonKey(name: 'location_en') required final String locationEn,
    @JsonKey(name: 'location_am') required final String locationAm,
    @JsonKey(name: 'is_featured') final bool isFeatured,
  }) = _$TenderImpl;

  factory _Tender.fromJson(Map<String, dynamic> json) = _$TenderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'title_en')
  String get titleEn;
  @override
  @JsonKey(name: 'title_am')
  String get titleAm;
  @override
  String get category;
  @override
  @JsonKey(name: 'organization_en')
  String get organizationEn;
  @override
  @JsonKey(name: 'organization_am')
  String get organizationAm;
  @override
  DateTime get deadline;
  @override
  @JsonKey(name: 'posted_date')
  DateTime get postedDate;
  @override
  @JsonKey(name: 'cpo_amount')
  double? get cpoAmount;
  @override
  String get status;
  @override
  @JsonKey(name: 'min_grade')
  String? get minGrade;
  @override
  @JsonKey(name: 'location_en')
  String get locationEn;
  @override
  @JsonKey(name: 'location_am')
  String get locationAm;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;

  /// Create a copy of Tender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TenderImplCopyWith<_$TenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
