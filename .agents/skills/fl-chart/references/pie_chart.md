# PieChart API Reference

## PieChartData

| Property | Description | Default |
|:---------|:-----------|:--------|
| sections | List of [PieChartSectionData](#piechartsectiondata) | `[]` |
| centerSpaceRadius | Free space in center; `double.infinity` = auto-calculated from view size; `0` = full pie | `double.nan` |
| centerSpaceColor | Color of center space | `Colors.transparent` |
| sectionsSpace | Margin between sections (not supported on html-renderer) | `2` |
| startDegreeOffset | Degree offset for section rotation (0-360) | `0` |
| pieTouchData | [PieTouchData](#pietouchdata) | `PieTouchData()` |
| borderData | [FlBorderData](./base_chart.md#flborderdata) | `FlBorderData()` |
| titleSunbeamLayout | Rotate titles tangent to each section | `false` |

## PieChartSectionData

| Property | Description | Default |
|:---------|:-----------|:--------|
| value | Weight of section (proportional to total) | `10` |
| color | Section color | `Colors.red` |
| gradient | Gradient fill (provide either `color` or `gradient`) | `null` |
| radius | Width/radius of the section | `40` |
| showTitle | Show/hide title on section | `true` |
| titleStyle | TextStyle for title | `TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)` |
| title | Title text | value as string |
| borderSide | Border stroke around section | `BorderSide(width: 0)` |
| cornerRadius | Rounded section edges | `0` |
| badgeWidget | Badge widget on section | `null` |
| titlePositionPercentageOffset | Title position within section (0-1) | `0.5` |
| badgePositionPercentageOffset | Badge position within section (0-1) | `0.5` |

## PieTouchData

| Property | Description | Default |
|:---------|:-----------|:--------|
| enabled | Enable/disable touch | `true` |
| mouseCursorResolver | Custom cursor per event | `MouseCursor.defer` |
| touchCallback | `(FlTouchEvent, PieTouchResponse?) → void` | `null` |
| longPressDuration | Custom long-press duration | `null` |

## PieTouchResponse

| Property | Description |
|:---------|:-----------|
| touchLocation | Touch position in device pixel coordinates |
| touchedSection | [PieTouchedSection](#pietouchedsection) |

## PieTouchedSection

| Property | Description |
|:---------|:-----------|
| touchedSection | The touched PieChartSectionData |
| touchedSectionIndex | Index of touched section |
| touchAngle | Angle of touch |
| touchRadius | Radius of touch |

## Usage Patterns

### Donut Chart

Set `centerSpaceRadius` > 0:

```dart
PieChartData(
  centerSpaceRadius: 50,
  sections: [...],
)
```

### Interactive Expansion on Touch

```dart
int touchedIndex = -1;

PieChart(
  PieChartData(
    pieTouchData: PieTouchData(
      touchCallback: (FlTouchEvent event, pieTouchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions || pieTouchResponse?.touchedSection == null) {
            touchedIndex = -1;
            return;
          }
          touchedIndex = pieTouchResponse!.touchedSection!.touchedSectionIndex;
        });
      },
    ),
    sections: List.generate(data.length, (i) {
      final isTouched = i == touchedIndex;
      return PieChartSectionData(
        value: data[i],
        radius: isTouched ? 60 : 50,
        titleStyle: TextStyle(fontSize: isTouched ? 18 : 14, color: Colors.white),
      );
    }),
  ),
)
```
