# CandlestickChart API Reference

## CandlestickChartData

| Property | Description | Default |
|:---------|:-----------|:--------|
| candlestickSpots | List of [CandlestickSpot](#candlestickspot) (OHLC data points) | `[]` |
| candlestickPainter | Custom painter for individual candlesticks | `DefaultCandlestickPainter()` |
| titlesData | [FlTitlesData](./base_chart.md#fltitlesdata) | `FlTitlesData()` |
| candlestickTouchData | [CandlestickTouchData](#candlesticktouchdata) | `CandlestickTouchData()` |
| showingTooltipIndicators | Spot indices for manual tooltip display (disable touches first) | `[]` |
| gridData | [FlGridData](./base_chart.md#flgriddata) | `FlGridData()` |
| borderData | [FlBorderData](./base_chart.md#flborderdata) | `FlBorderData()` |
| minX / maxX | X-axis bounds (explicit is more performant) | `null` |
| minY / maxY | Y-axis bounds (explicit is more performant) | `null` |
| baselineX / baselineY | Axis baselines | `0` |
| rangeAnnotations | [RangeAnnotations](./base_chart.md#rangeannotations) | `RangeAnnotations()` |
| clipData | Prevent drawing outside border | `FlClipData.none()` |
| backgroundColor | Background color | `null` |
| rotationQuarterTurns | Rotate chart 90° per quarter turn | `0` |
| touchedPointIndicator | [AxisSpotIndicator](./base_chart.md#axisspotindicator) for touched candle highlight | `null` |

## CandlestickSpot

Based on the [OHLC standard](https://en.wikipedia.org/wiki/Open-high-low-close_chart).

| Property | Description | Default |
|:---------|:-----------|:--------|
| open | Open price value | required |
| high | High price value | required |
| low | Low price value | required |
| close | Close price value | required |
| show | Show/hide this candlestick | `true` |

## CandlestickTouchData

| Property | Description | Default |
|:---------|:-----------|:--------|
| enabled | Enable/disable touch | `true` |
| touchCallback | `(FlTouchEvent, CandlestickTouchResponse?) → void` | `null` |
| mouseCursorResolver | Custom cursor per event | `MouseCursor.defer` |
| touchTooltipData | [CandlestickTouchTooltipData](#candlesticktouchtooltipdata) | `CandlestickTouchTooltipData()` |
| touchSpotThreshold | Touch accuracy threshold | `4` |
| handleBuiltInTouches | Enable built-in tooltip + indicator on touch/hover | `true` |
| longPressDuration | Custom long-press duration | `null` |

## CandlestickTouchTooltipData

| Property | Description | Default |
|:---------|:-----------|:--------|
| tooltipBorder | Border | `BorderSide.none` |
| tooltipBorderRadius | Corner radius | `BorderRadius.circular(4)` |
| tooltipPadding | Padding | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` |
| tooltipHorizontalAlignment | Alignment relative to spot | `FLHorizontalAlignment.center` |
| tooltipHorizontalOffset | Horizontal offset | `0` |
| maxContentWidth | Max width before text wrap | `120` |
| getTooltipItems | `(CandlestickSpot) → CandlestickTooltipItem` | `defaultCandlestickTooltipItem` |
| fitInsideHorizontally | Force inside bounds | `false` |
| fitInsideVertically | Force inside bounds | `false` |
| showOnTopOfTheChartBoxArea | Force tooltip to chart top | `false` |
| getTooltipColor | Background color callback | `Colors.blueGrey.darken(80)` |

## CandlestickTooltipItem

| Property | Description | Default |
|:---------|:-----------|:--------|
| text | Text content | `null` |
| textStyle | TextStyle | `null` |
| textDirection | TextDirection | `TextDirection.ltr` |
| bottomMargin | Bottom margin to top of spot | `0` |
| children | List\<TextSpan\> for rich text | `null` |

## CandlestickTouchResponse

| Property | Description |
|:---------|:-----------|
| touchLocation | Touch position in device pixel coordinates |
| touchChartCoordinate | Touch position in chart coordinates |
| touchedSpot | [CandlestickTouchedSpot](#candlesticktouchedspot) |

## CandlestickTouchedSpot

| Property | Description |
|:---------|:-----------|
| spot | Touched CandlestickSpot |
| spotIndex | Index of touched spot |
