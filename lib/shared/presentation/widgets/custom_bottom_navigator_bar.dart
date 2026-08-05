import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/theme/colors/colors_values.dart';
import '../../../navigation/navigation_controller.dart';

class CustomBottomNavigatorBar extends StatelessWidget {
  const CustomBottomNavigatorBar({
    super.key,
    required this.navigationController,
    required this.pageButtons,
  });

  final NavigationController navigationController;
  final List<Map<String, dynamic>> pageButtons;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: Obx(
          () => Container(
            height: 64,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ColorValues.textPrimaryInv(context).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorValues.utilityInfo(context).withAlpha(120),
                width: 1.25,
              ),
              boxShadow: [
                BoxShadow(
                  color: ColorValues.utilityInfo(context).withAlpha(150),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: pageButtons
                  .map(
                    (e) => Expanded(
                      child: _CustomBottomNavigatorItem(
                        onTap: () => navigationController.changeIndex(
                          pageButtons.indexOf(e),
                        ),
                        content: e,
                        isSelected:
                            pageButtons.indexOf(e) ==
                            navigationController.selectedIndex.value,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    ),
  );
}

class _CustomBottomNavigatorItem extends StatelessWidget {
  const _CustomBottomNavigatorItem({
    required this.content,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, dynamic> content;
  final bool isSelected;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onTap(),
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBar(isActive: isSelected),
          Opacity(
            opacity: isSelected ? 1 : 0.85,
            child: Icon(
              isSelected
                  ? (content['active_icon'] as IconData? ??
                        content['icon'] as IconData?)
                  : content['icon'] as IconData?,
              size: 24,
              color: isSelected
                  ? ColorValues.fgBrandSecondary(context)
                  : ColorValues.utilityGrey500(context),
            ),
          ),
        ],
      ),
    ),
  );
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    margin: const EdgeInsets.only(bottom: 4),
    duration: const Duration(milliseconds: 200),
    height: 4,
    width: isActive ? 24 : 0,
    decoration: BoxDecoration(
      color: ColorValues.fgBrandSecondary(context),
      borderRadius: BorderRadius.circular(16),
    ),
  );
}
