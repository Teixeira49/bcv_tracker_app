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

class _HomeAppBarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
    child: Text(
      "Precio del Dolar \u{1F1FB}\u{1F1EA}",
      style: TextStyle(color: Colors.white),
    ),
  );
}

class _TaxCurrencyItem extends StatelessWidget {
  const _TaxCurrencyItem({required this.currency, this.color});

  final Currency currency;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /*Image.network(
        currency.imgUrl ?? "",
        width: 50,
        height: 50
      ),*/
        Text(
          currency.keyName,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Text(currency.value, style: TextStyle(color: color)),
      ],
    ),
  );
}

class _BCVDollarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<DollarBCVController>(
    builder: (controller) => Skeletonizer(
      enabled: controller.isLoading.value,
      child: Card(
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.currentDollar.length,
            itemBuilder: (context, index) =>
                _TaxCurrencyItem(currency: controller.currentDollar[index]),
          ),
        ),
      ),
    ),
  );
}

class _CurrentDollarCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => GetBuilder<CurrentDollarController>(
    builder: (controller) => Skeletonizer(
      enabled: controller.isLoading.value,
      child: Card(
        color: Color(0xFF02466D),
        child: Padding(
          padding: EdgeInsetsGeometry.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: controller.currentDollar.length,
                itemBuilder: (context, index) => _TaxCurrencyItem(
                  currency: controller.currentDollar[index],
                  color: Colors.white,
                ),
              ),
              Divider(),
              Text(
                'Valor del Bs.S Actual',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
