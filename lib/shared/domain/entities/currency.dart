class Currency {
  final String name;
  final String keyName;
  final String value;
  final String? imgUrl;

  const Currency({
    required this.name,
    required this.keyName,
    required this.value,
    this.imgUrl,
  });

  static const empty = Currency(name: '', keyName: '', value: '');

  static const emptySkeletonizer = Currency(
    name: 'name',
    keyName: 'keyName',
    value: 'value',
  );
}
