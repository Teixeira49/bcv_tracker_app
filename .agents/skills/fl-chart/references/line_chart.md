# LineChart API Reference

## LineChartData

| Property | Description | Default |
|:---------|:-----------|:--------|
| lineBarsData | List of [LineChartBarData](#linechartbardata) to show chart lines; they stack and draw on top of each other | `[]` |
| betweenBarsData | List of [BetweenBarsData](#betweenbarsdata) to fill area between 2 lines | `[]` |
| titlesData | [FlTitlesData](./base_chart.md#fltitlesdata) | `FlTitlesData()` |
| extraLinesData | [ExtraLinesData](./base_chart.md#extralinesdata) for horizontal/vertical reference lines | `ExtraLinesData()` |
| lineTouchData | [LineTouchData](#linetouchdata) for touch interactivity | `LineTouchData()` |
| rangeAnnotations | [RangeAnnotations](./base_chart.md#rangeannotations) drawn behind chart | `RangeAnnotations()` |
| showingTooltipIndicators | List of [LineBarSpot](#linebarspot) to manually show tooltips (disable touches first) | `[]` |
| gridData | [FlGridData](./base_chart.md#flgriddata) | `FlGridData()` |
| borderData | [FlBorderData](./base_chart.md#flborderdata) | `FlBorderData()` |
| minX / maxX | X-axis bounds (auto-calculated from data if null; explicit is more performant) | `null` |
| minY / maxY | Y-axis bounds (auto-calculated from data if null; explicit is more performant) | `null` |
| baselineX / baselineY | Baseline values for axes | `0` |
| clipData | Prevent drawing outside border | `FlClipData.none()` |
| backgroundColor | Background color behind chart | `null` |
| rotationQuarterTurns | Rotate chart 90° per quarter turn (like RotatedBox) | `0` |

## LineChartBarData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show or hide this line | `true` |
| spots | List of [FlSpot](./base_chart.md#flspot) coordinates the line passes through | `[]` |
| color | Line color | `Colors.redAccent` |
| gradient | Gradient applied to line (LinearGradient, RadialGradient) | `null` |
| gradientArea | Area where gradient is applied | `null` |
| barWidth | Stroke width of the line | `2.0` |
| isCurved | Curve corners at spot positions | `false` |
| curveSmoothness | Smoothness radius when `isCurved: true` | `0.35` |
| preventCurveOverShooting | Prevent overshooting on linear sequences | `false` |
| preventCurveOvershootingThreshold | Threshold for overshoot prevention | `10.0` |
| isStrokeCapRound | Round line start/end caps | `false` |
| isStrokeJoinRound | Round stroke joins | `false` |
| belowBarData | [BarAreaData](#barareadata) for area below line | `BarAreaData()` |
| aboveBarData | [BarAreaData](#barareadata) for area above line | `BarAreaData()` |
| dotData | [FlDotData](#fldotdata) for spot dots | `FlDotData()` |
| showingIndicators | Indexes of spots to show indicators on | `[]` |
| dashArray | Circular array of dash/gap lengths (e.g., `[5, 10]`) | `null` |
| shadow | Shadow behind the line | `Shadow()` |
| isStepLineChart | Draw as step line chart using `lineChartStepData` | `false` |
| lineChartStepData | [LineChartStepData](#linechartstepdata) config (only if `isStepLineChart: true`) | `LineChartStepData()` |
| errorIndicatorData | Error indicator config for FlSpot xError/yError | `ErrorIndicatorData()` |

## LineChartStepData

| Property | Description | Default |
|:---------|:-----------|:--------|
| stepDirection | Direction of each step: 0.0 (forward) to 1.0 (backward) | `stepDirectionMiddle` |

## BetweenBarsData

| Property | Description | Default |
|:---------|:-----------|:--------|
| fromIndex | Index of first LineChartBarData (zero-based) | required |
| toIndex | Index of second LineChartBarData (zero-based) | required |
| color | Fill color | `Colors.blueGrey` |
| gradient | Gradient fill | `null` |

## BarAreaData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show the area fill | `false` |
| color | Fill color | `Colors.blueGrey` |
| gradient | Gradient fill | `null` |
| spotsLine | [BarAreaSpotsLine](#barareaspotsline) from spots to chart edge | `BarAreaSpotsLine()` |
| cutOffY | Cut area at this Y value (requires `applyCutOffY: true`) | `null` |
| applyCutOffY | Enable cutOffY | `false` |

## BarAreaSpotsLine

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show spot lines | `true` |
| flLineStyle | [FlLine](./base_chart.md#flline) style | `Colors.blueGrey` |
| checkToShowSpotLine | Function to show/hide per spot | `showAllSpotsBelowLine` |
| applyCutOffY | Inherit cutOff from parent BarAreaData | `true` |

## FlDotData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show dots on spots | `true` |
| checkToShowDot | Function to show/hide per spot | `showAllDots` |
| getDotPainter | Function returning dot painter per spot | `_defaultGetDotPainter` |

## LineTouchData

| Property | Description | Default |
|:---------|:-----------|:--------|
| enabled | Enable/disable touch | `true` |
| mouseCursorResolver | Custom cursor per touch event | `MouseCursor.defer` |
| touchTooltipData | [LineTouchTooltipData](#linetouchtooltipdata) | `LineTouchTooltipData()` |
| getTouchedSpotIndicator | Callback returning [TouchedSpotIndicatorData](#touchedspotindicatordata) list | `defaultTouchedIndicators` |
| touchSpotThreshold | Touch accuracy threshold | `10` |
| distanceCalculator | Function to calculate spot-to-touch distance | `_xDistance` |
| handleBuiltInTouches | Enable built-in tooltip + indicator display | `true` |
| getTouchLineStart | Where indicator line starts (default: chart bottom) | `defaultGetTouchLineStart` |
| getTouchLineEnd | Where indicator line ends (default: touch point) | `defaultGetTouchLineEnd` |
| touchCallback | `(FlTouchEvent, LineTouchResponse?) → void` | `null` |
| longPressDuration | Custom long-press duration | `null` |

## LineTouchTooltipData

| Property | Description | Default |
|:---------|:-----------|:--------|
| tooltipBorder | Border of tooltip bubble | `BorderSide.none` |
| tooltipBorderRadius | Corner radius | `BorderRadius.circular(4)` |
| tooltipPadding | Inner padding | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` |
| tooltipMargin | Margin from touched spot | `16` |
| tooltipHorizontalAlignment | Horizontal alignment relative to spot | `FLHorizontalAlignment.center` |
| tooltipHorizontalOffset | Horizontal offset | `0` |
| maxContentWidth | Max tooltip width before text wraps | `120` |
| getTooltipItems | Callback returning list of [LineTooltipItem](#linetooltipitem) | `defaultLineTooltipItem` |
| fitInsideHorizontally | Force tooltip inside chart bounds horizontally | `false` |
| fitInsideVertically | Force tooltip inside chart bounds vertically | `false` |
| showOnTopOfTheChartBoxArea | Force tooltip to top of line | `false` |
| getTooltipColor | Callback returning background color per spot | `Colors.blueGrey.darken(15)` |

## LineTooltipItem

| Property | Description | Default |
|:---------|:-----------|:--------|
| text | Text content | `null` |
| textStyle | TextStyle | `null` |
| textAlign | TextAlign | `TextAlign.center` |
| textDirection | TextDirection | `TextDirection.ltr` |
| children | List\<TextSpan\> for rich text | `null` |

## TouchedSpotIndicatorData

| Property | Description | Default |
|:---------|:-----------|:--------|
| indicatorBelowLine | [FlLine](./base_chart.md#flline) for vertical indicator | `null` |
| touchedSpotDotData | [FlDotData](#fldotdata) for dot on touched spot | `null` |

## LineBarSpot

| Property | Description |
|:---------|:-----------|
| bar | The LineChartBarData containing the spot |
| barIndex | Index of LineChartBarData in LineChartData |
| spotIndex | Index of FlSpot in LineChartBarData |

## TouchLineBarSpot

Extends LineBarSpot with:

| Property | Description |
|:---------|:-----------|
| distance | Distance to the touch event |

## LineTouchResponse

| Property | Description |
|:---------|:-----------|
| touchLocation | Touch position in device pixel coordinates |
| touchChartCoordinate | Touch position in chart coordinates |
| lineBarSpots | List of [TouchLineBarSpot](#touchlinebarspot) |
