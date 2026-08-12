part of '../page/currency_detail_sheet.dart';

/// Pinned bar at the top of the sheet: the drag handle and the close button.
///
/// Pinned rather than scrolled away so there is always something to grab and a
/// way out that does not depend on the gesture. It carries **no text on
/// purpose**: a fixed-extent sliver cannot grow with the system font scale, and
/// text is the only thing in the sheet that would need to.
class _CurrencyDetailGrabBar extends StatelessWidget {
  const _CurrencyDetailGrabBar();

  @override
  Widget build(BuildContext context) => const SliverPersistentHeader(
    pinned: true,
    delegate: _CurrencyDetailGrabBarDelegate(),
  );
}

class _CurrencyDetailGrabBarDelegate extends SliverPersistentHeaderDelegate {
  const _CurrencyDetailGrabBarDelegate();

  /// Fits a 40×40 tap target plus the handle above it. Fixed, see the note on
  /// [_CurrencyDetailGrabBar].
  static const double _height = 48;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      // Opaque: the bar stays pinned while the content scrolls under it.
      color: ColorValues.bgPrimary(context),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: WidthValues.spacingXs),
              child: Container(
                width: WidthValues.spacingLg + WidthValues.spacingMd,
                height: WidthValues.spacingXxs,
                decoration: BoxDecoration(
                  color: ColorValues.fgSecondary(context).withAlpha(140),
                  borderRadius: BorderRadius.circular(WidthValues.radiusFull),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: WidthValues.spacingXs),
              child: IconButton(
                onPressed: () => Get.back<void>(),
                tooltip: AppMessages.closeAction,
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 40,
                  height: 40,
                ),
                icon: Icon(
                  Icons.close,
                  color: ColorValues.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CurrencyDetailGrabBarDelegate oldDelegate) =>
      false;
}

/// The rate itself: who publishes it, how much it is worth and how it moved.
///
/// Scrolls away with the content — the pinned part is only the grab bar — so a
/// long chart or converter can use the whole sheet once the user has read the
/// number.
class _CurrencyDetailHeader extends StatelessWidget {
  const _CurrencyDetailHeader({required this.currency});

  final Currency currency;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      WidthValues.spacingMd,
      WidthValues.spacingXs,
      WidthValues.spacingMd,
      WidthValues.spacingSm,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            _CurrencyDetailAvatar(currency: currency),
            SizedBox(width: WidthValues.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    CurrencyHelpers.castCurrencyDisplayName(currency),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ColorValues.textPrimary(context),
                    ),
                  ),
                  SizedBox(height: WidthValues.spacingXxs),
                  Text(
                    currency.platform,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorValues.textTertiary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: WidthValues.spacingMd),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    CurrencyHelpers.castCurrency(value: currency.value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: ColorValues.textPrimary(context),
                    ),
                  ),
                  Text(
                    CurrencyHelpers.completeCurrencyExchange(currency.keyName),
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorValues.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            // Only when the source reported a change: a `0%` badge on a rate
            // that simply has no previous value reads as "it did not move".
            if (currency.tendency != null) ...<Widget>[
              SizedBox(width: WidthValues.spacingXs),
              Semantics(
                label: AppMessages.variationLabel,
                child: PerformanceIndicatorWidget(value: currency.tendency!),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

/// Avatar of the rate, showing whichever of the two identities carries
/// information.
///
/// The two Home cards resolve this differently and both are right: the average
/// card shows the **platform logo** the backend sends, because every row there
/// quotes the same dollar and the market is what tells them apart; the BCV card
/// shows the **country flag** bundled with the app, because every row there
/// comes from the same institution and the currency is what tells them apart.
///
/// The sheet serves both, so it mirrors the card that opened it: an official
/// rate leads with the flag (the BCV seal is identical on its dollar, its euro
/// and its rouble, so it would say nothing), a parallel one leads with the
/// platform logo. Either way the other identity is written in text right
/// beside it.
///
/// The currency initials close the chain because they always work: no network,
/// no asset.
class _CurrencyDetailAvatar extends StatelessWidget {
  const _CurrencyDetailAvatar({required this.currency});

  final Currency currency;

  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final String flagAsset = CurrencyHelpers.castCurrencySymbolIcon(
      currencyCode: currency.keyName,
    );
    final bool preferFlag =
        CurrencyHelpers.isOfficialRate(currency) && flagAsset.isNotEmpty;
    final String? logoUrl = preferFlag ? null : currency.imgUrl;

    return CircleAvatar(
      radius: _radius,
      backgroundColor: ColorValues.borderTertiary(context),
      backgroundImage: logoUrl == null ? null : NetworkImage(logoUrl),
      child: logoUrl != null
          ? null
          : flagAsset.isEmpty
          ? Text(
              _initials,
              style: TextStyle(
                color: ColorValues.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            )
          : ClipOval(
              child: SvgPicture.asset(
                flagAsset,
                width: _radius * 2,
                height: _radius * 2,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  /// First two characters of the code, guarded: `keyName` is optional in the
  /// contract and degrades to an empty string, on which a blind `substring(0, 2)`
  /// throws.
  String get _initials {
    final String code = CurrencyHelpers.castCurrencyDisplayCode(
      currency.keyName,
    );
    return code.length <= 2 ? code : code.substring(0, 2);
  }
}
