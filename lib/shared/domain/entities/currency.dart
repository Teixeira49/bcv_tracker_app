class Currency {
  final String name;
  final String keyName;
  final String value;
  final String? imgUrl;
  final DateTime? date;
  final double? tendency;

  const Currency({
    required this.name,
    required this.keyName,
    required this.value,
    this.imgUrl,
    this.date,
    this.tendency,
  });

  Currency copyWith({
    String? name,
    String? keyName,
    String? value,
    String? imgUrl,
    DateTime? date,
    double? tendency,
  }) {
    return Currency(
      name: name ?? this.name,
      keyName: keyName ?? this.keyName,
      value: value ?? this.value,
      imgUrl: imgUrl ?? this.imgUrl,
      date: date ?? this.date,
      tendency: tendency ?? this.tendency,
    );
  }

  static const empty = Currency(name: '', keyName: '', value: '');

  static const emptySkeletonizer = Currency(
    name: 'name',
    keyName: 'keyName',
    value: '1.000',
  );
}
