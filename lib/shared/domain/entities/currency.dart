class Currency {
  final int id;
  final String name;
  final String keyName;
  final String platform;
  final double value;
  final String? imgUrl;
  final DateTime? createDate;
  final DateTime? updateDate;
  final double? tendency;

  const Currency({
    required this.id,
    required this.name,
    required this.keyName,
    required this.platform,
    required this.value,
    this.imgUrl,
    this.createDate,
    this.updateDate,
    this.tendency,
  });

  Currency copyWith({
    String? name,
    String? keyName,
    String? platform,
    double? value,
    String? imgUrl,
    DateTime? updateDate,
    double? tendency,
  }) {
    return Currency(
      id: id,
      name: name ?? this.name,
      keyName: keyName ?? this.keyName,
      platform: platform ?? this.platform,
      value: value ?? this.value,
      imgUrl: imgUrl ?? this.imgUrl,
      updateDate: updateDate ?? this.updateDate,
      tendency: tendency ?? this.tendency,
    );
  }

  static const empty = Currency(
    id: 0,
    name: '',
    platform: '',
    keyName: '',
    value: 0.00,
    imgUrl: '',
    tendency: 0.00,
  );

  static final emptySkeletonizer = Currency(
    name: 'name',
    keyName: 'keyName',
    platform: 'platform',
    value: 1.0,
    imgUrl: 'imgUrl',
    createDate: DateTime.now(),
    updateDate: DateTime.now(),
    tendency: 1.0,
    id: 0,
  );

  static final pivotCurrency = Currency(
    keyName: 'VES',
    name: 'Banco Central de Venezuela',
    value: 1.0,
    platform: 'Banco Central de Venezuela',
    id: -1,
  );
}
