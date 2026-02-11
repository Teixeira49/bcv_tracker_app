part of '../page/settings_modal.dart';

class _MarketDefaultButton extends StatelessWidget {
  const _MarketDefaultButton({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => Expanded(
    child: CustomBadgedButton(
      onTap: onTap,
      borderRadius: 8,
      color: isSelected
          ? ColorValues.utilityInfo(context)
          : ColorValues.utilityGrey500(context),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? ColorValues.textBrandTertiary(context)
              : ColorValues.utilityGrey500(context),
          fontSize: 16,
        ),
      ),
    ),
  );
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final bool isSelected;

  const _ThemeButton({
    required this.label,
    required this.onTap,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomBadgedButton(
        onTap: onTap,
        borderRadius: 16,
        color: isSelected
            ? ColorValues.utilityInfo(context)
            : ColorValues.fgSecondary(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? ColorValues.textBrandTertiary(context)
                    : ColorValues.utilityGrey500(context),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? ColorValues.textBrandTertiary(context)
                      : ColorValues.utilityGrey500(context),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
