# Base Chart — Shared Components

Components shared across all axis-based chart types (LineChart, BarChart, ScatterChart, CandlestickChart).

## FlTitlesData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide all titles | `true` |
| leftTitles | [AxisTitles](#axistitles) | `AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: true))` |
| topTitles | [AxisTitles](#axistitles) | `AxisTitles(sideTitles: SideTitles(reservedSize: 6, showTitles: true))` |
| rightTitles | [AxisTitles](#axistitles) | `AxisTitles(sideTitles: SideTitles(reservedSize: 40, showTitles: true))` |
| bottomTitles | [AxisTitles](#axistitles) | `AxisTitles(sideTitles: SideTitles(reservedSize: 6, showTitles: true))` |

## AxisTitles

| Property | Description | Default |
|:---------|:-----------|:--------|
| axisNameSize | Size of axis name area | `16` |
| axisNameWidget | Widget for axis name label | `null` |
| sideTitles | [SideTitles](#sidetitles) for axis tick labels | `SideTitles()` |
| drawBehindEverything | Draw titles behind chart (prevents tooltip overlap) | `true` |
| sideTitleAlignment | [SideTitleAlignment](#sidetitlealignment): `.outside`, `.border`, `.inside` | `.outside` |

## SideTitles

| Property | Description | Default |
|:---------|:-----------|:--------|
| showTitles | Show/hide tick labels | `false` |
| getTitlesWidget | `(value, TitleMeta) → Widget` returning label for each tick | `defaultGetTitle` |
| reservedSize | Max space for titles | `22` |
| interval | Tick interval (auto-calculated if null) | `null` |
| minIncluded | Include title at min value | `true` |
| maxIncluded | Include title at max value | `true` |

## SideTitleAlignment

| Option | Description | Default |
|:-------|:-----------|:--------|
| `SideTitleAlignment.outside` | Labels outside chart area | ✅ Yes |
| `SideTitleAlignment.border` | Labels along the border | No |
| `SideTitleAlignment.inside` | Labels inside chart area | No |

## FlGridData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide grid | `true` |
| drawHorizontalLine | Show horizontal grid lines | `true` |
| horizontalInterval | Interval (auto if null) | `null` |
| getDrawingHorizontalLine | `(value) → FlLine` for line style | `defaultGridLine` |
| checkToShowHorizontalLine | `(value) → bool` to show/hide per line | `showAllGrids` |
| drawVerticalLine | Show vertical grid lines | `true` |
| verticalInterval | Interval (auto if null) | `null` |
| getDrawingVerticalLine | `(value) → FlLine` for line style | `defaultGridLine` |
| checkToShowVerticalLine | `(value) → bool` to show/hide per line | `showAllGrids` |

## FlBorderData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide border | `true` |
| border | Flutter Border object | `Border.all(color: Colors.black, width: 1.0)` |

## FlSpot

| Property | Description |
|:---------|:-----------|
| x | X coordinate (from left) |
| y | Y coordinate (from bottom) |
| xError | [FlErrorRange](#flerrorrange) for x-axis |
| yError | [FlErrorRange](#flerrorrange) for y-axis |

## FlLine

| Property | Description | Default |
|:---------|:-----------|:--------|
| color | Line color | `Colors.black` |
| gradient | Line gradient | `null` |
| strokeWidth | Stroke width | `2` |
| dashArray | Dash pattern (e.g., `[5, 10]`) | `null` |

## FlLabel

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide label | `true` |
| text | Label text | `''` |
| style | TextStyle | `null` |
| angle | Rotation in degrees | `0` |
| textDirection | TextDirection | `TextDirection.ltr` |

## FlErrorRange

| Property | Description |
|:---------|:-----------|
| lowerBy | Lower error value (subtracted from spot, must be positive) |
| upperBy | Upper error value (added to spot, must be positive) |

## FlErrorIndicatorData

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide error indicator | `true` |
| painter | Custom painter callback | `FlSimpleErrorPainter()` |

## ExtraLinesData

| Property | Description | Default |
|:---------|:-----------|:--------|
| extraLinesOnTop | Paint extra lines over or under trendline | `true` |
| horizontalLines | List of [HorizontalLine](#horizontalline) | `[]` |
| verticalLines | List of [VerticalLine](#verticalline) (ignored in BarChart) | `[]` |

## HorizontalLine

| Property | Description | Default |
|:---------|:-----------|:--------|
| y | Y position | required |
| color | Line color | `Colors.black` |
| gradient | Line gradient | `null` |
| strokeWidth | Stroke width | `2` |
| strokeCap | StrokeCap (may not work with dashes) | `StrokeCap.butt` |
| image | Image annotation | `null` |
| sizedPicture | SVG annotation | `null` |
| label | [HorizontalLineLabel](#horizontallinelabel) | `null` |

## VerticalLine

| Property | Description | Default |
|:---------|:-----------|:--------|
| x | X position | required |
| color | Line color | `Colors.black` |
| gradient | Line gradient | `null` |
| strokeWidth | Stroke width | `2` |
| strokeCap | StrokeCap | `StrokeCap.butt` |
| image | Image annotation | `null` |
| sizedPicture | SVG annotation | `null` |
| label | [VerticalLineLabel](#verticallinelabel) | `null` |

## HorizontalLineLabel

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide | `false` |
| padding | EdgeInsets | `EdgeInsets.zero` |
| style | TextStyle | `TextStyle(fontSize: 11, color: line.color)` |
| alignment | Alignment relative to line | `Alignment.topLeft` |
| direction | Label direction | `LabelDirection.horizontal` |
| labelResolver | `(line) → String` | `defaultLineLabelResolver` |

## VerticalLineLabel

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide | `false` |
| padding | EdgeInsets | `EdgeInsets.zero` |
| style | TextStyle | `TextStyle(fontSize: 11, color: line.color)` |
| alignment | Alignment relative to line | `Alignment.topLeft` |
| direction | Label direction | `LabelDirection.vertical` |
| labelResolver | `(line) → String` | `defaultLineLabelResolver` |

## RangeAnnotations

| Property | Description | Default |
|:---------|:-----------|:--------|
| horizontalRangeAnnotations | List of [HorizontalRangeAnnotation](#horizontalrangeannotation) | `[]` |
| verticalRangeAnnotations | List of [VerticalRangeAnnotation](#verticalrangeannotation) | `[]` |

## HorizontalRangeAnnotation

| Property | Description | Default |
|:---------|:-----------|:--------|
| y1 | Start Y | required |
| y2 | End Y | required |
| color | Fill color | `Colors.white` |
| gradient | Fill gradient | `null` |

## VerticalRangeAnnotation

| Property | Description | Default |
|:---------|:-----------|:--------|
| x1 | Start X | required |
| x2 | End X | required |
| color | Fill color | `Colors.white` |
| gradient | Fill gradient | `null` |

## FlTouchEvent

Base class for all touch/pointer events:

| Event | Trigger |
|:------|:--------|
| FlPanDownEvent | Pointer contacted screen |
| FlPanStartEvent | Pointer began moving |
| FlPanUpdateEvent | Moving pointer moved again |
| FlPanCancelEvent | Pan did not complete |
| FlPanEndEvent | Pointer lifted after pan |
| FlTapDownEvent | Potential tap contacted screen |
| FlTapCancelEvent | Tap cancelled |
| FlTapUpEvent | Tap completed |
| FlLongPressStart | Long press began |
| FlLongPressMoveUpdate | Moving during long press |
| FlLongPressEnd | Long press ended |
| FlPointerEnterEvent | Pointer entered chart area |
| FlPointerHoverEvent | Pointer hovering (not touching) |
| FlPointerExitEvent | Pointer exited chart area |

## AxisSpotIndicator

| Property | Description | Default |
|:---------|:-----------|:--------|
| x | X value of touched spot | required |
| y | Y value of touched spot | required |
| AxisSpotIndicatorPainter | Custom painter for indicator | `AxisLinesIndicatorPainter()` |

## FLHorizontalAlignment

Enum: `center`, `left`, `right`
