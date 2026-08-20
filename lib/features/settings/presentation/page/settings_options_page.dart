import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../shared/presentation/widgets/base_layout.dart';
import '../widgets/settings_option_tile.dart';

/// How a [SettingsOptionsPage] arranges its choices.
///
/// The decision is about the options, not the screen: see `DESIGN.md` →
/// *settingsChoiceCard* for when each one applies.
enum SettingsOptionsLayout {
  /// One choice per row, in a single card. The default, and what a set that is
  /// **read** wants — the ten languages.
  list,

  /// Two choices per row, each its own card with its icon above its label. For
  /// a short set where the icon identifies the option faster than the word.
  grid,
}

/// The screen where a single-choice setting is picked from a list.
///
/// One widget for the three sub-screens
/// [#37](https://github.com/Teixeira49/bcv_tracker_app/issues/37) asks for,
/// because they differ only in their list: language (ten rows), market (two)
/// and theme (three). Written generically so the next single-choice setting is
/// a `GetPage` and a list, not another screen.
///
/// **It does not close on selection, deliberately.** Language and theme repaint
/// the entire app the instant they are applied, and that repaint *is* the
/// confirmation — popping on top of it stacks a route transition over a full
/// rebuild and hides the very feedback the tap produced. The user goes back
/// when they are done, which is also what lets them compare two themes without
/// entering the screen twice.
///
/// It renders whatever [selected] says and reports taps through [onSelected];
/// the reactivity belongs to the caller, which wraps this in an `Obx` over
/// `SettingsController` (see `getx-architecture`: the service holds the `Rx`,
/// the view never names it).
class SettingsOptionsPage<T> extends StatelessWidget {
  const SettingsOptionsPage({
    super.key,
    required this.title,
    required this.intro,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.layout = SettingsOptionsLayout.list,
  });

  /// Screen heading, shown in the branded strip. From `AppMessages`.
  final String title;

  /// One sentence above the options, saying what choosing one will do.
  ///
  /// **Required, not optional.** A choice screen that cannot say what its
  /// setting is for is a list of words the user has to infer from — and the
  /// screens still queued behind this one (notifications #13, accessibility
  /// #33, analytics consent #34) are exactly the ones where guessing is worst.
  /// Making it part of the constructor means the next screen cannot ship
  /// without an answer.
  final String intro;

  /// The choices, in display order.
  final List<SettingsOption<T>> options;

  /// The value currently stored. Exactly one row is expected to match it; if
  /// none does, no row is ticked — the honest rendering of a stored value this
  /// build no longer offers.
  final T selected;

  /// Applies the choice. The setter that persists it lives on
  /// `SettingsController`; this page only reports the tap.
  final ValueChanged<T> onSelected;

  /// How the choices are arranged. See [SettingsOptionsLayout].
  final SettingsOptionsLayout layout;

  /// Columns of the grid layout.
  ///
  /// Two, and fixed rather than derived from the available width: this is a
  /// phone-first app and a third column would put the cards below the size at
  /// which an icon and a wrapped German label still read.
  static const int _gridColumns = 2;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: ColorValues.bgPrimary(context),
    body: BaseLayout(
      title: title,
      showBackButton: true,
      showSettingsAction: false,
      margins: EdgeInsets.fromLTRB(
        WidthValues.spacingMd,
        WidthValues.spacingLg,
        WidthValues.spacingMd,
        WidthValues.spacingNone,
      ),
      child: ListView(
        // Room under the last row: the panel ends at the screen edge and a list
        // that stops flush against it reads as cut off.
        padding: EdgeInsets.only(bottom: WidthValues.spacing4xl),
        children: <Widget>[
          // Inside the scroll view rather than pinned above it: on a short
          // screen at a large font scale the sentence should be able to leave
          // to make room for the options, which is the reason the user came.
          Padding(
            padding: EdgeInsets.only(
              left: WidthValues.spacingXs,
              right: WidthValues.spacingXs,
              bottom: WidthValues.spacingMd,
            ),
            child: Text(
              intro,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: ColorValues.textTertiary(context),
              ),
            ),
          ),
          ...switch (layout) {
            SettingsOptionsLayout.list => <Widget>[_buildList(context)],
            SettingsOptionsLayout.grid => _buildGrid(context),
          },
        ],
      ),
    ),
  );

  /// Every choice as a row of one card, separated by dividers.
  Widget _buildList(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: ColorValues.utilityBrand50(context),
    child: Column(
      children: <Widget>[
        for (int i = 0; i < options.length; i++) ...<Widget>[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              indent: WidthValues.spacingMd,
              endIndent: WidthValues.spacingMd,
              color: ColorValues.borderPrimary(context),
            ),
          SettingsOptionTile<T>(
            option: options[i],
            isSelected: options[i].value == selected,
            onTap: () => onSelected(options[i].value),
          ),
        ],
      ],
    ),
  );

  /// The choices as cards, [_gridColumns] per row.
  ///
  /// Hand-chunked into `Row`s rather than built with a `GridView`: the page is
  /// already a `ListView`, and a grid inside it would be a second scroll view
  /// needing `shrinkWrap` — the arrangement here is a handful of rows, and rows
  /// are what it actually is.
  ///
  /// **An odd count leaves the last cell empty on purpose.** The alternative,
  /// stretching the lone card across the row, makes it a different size from
  /// its siblings and the set stops reading as a grid — which matters with
  /// exactly three themes, where the odd one out is the permanent state.
  List<Widget> _buildGrid(BuildContext context) {
    final List<Widget> rows = <Widget>[];

    for (int start = 0; start < options.length; start += _gridColumns) {
      final int end = (start + _gridColumns).clamp(0, options.length);

      rows.add(
        Padding(
          padding: EdgeInsets.only(top: start == 0 ? 0 : WidthValues.spacingMd),
          // `IntrinsicHeight` so both cards in a row match the taller of the
          // two. Without it a label that wraps in German leaves its neighbour
          // visibly short, and the pair stops looking like one row.
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: WidthValues.spacingMd,
              children: <Widget>[
                for (int i = start; i < end; i++)
                  Expanded(
                    child: SettingsOptionCard<T>(
                      option: options[i],
                      isSelected: options[i].value == selected,
                      onTap: () => onSelected(options[i].value),
                    ),
                  ),
                // Holds the cell width of the short last row.
                for (int i = end; i < start + _gridColumns; i++)
                  const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      );
    }

    return rows;
  }
}
