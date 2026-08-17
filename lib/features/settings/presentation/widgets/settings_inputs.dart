part of '../page/settings_modal.dart';

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    // `Obx`, where the other two selectors already had one and this did not.
    // Under `GetBuilder` this dropdown only ever refreshed because
    // `Get.updateLocale` rebuilds the whole app — an accident, not a
    // subscription. Reading `favLanguageCode` inside `Obx` makes it depend on
    // the value it displays.
    return Obx(() {
      final LanguageOption selectedLanguage = controller.selectedLanguage;

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
    });
  }
}
