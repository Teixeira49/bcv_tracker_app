import 'package:flutter/material.dart';

import '../../../../config/theme/colors/colors_values.dart';
import '../../../../config/theme/width/width_values.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/constants/market_constants.dart';
import '../../../../core/i18n/app_messages.dart';

/// The app's own identity block, at the top of the About screen.
///
/// Logo, name and one sentence saying what it does. It carries **no section
/// title**, unlike the three blocks below it: a heading over the app's own name
/// would be labelling the obvious, and the screen reads better opening with the
/// thing itself.
class AboutHeader extends StatelessWidget {
  const AboutHeader({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: WidthValues.spacingLg),
    child: Column(
      children: <Widget>[
        Image.asset(
          Constants.appLogoAsset,
          height: 72,
          // Tinted per mode, and it has to be: the artwork is monochrome white,
          // which is right on the branded strip and invisible here — this is
          // the first screen that puts the mark on a **light** surface, so it
          // was white on white. `srcIn` keeps the silhouette and replaces the
          // ink, the same thing the splash does with its `colorFilter`.
          color: ColorValues.fgBrandMark(context),
          colorBlendMode: BlendMode.srcIn,
          // Decorative: the name is right underneath, so announcing the logo
          // to a screen reader would read the app's identity out twice.
          excludeFromSemantics: true,
        ),
        SizedBox(height: WidthValues.spacingSm),
        Text(
          Constants.appTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: ColorValues.textPrimary(context),
          ),
        ),
        SizedBox(height: WidthValues.spacingXxs),
        Text(
          AppMessages.appTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: ColorValues.textTertiary(context),
          ),
        ),
      ],
    ),
  );
}

/// A row that leaves the app.
///
/// Used for every link on the About screen — the nine data sources, the two
/// repositories, the API docs, the licence and the author. The trailing
/// open-in-new icon is the part that earns its keep: it is the only thing
/// distinguishing these rows from the settings rows above them, which drill
/// **down** into the app and carry a chevron.
class AboutLinkTile extends StatelessWidget {
  const AboutLinkTile({
    super.key,
    required this.title,
    required this.onTap,
    this.trailing,
    this.isBrandName = false,
  });

  /// The row's label. From `AppMessages` — **except** when [isBrandName] says
  /// otherwise.
  final String title;

  /// Opens the link. Wired by the page, which owns the failure message.
  final VoidCallback onTap;

  /// Secondary text at the end of the row: the market's kind, the licence's
  /// name. Optional, because a repository row has nothing to add.
  final String? trailing;

  /// Whether [title] is a brand or an institution rather than translated copy.
  ///
  /// Only changes the weight — a market name is the subject of its row, a
  /// label like "App repository" is not. It exists mostly as documentation at
  /// the call site: it marks which strings deliberately bypass `AppMessages`
  /// (`i18n-convention.md`, rule 9).
  final bool isBrandName;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: WidthValues.spacingMd,
        vertical: WidthValues.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isBrandName ? FontWeight.w600 : FontWeight.w400,
                color: ColorValues.textPrimary(context),
              ),
            ),
          ),
          if (trailing != null) ...<Widget>[
            SizedBox(width: WidthValues.spacingXs),
            // `Expanded`, not `Flexible`, and for the reason #37 had to learn
            // twice: a loose child's unused share strands at the end of the
            // row and drags the icon away from the edge.
            Expanded(
              flex: 5,
              child: Text(
                trailing!,
                textAlign: TextAlign.end,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ColorValues.textBrandSecondary(context),
                ),
              ),
            ),
          ] else
            const Spacer(flex: 5),
          SizedBox(width: WidthValues.spacingXs),
          Icon(
            Icons.open_in_new_rounded,
            size: 18,
            color: ColorValues.textTertiary(context),
          ),
        ],
      ),
    ),
  );
}

/// A row that states a fact and goes nowhere.
///
/// El nombre del autor y la versión (#43) son las dos. Deliberately **not** an
/// [AboutLinkTile]: that
/// shape ends in an open-in-new icon, which promises a browser. This one
/// promises nothing, which is what it does — the author used to be a link to
/// their profile and stopped being one when the project block was withdrawn,
/// because that profile is the repository by another route.
class AboutFactRow extends StatelessWidget {
  const AboutFactRow({super.key, required this.label, required this.value});

  /// From `AppMessages`.
  final String label;

  /// Already formatted. This widget composes nothing.
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: WidthValues.spacingMd,
      vertical: WidthValues.spacingSm,
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: ColorValues.textPrimary(context),
            ),
          ),
        ),
        SizedBox(width: WidthValues.spacingXs),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorValues.textBrandSecondary(context),
            ),
          ),
        ),
      ],
    ),
  );
}

/// The translated label of a [MarketKind].
///
/// A function and not a field on the enum: the label goes through
/// `AppMessages`, which resolves against the active locale at call time, and an
/// enum field would freeze whichever language the app started in.
String marketKindLabel(MarketKind kind) => switch (kind) {
  MarketKind.official => AppMessages.marketKindOfficial,
  MarketKind.peerToPeer => AppMessages.marketKindPeerToPeer,
  MarketKind.aggregator => AppMessages.marketKindAggregator,
};
