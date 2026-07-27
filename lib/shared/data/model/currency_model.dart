import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';

class CurrencyModel extends Currency {
  CurrencyModel({
    required super.name,
    required super.keyName,
    required super.platform,
    required super.value,
    super.imgUrl,
    super.createDate,
    super.updateDate,
    super.tendency,
  });

  /// Maps a `CurrencySchema` of the backend.
  ///
  /// `createDate`, `updateDate`, `change` and `platform_img` are optional in the
  /// contract, so none of them can be dereferenced directly.
  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      name: json['name'] as String? ?? '',
      keyName: json['code'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      imgUrl: _parseImgUrl(json['platform_img']),
      createDate: _parseDate(json['createDate']),
      updateDate: _parseDate(json['updateDate']),
      tendency: (json['change'] as num?)?.toDouble(),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// The backend sends an empty string for platforms with no logo mapped
  /// (`PLATFORM_IMAGES.get(platform, "")`); the UI expects `null` there to fall
  /// back to the currency initials instead of requesting an empty URL.
  static String? _parseImgUrl(Object? value) {
    if (value is! String) return null;
    final url = value.trim();
    return url.isEmpty ? null : url;
  }

  Currency toEntity() {
    return Currency(
      name: name,
      keyName: keyName,
      platform: platform,
      value: value,
      imgUrl: imgUrl,
      createDate: createDate,
      updateDate: updateDate,
      tendency: tendency,
    );
  }
}
