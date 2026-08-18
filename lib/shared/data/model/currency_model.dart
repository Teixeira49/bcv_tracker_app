import 'package:bcv_tracker_app/core/helpers/backend_date.dart';
import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';

/// Wire format of one rate, and the seam back to [Currency].
///
/// Where the backend's shape is dealt with and then left behind: optional fields
/// read with a fallback, `platform_img` empty strings turned into `null`, `num`
/// widened to `double`, and dates normalised **once**. Nothing above the data layer
/// should ever normalise something that came off the network.
///
/// It **extends the entity**, so a `CurrencyModel` satisfies every signature that
/// asks for a `Currency` and the compiler cannot tell you when one leaks upward.
/// `.toEntity()` is therefore mandatory even though returning `this` would compile
/// — see `.agents/rules/entities-vs-models.md`, and the four places a new field has
/// to touch.
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
      // Normalized to the device zone here, at the boundary, so the rest of the
      // app never handles a backend timestamp again (see [BackendDate]).
      createDate: BackendDate.toLocal(json['createDate']),
      updateDate: BackendDate.toLocal(json['updateDate']),
      tendency: (json['change'] as num?)?.toDouble(),
    );
  }

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
