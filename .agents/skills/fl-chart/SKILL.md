---
name: "implementing-fl-chart"
description: "Implements data visualization charts in Flutter using the fl_chart package (v1.2.0). Supports LineChart, BarChart, PieChart, ScatterChart, RadarChart, and CandlestickChart with implicit animations, touch interactivity, and pan/zoom transformations. Use when building any Flutter chart, graph, or data visualization — including line graphs for trends, bar charts for comparisons, pie/donut charts for proportions, scatter plots for distributions, radar charts for multi-axis comparisons, or candlestick charts for financial OHLC data. Also use when customizing chart axes, titles, tooltips, grid lines, touch callbacks, chart animations, or chart zoom/pan behavior."
metadata:
  last_modified: "2026-04-02 17:12:00 (GMT+8)"
---

# FL Chart — Flutter Data Visualization (v1.2.0)

## Goal

Production-ready chart rendering in Flutter with implicit animations, touch interactivity, and pan/zoom transformations. Supports 6 chart types covering most data visualization needs.

## Process

### 1. Install

```yaml
dependencies:
  fl_chart: ^1.2.0
```

Requires Flutter >=3.27.4, Dart SDK >=3.6.2.

### 2. Choose Chart Type

| Chart | Widget | Use Case |
|-------|--------|----------|
| **Line** | `LineChart` | Trends over time, continuous data, multi-series comparison |
| **Bar** | `BarChart` | Category comparison, grouped/stacked bars, horizontal bars |
| **Pie** | `PieChart` | Proportions, donut charts, percentage breakdowns |
| **Scatter** | `ScatterChart` | Distribution, correlation, cluster analysis |
| **Radar** | `RadarChart` | Multi-axis comparison, skill profiles, feature ratings |
| **Candlestick** | `CandlestickChart` | Financial OHLC data, stock price visualization |

### 3. Quick Start — Each Chart Type

#### LineChart

```dart
// Multi-series line chart with gradient fill
LineChart(
  LineChartData(
    minX: 0, maxX: 6, minY: 0, maxY: 25,
    lineBarsData: [
      LineChartBarData(
        spots: [FlSpot(0, 12), FlSpot(1, 9), FlSpot(2, 15), FlSpot(3, 11), FlSpot(4, 18), FlSpot(5, 21), FlSpot(6, 18)],
        isCurved: true,
        color: Colors.green,
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.green.withValues(alpha: 0.3), Colors.green.withValues(alpha: 0.0)],
          ),
        ),
      ),
      LineChartBarData(
        spots: [FlSpot(0, 8), FlSpot(1, 6), FlSpot(2, 9), FlSpot(3, 13), FlSpot(4, 7), FlSpot(5, 11), FlSpot(6, 9)],
        isCurved: true,
        color: Colors.redAccent,
        barWidth: 3,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.redAccent.withValues(alpha: 0.3), Colors.redAccent.withValues(alpha: 0.0)],
          ),
        ),
      ),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    gridData: FlGridData(show: true),
    borderData: FlBorderData(show: true),
  ),
)
```

#### BarChart

```dart
BarChart(
  BarChartData(
    barGroups: [
      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 16)]),
      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blue, width: 16)]),
      BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 6, color: Colors.blue, width: 16)]),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(['Mon', 'Tue', 'Wed'][value.toInt()]),
        ),
      ),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
  ),
)
```

#### PieChart

```dart
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(value: 40, color: Colors.blue, title: '40%', radius: 50),
      PieChartSectionData(value: 30, color: Colors.orange, title: '30%', radius: 50),
      PieChartSectionData(value: 20, color: Colors.green, title: '20%', radius: 50),
      PieChartSectionData(value: 10, color: Colors.red, title: '10%', radius: 50),
    ],
    centerSpaceRadius: 40, // 0 for full pie, >0 for donut
    sectionsSpace: 2,
  ),
)
```

#### ScatterChart

```dart
ScatterChart(
  ScatterChartData(
    scatterSpots: [
      ScatterSpot(1, 2, dotPainter: FlDotCirclePainter(radius: 6, color: Colors.blue)),
      ScatterSpot(3, 5, dotPainter: FlDotCirclePainter(radius: 8, color: Colors.red)),
      ScatterSpot(5, 3, dotPainter: FlDotCirclePainter(radius: 5, color: Colors.green)),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
  ),
)
```

#### RadarChart

```dart
RadarChart(
  RadarChartData(
    dataSets: [
      RadarDataSet(
        dataEntries: [RadarEntry(value: 4), RadarEntry(value: 3), RadarEntry(value: 5), RadarEntry(value: 2), RadarEntry(value: 4)],
        fillColor: Colors.blue.withValues(alpha: 0.2),
        borderColor: Colors.blue,
        borderWidth: 2,
      ),
    ],
    radarShape: RadarShape.circle,
    tickCount: 4,
    titlePositionPercentageOffset: 0.2,
    getTitle: (index, angle) => RadarChartTitle(text: ['Speed', 'Power', 'Skill', 'Defense', 'Agility'][index]),
  ),
)
```

#### CandlestickChart

```dart
CandlestickChart(
  CandlestickChartData(
    candlestickSpots: [
      CandlestickSpot(x: 0, open: 10, high: 15, low: 8, close: 13),
      CandlestickSpot(x: 1, open: 13, high: 16, low: 11, close: 12),
      CandlestickSpot(x: 2, open: 12, high: 18, low: 10, close: 17),
    ],
    titlesData: FlTitlesData(
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
  ),
)
```

### 4. Common Configuration (All Axis Charts)

#### Titles & Axis Labels

All axis-based charts (Line, Bar, Scatter, Candlestick) share `FlTitlesData`:

```dart
titlesData: FlTitlesData(
  bottomTitles: AxisTitles(
    axisNameWidget: Text('Month'),  // axis label
    axisNameSize: 16,
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: 1,        // show a title every 1 unit
      getTitlesWidget: (value, meta) {
        // Return custom widget for each axis value
        return SideTitleWidget(
          meta: meta,
          child: Text(value.toInt().toString()),
        );
      },
    ),
  ),
  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
),
```

#### Grid Lines

```dart
gridData: FlGridData(
  show: true,
  drawHorizontalLine: true,
  drawVerticalLine: false,
  horizontalInterval: 2,
  getDrawingHorizontalLine: (value) => FlLine(
    color: Colors.grey.withValues(alpha: 0.3),
    strokeWidth: 1,
    dashArray: [5, 5],
  ),
),
```

#### Border

```dart
borderData: FlBorderData(
  show: true,
  border: Border(
    bottom: BorderSide(color: Colors.black, width: 1),
    left: BorderSide(color: Colors.black, width: 1),
    right: BorderSide.none,
    top: BorderSide.none,
  ),
),
```

#### Extra Lines (Thresholds / Reference Lines)

```dart
extraLinesData: ExtraLinesData(
  horizontalLines: [
    HorizontalLine(
      y: 75,
      color: Colors.red,
      strokeWidth: 2,
      dashArray: [8, 4],
      label: HorizontalLineLabel(show: true, labelResolver: (line) => 'Target: ${line.y}'),
    ),
  ],
),
```

### 5. Touch Interactivity

Every chart has a touch data config. Built-in tooltip display is enabled by default:

```dart
// LineChart example
lineTouchData: LineTouchData(
  enabled: true,
  handleBuiltInTouches: true,
  touchTooltipData: LineTouchTooltipData(
    getTooltipColor: (spot) => Colors.blueGrey.withValues(alpha: 0.8),
    getTooltipItems: (touchedSpots) {
      return touchedSpots.map((spot) {
        return LineTooltipItem(
          '${spot.y.toStringAsFixed(1)}',
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      }).toList();
    },
  ),
  touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlTapUpEvent && response?.lineBarSpots != null) {
      // Handle tap on data point
    }
  },
),
```

Set `handleBuiltInTouches: false` to fully custom-handle touch events via `touchCallback`.

### 6. Implicit Animations

All charts animate automatically when data changes. Control via `duration` and `curve`:

```dart
LineChart(
  LineChartData(...),
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)
```

Set `duration: Duration.zero` to disable animations.

### 7. Pan & Zoom (Transformations)

Enable scaling/panning on axis charts (Line, Bar, Scatter):

```dart
LineChart(
  LineChartData(...),
  transformationConfig: FlTransformationConfig(
    scaleAxis: FlScaleAxis.horizontal,  // .horizontal, .vertical, .free, .none
    minScale: 1.0,
    maxScale: 5.0,
  ),
)
```

For programmatic zoom control, supply a `TransformationController`:

```dart
final controller = TransformationController();

LineChart(
  LineChartData(...),
  transformationConfig: FlTransformationConfig(
    scaleAxis: FlScaleAxis.horizontal,
    minScale: 1.0,
    maxScale: 25.0,
    transformationController: controller,
  ),
)

// Zoom in programmatically
controller.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
// Reset
controller.value = Matrix4.identity();
```

> ⚠️ BarChart with `alignment: .center/.start/.end` does not support horizontal scaling.

### 8. Stacked Bar Chart

```dart
BarChart(
  BarChartData(
    barGroups: [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(toY: 70, width: 20, borderRadius: BorderRadius.circular(4), rodStackItem: [
          BarChartRodStackItem(0, 20, Colors.blue),    // Q1
          BarChartRodStackItem(20, 50, Colors.orange),  // Q2
          BarChartRodStackItem(50, 70, Colors.green),   // Q3
        ]),
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(toY: 75, width: 20, borderRadius: BorderRadius.circular(4), rodStackItem: [
          BarChartRodStackItem(0, 30, Colors.blue),
          BarChartRodStackItem(30, 55, Colors.orange),
          BarChartRodStackItem(55, 75, Colors.green),
        ]),
      ]),
    ],
    barTouchData: BarTouchData(
      touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
        // response?.spot?.touchedStackItemIndex gives the tapped layer index
        // response?.spot?.touchedStackItem gives the BarChartRodStackItem
      },
      touchTooltipData: BarTouchTooltipData(
        getTooltipItems: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem('Total: ${rod.toY.toInt()}', const TextStyle(color: Colors.white));
        },
      ),
    ),
  ),
)
```

> `touchedStackItemIndex` on `BarTouchedSpot` identifies which layer was tapped (-1 if none).

### 9. Horizontal Bar Chart

Rotate any axis chart by setting `rotationQuarterTurns`:

```dart
BarChart(
  BarChartData(
    rotationQuarterTurns: 1, // 90° clockwise
    barGroups: [...],
  ),
)
```

## Reference Documentation

Each chart has a full API reference with all properties, defaults, and data classes:

- [LineChart API](./references/line_chart.md) — LineChartData, LineChartBarData, BetweenBarsData, BarAreaData, FlDotData, LineTouchData, step line charts
- [BarChart API](./references/bar_chart.md) — BarChartGroupData, BarChartRodData, stacked bars, rod labels, BarTouchData
- [PieChart API](./references/pie_chart.md) — PieChartSectionData, badges, corner radius, PieTouchData
- [ScatterChart API](./references/scatter_chart.md) — ScatterSpot, dot painters, labels, ScatterTouchData
- [RadarChart API](./references/radar_chart.md) — RadarDataSet, RadarEntry, titles, shapes, RadarTouchData
- [CandlestickChart API](./references/candlestick_chart.md) — CandlestickSpot (OHLC), custom painters, CandlestickTouchData
- [Base / Shared Components](./references/base_chart.md) — FlTitlesData, SideTitles, FlGridData, FlBorderData, FlSpot, FlLine, ExtraLinesData, RangeAnnotations, FlTouchEvent, error indicators

## Constraints

* **Version**: fl_chart ^1.2.0. API tables in references reflect this version.
* **Import**: `import 'package:fl_chart/fl_chart.dart';` — single import for all chart types.
* **PieChart padding**: If wrapping PieChart in a padding widget, set `centerSpaceRadius: double.infinity` to prevent layout issues.
* **Axis bounds**: Explicitly providing `minX/maxX/minY/maxY` improves performance over auto-calculation from data.
* **BarChart vertical lines**: `ExtraLinesData.verticalLines` are ignored in BarChart — use horizontal lines only.
* **Equatable**: fl_chart depends on `equatable` — no need to add it separately.
