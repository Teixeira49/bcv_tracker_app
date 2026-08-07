part of '../page/settings_modal.dart';

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) => GetBuilder<SettingsController>(
    builder: (SettingsController controller) {
      final selectedLanguage = controller.selectedLanguage;

      return DropdownButtonFormField<LanguageOption>(
        initialValue: selectedLanguage,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorValues.borderPrimary(context),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorValues.utilityBrandSecondary500(context),
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorValues.borderPrimary(context),
              width: 1.5,
            ),
          ),
        ),
        dropdownColor: ColorValues.bgPrimaryAlter(context),
        borderRadius: BorderRadius.circular(12),
        items: controller.languageOptions.map((LanguageOption language) {
          return DropdownMenuItem<LanguageOption>(
            value: language,
            child: Row(
              children: [
                Text(language.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(language.name),
              ],
            ),
          );
        }).toList(),
        onChanged: (LanguageOption? newValue) {
          if (newValue != null) controller.setFavLanguage(newValue.code);
        },
        selectedItemBuilder: (BuildContext context) {
          return controller.languageOptions.map<Widget>((
            LanguageOption language,
          ) {
            return Row(
              children: [
                Text(language.flag, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Text(language.name),
              ],
            );
          }).toList();
        },
      );
    },
  );
}
