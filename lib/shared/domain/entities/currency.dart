class Currency {
  final String name;
  final String keyName;
  final String platform;
  final double value;
  final String? imgUrl;
  final DateTime? createDate;
  final DateTime? updateDate;
  final double? tendency;

  const Currency({
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
    DateTime? createDate,
    DateTime? updateDate,
    double? tendency,
  }) {
    return Currency(
      name: name ?? this.name,
      keyName: keyName ?? this.keyName,
      platform: platform ?? this.platform,
      value: value ?? this.value,
      imgUrl: imgUrl ?? this.imgUrl,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      tendency: tendency ?? this.tendency,
    );
  }

  static const empty = Currency(
    name: '',
    platform: '',
    keyName: '',
    value: 0.00,
    imgUrl: 'https://placehold.co/600x400/png',
    tendency: 0.00,
  );

  static final emptySkeletonizer = Currency(
    name: 'name',
    keyName: 'keyName',
    platform: 'platform',
    value: 1.0,
    imgUrl: 'https://placehold.co/600x400/png',
    createDate: DateTime.now(),
    updateDate: DateTime.now(),
    tendency: 1.0,
  );

  static final pivotCurrency = Currency(
    keyName: 'VES',
    name: 'Bolivares',
    value: 1.0,
    platform: 'Banco Central de Venezuela',
  );
}
