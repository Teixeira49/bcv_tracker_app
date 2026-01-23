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
          colors: [
            ColorValues.utilityMidNight(context),
            ColorValues.utilityBrand500(context),
          ],
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
