import 'package:flutter/material.dart';

class BaseModal extends StatelessWidget {
  const BaseModal({
    super.key,
    required this.title,
    this.externalMargin = const EdgeInsets.all(0),
    this.internalMargin = const EdgeInsets.only(right: 20, left: 20, top: 6, bottom: 16),
    required this.child,
  });

  final String title;
  final EdgeInsets externalMargin;
  final EdgeInsets internalMargin;
  final Widget child;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close),
        ),
      ],
    ),
    contentPadding: externalMargin,
    backgroundColor: Colors.white,
    elevation: 16,
    shadowColor: Color(0xFF02466D),
    content: SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(),
          Padding(padding: internalMargin, child: child),
        ],
      ),
    ),
  );
}
