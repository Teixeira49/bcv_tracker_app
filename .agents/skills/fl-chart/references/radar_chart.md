# RadarChart API Reference

## RadarChartData

| Property | Description | Default |
|:---------|:-----------|:--------|
| dataSets | List of [RadarDataSet](#radardataset) | `[]` |
| radarBackgroundColor | Background fill color | `Colors.transparent` |
| radarShape | Border/background shape | `RadarShape.circle` |
| radarBorderData | Outer border style | `BorderSide(color: Colors.black, width: 2)` |
| getTitle | `(index, angle) → RadarChartTitle` for axis titles | `null` |
| titleTextStyle | Default TextStyle for titles | `TextStyle(color: Colors.black, fontSize: 12)` |
| titlePositionPercentageOffset | Title distance from chart (0-1) | `0.2` |
| tickCount | Number of concentric tick rings | `1` |
| ticksTextStyle | TextStyle for tick labels | `TextStyle(fontSize: 10, color: Colors.black)` |
| tickBorderData | Style of tick ring borders | `BorderSide(color: Colors.black, width: 2)` |
| gridBorderData | Style of radial grid lines | `BorderSide(color: Colors.black, width: 2)` |
| radarTouchData | [RadarTouchData](#radartouchdata) | `RadarTouchData()` |
| isMinValueAtCenter | Place minimum value at center (vs zero) | `false` |

## RadarDataSet

| Property | Description | Default |
|:---------|:-----------|:--------|
| dataEntries | List of [RadarEntry](#radarentry) | `[]` |
| fillColor | Dataset fill color | `Colors.black12` |
| fillGradient | Dataset fill gradient | `null` |
| borderColor | Dataset border color | `Colors.blueAccent` |
| borderWidth | Dataset border width | `2.0` |
| entryRadius | Radius of each entry dot | `5.0` |

## RadarEntry

| Property | Description | Default |
|:---------|:-----------|:--------|
| value | Data value for this axis | required |

## RadarTouchData

| Property | Description | Default |
|:---------|:-----------|:--------|
| enabled | Enable/disable touch | `true` |
| mouseCursorResolver | Custom cursor per event | `MouseCursor.defer` |
| touchCallback | `(FlTouchEvent, RadarTouchResponse?) → void` | `null` |
| longPressDuration | Custom long-press duration | `null` |
| touchSpotThreshold | Touch accuracy threshold | `10` |

## RadarTouchResponse

| Property | Description |
|:---------|:-----------|
| touchLocation | Touch position in device pixel coordinates |
| touchedSpot | [RadarTouchedSpot](#radartouchedspot) |

## RadarTouchedSpot

| Property | Description |
|:---------|:-----------|
| touchedDataSet | Touched RadarDataSet |
| touchedDataSetIndex | Index of touched dataset |
| touchedRadarEntry | Touched RadarEntry |
| touchedRadarEntryIndex | Index of touched entry |

## RadarChartTitle

| Property | Description | Default |
|:---------|:-----------|:--------|
| text | Title text | required |
| children | List\<InlineSpan\> for rich text | `null` |
| angle | Rotation angle in degrees | `0` |
| positionPercentageOffset | Title distance (0-1), overrides chart-level setting | `null` |

## Usage Patterns

### Multi-Dataset Overlay

Stack multiple `RadarDataSet` to compare groups:

```dart
RadarChartData(
  dataSets: [
    RadarDataSet(
      dataEntries: [RadarEntry(value: 4), RadarEntry(value: 3), RadarEntry(value: 5), RadarEntry(value: 2), RadarEntry(value: 4)],
      fillColor: Colors.blue.withValues(alpha: 0.2),
      borderColor: Colors.blue,
      borderWidth: 2,
      entryRadius: 4,
    ),
    RadarDataSet(
      dataEntries: [RadarEntry(value: 3), RadarEntry(value: 4), RadarEntry(value: 2), RadarEntry(value: 5), RadarEntry(value: 3)],
      fillColor: Colors.red.withValues(alpha: 0.2),
      borderColor: Colors.red,
      borderWidth: 2,
      entryRadius: 4,
    ),
  ],
  radarShape: RadarShape.circle,
  tickCount: 4,
  getTitle: (index, angle) => RadarChartTitle(text: ['Speed', 'Power', 'Skill', 'Defense', 'Agility'][index]),
)
```
