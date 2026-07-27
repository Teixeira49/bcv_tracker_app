part of '../page/settings_modal.dart';

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        _SettingsSectionTitle(title: AppMessages.defaultMarket),
        const _MarketSelector(),
        _SettingsSectionTitle(title: AppMessages.followedMarkets),
        const _FollowedMarketsSelector(),
        _SettingsSectionTitle(title: AppMessages.language),
        const _LanguageSelector(),
        _SettingsSectionTitle(title: AppMessages.theme),
        const _ThemeSelector(),
      ],
    );
  }
}
