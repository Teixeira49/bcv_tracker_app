import 'package:bcv_tracker_app/shared/domain/entities/entities.dart';

class CurrencyModel extends Currency {
  CurrencyModel({
    required super.name,
    required super.keyName,
    required super.value,
    super.imgUrl,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      name: json['name'],
      keyName: json['keyName'],
      value: json['value'],
      imgUrl: json['imgUrl'],
    );
  }

  Currency toEntity() {
    return Currency(
      name: name,
      keyName: keyName,
      value: value,
      imgUrl: imgUrl,
    );
  }
}
