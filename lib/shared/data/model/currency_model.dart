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

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      name: json['name'],
      keyName: json['code'],
      platform: json['platform'],
      value: json['value'].toDouble(),
      imgUrl: json['platform_img'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: DateTime.parse(json['updateDate']),
      tendency: json['change'],
    );
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
