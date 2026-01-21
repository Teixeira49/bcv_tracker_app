part of '../page/splash_page.dart';

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    final sizeLogo = MediaQuery.of(context).size.width * 0.8;

    return Container(
      alignment: AlignmentGeometry.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff070e15), Color(0xFF02466D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SvgPicture.asset(
        AppIcons.mainLogo,
        fit: BoxFit.cover,
        width: sizeLogo,
        height: sizeLogo,
      ),
    );
  }
}
