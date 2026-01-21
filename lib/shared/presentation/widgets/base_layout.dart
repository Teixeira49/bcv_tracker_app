import 'package:bcv_tracker_app/shared/presentation/widgets/show_blurred_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
              'assets/logo_center.svg',
              colorFilter: ColorFilter.mode(Colors.white70, BlendMode.srcIn),
              height: 24,
            ),
            Text(
              title ?? 'BCV Tracker',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () => showBlurredDialog(
                context: context,
                builder: (context) => SettingsModal(),
              ),
              icon: Icon(Icons.settings, color: Colors.white70),
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
      gradient: LinearGradient(colors: [Color(0xff070e15), Color(0xFF02466D)]),
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
            color: Colors.white,
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
