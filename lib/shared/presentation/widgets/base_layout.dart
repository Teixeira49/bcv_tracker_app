import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget? child;
  final Widget? appBar;
  final EdgeInsetsGeometry margins;

  const BaseLayout({super.key, this.child, required this.margins, this.appBar});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      if (appBar != null) appBar!,
      if (child != null)
        SizedBox.fromSize(
          size: MediaQuery.of(context).size,
          child: Padding(padding: margins, child: child),
        ),
    ],
  );
}
