import 'package:freezed_annotation/freezed_annotation.dart';

part 'tender.freezed.dart';
part 'tender.g.dart';

@freezed
class Tender with _$Tender {
  const factory Tender({
    required String id,
    @JsonKey(name: 'title_en') required String titleEn,
    @JsonKey(name: 'title_am') required String titleAm,
    required String category,
    @JsonKey(name: 'organization_en') required String organizationEn,
    @JsonKey(name: 'organization_am') required String organizationAm,
    required DateTime deadline,
    @JsonKey(name: 'posted_date') required DateTime postedDate,
    @JsonKey(name: 'cpo_amount') double? cpoAmount,
    required String status,
    @JsonKey(name: 'min_grade') String? minGrade,
    @JsonKey(name: 'location_en') required String locationEn,
    @JsonKey(name: 'location_am') required String locationAm,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
  }) = _Tender;

  factory Tender.fromJson(Map<String, dynamic> json) => _$TenderFromJson(json);
}

extension TenderX on Tender {
  String getTitle(String langCode) => langCode == 'am' ? titleAm : titleEn;
  String getOrganization(String langCode) => langCode == 'am' ? organizationAm : organizationEn;
  String getLocation(String langCode) => langCode == 'am' ? locationAm : locationEn;
}
