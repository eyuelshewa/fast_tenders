// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TenderImpl _$$TenderImplFromJson(Map<String, dynamic> json) => _$TenderImpl(
  id: json['id'] as String,
  titleEn: json['title_en'] as String,
  titleAm: json['title_am'] as String,
  category: json['category'] as String,
  organizationEn: json['organization_en'] as String,
  organizationAm: json['organization_am'] as String,
  deadline: DateTime.parse(json['deadline'] as String),
  postedDate: DateTime.parse(json['posted_date'] as String),
  cpoAmount: (json['cpo_amount'] as num?)?.toDouble(),
  status: json['status'] as String,
  minGrade: json['min_grade'] as String?,
  locationEn: json['location_en'] as String,
  locationAm: json['location_am'] as String,
  isFeatured: json['is_featured'] as bool? ?? false,
);

Map<String, dynamic> _$$TenderImplToJson(_$TenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title_en': instance.titleEn,
      'title_am': instance.titleAm,
      'category': instance.category,
      'organization_en': instance.organizationEn,
      'organization_am': instance.organizationAm,
      'deadline': instance.deadline.toIso8601String(),
      'posted_date': instance.postedDate.toIso8601String(),
      'cpo_amount': instance.cpoAmount,
      'status': instance.status,
      'min_grade': instance.minGrade,
      'location_en': instance.locationEn,
      'location_am': instance.locationAm,
      'is_featured': instance.isFeatured,
    };
