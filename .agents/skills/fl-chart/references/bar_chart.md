# BarChart API Reference

## BarChartData

| Property | Description | Default |
|:---------|:-----------|:--------|
| barGroups | List of [BarChartGroupData](#barchartgroupdata) — one item per group for normal bars | `[]` |
| groupsSpace | Space between groups (only for `.start`, `.center`, `.end` alignment) | `16` |
| alignment | [BarChartAlignment](#barchartalignment) — inspired by MainAxisAlignment | `spaceEvenly` |
| titlesData | [FlTitlesData](./base_chart.md#fltitlesdata) | `FlTitlesData()` |
| rangeAnnotations | [RangeAnnotations](./base_chart.md#rangeannotations) | `RangeAnnotations()` |
| backgroundColor | Background color behind chart | `null` |
| barTouchData | [BarTouchData](#bartouchdata) | `BarTouchData()` |
| gridData | [FlGridData](./base_chart.md#flgriddata) | `FlGridData()` |
| borderData | [FlBorderData](./base_chart.md#flborderdata) | `FlBorderData()` |
| maxY / minY | Y-axis bounds (explicit is more performant) | `null` |
| baselineY | Y-axis baseline | `0` |
| extraLinesData | [ExtraLinesData](./base_chart.md#extralinesdata) — vertical lines are ignored in BarChart | `ExtraLinesData()` |
| rotationQuarterTurns | Rotate chart 90° per quarter turn (1 = horizontal bar chart) | `0` |
| errorIndicatorData | Error indicator for rod `toYErrorRange` | `ErrorIndicatorData()` |

## BarChartAlignment

Enum: `start`, `end`, `center`, `spaceEvenly`, `spaceAround`, `spaceBetween`

## BarChartGroupData

| Property | Description | Default |
|:---------|:-----------|:--------|
| x | X position on horizontal axis | `null` |
| barRods | List of [BarChartRodData](#barchartroddata) | `[]` |
| barsSpace | Space between rods within the group | `2` |
| showingTooltipIndicators | Rod indexes to manually show tooltips (disable touches first) | `[]` |

## BarChartRodData

| Property | Description | Default |
|:---------|:-----------|:--------|
| fromY | Rod start Y value | `0` |
| toY | Rod end Y value | required |
| color | Rod color | `Colors.cyan` |
| gradient | Gradient fill | `null` |
| width | Rod stroke width | `8` |
| borderRadius | Edge rounding (null = fully round) | `null` |
| borderDashArray | Dash pattern for border stroke | `null` |
| borderSide | Border stroke around rod (null = no stroke) | `null` |
| backDrawRodData | [BackgroundBarChartRodData](#backgroundbarchartroddata) for background rod | `null` |
| rodStackItem | List of [BarChartRodStackItem](#barchartrodstackitem) for stacked bars | `[]` |
| toYErrorRange | [FlErrorRange](./base_chart.md#flerrorrange) for error indicator | `null` |
| label | [BarChartRodLabel](#barchartrodlabel) text label on rod | `null` |

## BackgroundBarChartRodData

| Property | Description | Default |
|:---------|:-----------|:--------|
| fromY | Start Y | `0` |
| toY | End Y | `8` |
| show | Show/hide | `false` |
| color | Color | `Colors.blueGrey` |
| gradient | Gradient | `null` |

## BarChartRodStackItem

| Property | Description | Default |
|:---------|:-----------|:--------|
| fromY | Stack item start Y | required |
| toY | Stack item end Y | required |
| color | Stack item color | required |
| gradient | Stack item gradient | `null` |
| label | Text label | `null` |
| labelStyle | TextStyle for label | `null` |
| borderSide | Border stroke per stack item | `null` |

## BarChartRodLabel

Extends [FlLabel](./base_chart.md#fllabel).

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide label | `true` |
| text | Label text | `''` |
| style | TextStyle | `null` |
| angle | Rotation in degrees | `0` |
| textDirection | TextDirection | `TextDirection.ltr` |
| offset | Offset from rod tip (`dx` horizontal, `dy` vertical) | `Offset(0, 8)` |

## BarTouchData

| Property | Description | Default |
|:---------|:-----------|:--------|
| enabled | Enable/disable touch | `true` |
| mouseCursorResolver | Custom cursor per event | `MouseCursor.defer` |
| touchTooltipData | [BarTouchTooltipData](#bartouchtooltipdata) | `BarTouchTooltipData()` |
| touchExtraThreshold | Bounding threshold for touch accuracy | `EdgeInsets.all(4)` |
| allowTouchBarBackDraw | Enable touch on background rod | `false` |
| handleBuiltInTouches | Enable built-in tooltip display | `true` |
| touchCallback | `(FlTouchEvent, BarTouchResponse?) → void` | `null` |
| longPressDuration | Custom long-press duration | `null` |

## BarTouchTooltipData

| Property | Description | Default |
|:---------|:-----------|:--------|
| tooltipBorder | Border | `BorderSide.none` |
| tooltipBorderRadius | Corner radius | `BorderRadius.circular(4)` |
| tooltipPadding | Padding | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` |
| tooltipMargin | Margin from spot | `16` |
| tooltipHorizontalAlignment | Alignment relative to bar | `FLHorizontalAlignment.center` |
| tooltipHorizontalOffset | Horizontal offset | `0` |
| maxContentWidth | Max width before text wrap | `120` |
| getTooltipItems | Callback: `(group, groupIndex, rod, rodIndex) → BarTooltipItem` | `defaultBarTooltipItem` |
| fitInsideHorizontally | Force inside bounds | `false` |
| fitInsideVertically | Force inside bounds | `false` |
| direction | Tooltip direction (top/bottom/auto) | `auto` |
| getTooltipColor | Background color callback | `Colors.blueGrey.darken(15)` |

## BarTooltipItem

| Property | Description | Default |
|:---------|:-----------|:--------|
| text | Text content | `null` |
| textStyle | TextStyle | `null` |
| textAlign | TextAlign | `TextAlign.center` |
| textDirection | TextDirection | `TextDirection.ltr` |
| children | List\<TextSpan\> for rich text | `null` |

## BarTouchResponse

| Property | Description |
|:---------|:-----------|
| touchLocation | Touch position in device pixel coordinates |
| touchChartCoordinate | Touch position in chart coordinates |
| spot | [BarTouchedSpot](#bartouchedspot) |

## BarTouchedSpot

| Property | Description |
|:---------|:-----------|
| touchedBarGroup | The touched BarChartGroupData |
| touchedBarGroupIndex | Index of touched group |
| touchedRodData | The touched BarChartRodData |
| touchedRodDataIndex | Index of touched rod |
| touchedStackItem | Touched BarChartRodStackItem (stacked charts) |
| touchedStackItemIndex | Index of stack item (-1 if none) |
