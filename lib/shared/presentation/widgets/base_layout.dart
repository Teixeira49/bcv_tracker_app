import 'package:bcv_tracker_app/core/constants/constants.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/show_blurred_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../config/theme/colors/colors_values.dart';
import '../../../config/theme/icons/icons_constants.dart';
import '../../../features/settings/presentation/page/settings_modal.dart';

class BaseLayout extends StatelessWidget {
  final Widget? child;
  final String? title;
  final EdgeInsetsGeometry margins;

  const BaseLayout({super.key, this.child, required this.margins, this.title});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (child != null) _BaseBody(margins: margins, child: child!),
      Positioned(
        top: MediaQuery.of(context).size.height * 0.045,
        left: 16,
        right: 8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            SvgPicture.asset(
              AppIcons.onlyLogo,
              colorFilter: ColorFilter.mode(
                ColorValues.textWhite70(context),
                BlendMode.srcIn,
              ),
              height: 24,
            ),
            Text(
              title ?? Constants.appTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorValues.textWhite70(context),
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () => showBlurredDialog(
                context: context,
                builder: (context) => SettingsModal(),
              ),
              icon: Icon(
                Icons.settings,
                color: ColorValues.textWhite70(context),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _BaseBody extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margins;

  const _BaseBody({required this.child, required this.margins});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorValues.utilityMidNight(context),
          ColorValues.utilityBrand500(context),
        ],
      ),
    ),
    height: MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width,
    child: Column(
      children: [
        SizedBox.fromSize(size: MediaQuery.of(context).size * 0.10),
        Container(
          height: MediaQuery.of(context).size.height * 0.90,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: ColorValues.bgPrimary(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          padding: margins,
          child: child,
        ),
      ],
    ),
  );
}

/*
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
 */
