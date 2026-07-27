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

/// Chip that follows or drops a market. Sized to its label, unlike
/// [_MarketDefaultButton], because the catalogue holds nine of them.
class _MarketToggleButton extends StatelessWidget {
  const _MarketToggleButton({
    required this.label,
    required this.onTap,
    required this.isSelected,
  });

  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) => CustomBadgedButton(
    onTap: onTap,
    borderRadius: 8,
    color: isSelected
        ? ColorValues.utilityInfo(context)
        : ColorValues.utilityGrey500(context),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.add_circle_outline,
            size: 16,
            color: isSelected
                ? ColorValues.textBrandTertiary(context)
                : ColorValues.utilityGrey500(context),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? ColorValues.textBrandTertiary(context)
                  : ColorValues.utilityGrey500(context),
              fontSize: 15,
            ),
          ),
        ],
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
