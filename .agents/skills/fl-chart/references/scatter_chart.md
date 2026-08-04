# ScatterChart API Reference

## ScatterChartData

| Property | Description | Default |
|:---------|:-----------|:--------|
| scatterSpots | List of [ScatterSpot](#scatterspot) | `[]` |
| titlesData | [FlTitlesData](./base_chart.md#fltitlesdata) | `FlTitlesData()` |
| scatterTouchData | [ScatterTouchData](#scattertouchdata) | `ScatterTouchData()` |
| showingTooltipIndicators | Spot indices for manual tooltip display (disable touches first) | `[]` |
| rotationQuarterTurns | Rotate chart 90° per quarter turn | `0` |
| errorIndicatorData | Error indicator for spot xError/yError | `ErrorIndicatorData()` |

## ScatterSpot

| Property | Description | Default |
|:---------|:-----------|:--------|
| show | Show/hide spot | `true` |
| radius | Spot radius | `8` |
| color | Spot color | auto-calculated |
| renderPriority | Sort order to manage overlap | `0` |
| xError | [FlErrorRange](./base_chart.md#flerrorrange) for x-axis error | `null` |
| yError | [FlErrorRange](./base_chart.md#flerrorrange) for y-axis error | `null` |

## ScatterTouchData

| Property | Description | Default |
|:---------|:-----------|:--------|
| enabled | Enable/disable touch | `true` |
| mouseCursorResolver | Custom cursor per event | `MouseCursor.defer` |
| touchTooltipData | [ScatterTouchTooltipData](#scattertouchtooltipdata) | `ScatterTouchTooltipData()` |
| touchSpotThreshold | Touch accuracy threshold | `0` |
| handleBuiltInTouches | Enable built-in tooltip display | `true` |
| touchCallback | `(FlTouchEvent, ScatterTouchResponse?) → void` | `null` |
| longPressDuration | Custom long-press duration | `null` |

## ScatterTouchTooltipData

| Property | Description | Default |
|:---------|:-----------|:--------|
| tooltipBorder | Border | `BorderSide.none` |
| tooltipBorderRadius | Corner radius | `BorderRadius.circular(4)` |
| tooltipPadding | Padding | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)` |
| tooltipHorizontalAlignment | Alignment relative to spot | `FLHorizontalAlignment.center` |
| tooltipHorizontalOffset | Horizontal offset | `0` |
| maxContentWidth | Max width before text wrap | `120` |
| getTooltipItems | `(ScatterSpot) → ScatterTooltipItem` | `defaultScatterTooltipItem` |
| fitInsideHorizontally | Force inside bounds | `false` |
| fitInsideVertically | Force inside bounds | `false` |
| getTooltipColor | Background color callback | `Colors.blueGrey.darken(15)` |

## ScatterTooltipItem

| Property | Description | Default |
|:---------|:-----------|:--------|
| text | Text content | `null` |
| textStyle | TextStyle | `null` |
| textDirection | TextDirection | `TextDirection.ltr` |
| bottomMargin | Bottom margin to top of spot | `0` |
| children | List\<TextSpan\> for rich text | `null` |

## ScatterTouchResponse

| Property | Description |
|:---------|:-----------|
| touchLocation | Touch position in device pixel coordinates |
| touchChartCoordinate | Touch position in chart coordinates |
| touchedSpot | [ScatterTouchedSpot](#scattertouchedspot) |

## ScatterTouchedSpot

| Property | Description |
|:---------|:-----------|
| spot | Touched ScatterSpot |
| spotIndex | Index of touched spot |

## ScatterLabelSettings

| Property | Description | Default |
|:---------|:-----------|:--------|
| showLabel | Show/hide labels | `false` |
| getLabelTextStyleFunction | `(index) → TextStyle` | `null` |
| getLabelFunction | `(index) → String` | `spot.radius.toString()` |
| textDirection | TextDirection | `TextDirection.ltr` |
