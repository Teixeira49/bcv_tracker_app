part of '../page/home_page.dart';

class _RoundedHomeAppBarClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.75);
    final controlPoint = Offset(size.width * 0.4, size.height);
    final endPoint = Offset(size.width, size.height / 1.75);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_RoundedHomeAppBarClipPath oldClipper) =>
      oldClipper != this;
}

class _RoundedHomeAppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _RoundedHomeAppBarClipPath(),
    child: Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff070e15), Color(0xFF02466D)],
        ),
      ),
    ),
  );
}

class _DollarCurrencyCard extends StatelessWidget {
  // GetBuilder<CurrentDollarController>( add later

  @override
  Widget build(BuildContext context) => Skeletonizer(
    enabled: false,
    child: Card(
      color: Color(0xFFEFF5FF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(
                'https://exchangemonitor.net/assets/img/rates/ve/bcv.png',
              ),
            ),
            title: Text(
              'Dolar Oficial',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Banco Central de Venezuela',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: CustomBadged(
              color: Color(0xFF39E079),
              child: PerformanceIndicatorWidget(isPositive: true, value: 0.24),
            ),
          ),
          ListTile(
            title: Text('Valor de la divisa', style: TextStyle(fontSize: 14)),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyHelpers.castCurrency(value: 344.49),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
                Text(
                  CurrencyHelpers.completeCurrencyExchange('USD'),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          Divider(indent: 16, endIndent: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Ultima Actualizacion'), Text('Ayer')],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    ),
  );
}

class _BCVDollarCard extends StatelessWidget {
  const _BCVDollarCard({required this.value, required this.currencyCode});

  final double value;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final currencyCountry = CurrencyHelpers.castCurrencyCountry(
      currencyCode: currencyCode,
    );
    return Skeletonizer(
      enabled: false,
      child: Card(
        color: Color(0xFFEFF5FF),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(currencyCountry.countryFlag),
                ),
                title: Text(
                  currencyCountry.currencyCountryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: SvgPicture.asset(currencyCountry.currencySymbol, width: 20),
              ),
              Divider(indent: 16, endIndent: 16),
              ListTile(
                title: Text(
                  'Valor de la moneda',
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyHelpers.castCurrency(value: value),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      CurrencyHelpers.completeCurrencyExchange(currencyCode),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BCVAdvisorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomBadged(
    borderRadius: 12,
    color: Color(0xFF1187CE),
    hMargin: 3,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text('Fecha: 18/01/2026 - 2:00 pm'),
    ),
  );
}

class _CurrencyDollarAverageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => CustomBadged(
    borderRadius: 12,
    color: Color(0xFF1187CE),
    hMargin: 3,
    child: Padding(
      padding: EdgeInsets.only(right: 4, top: 8, left: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Valor Promedio', style: TextStyle(color: Color(0xFF064469))),
              Text(
                'Bs.S 344,49',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xFF064469),
                ),
              ),
            ],
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.settings))
        ],
      )
    ),
  );
}
