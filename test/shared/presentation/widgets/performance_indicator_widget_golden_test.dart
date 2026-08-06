import 'package:alchemist/alchemist.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/performance_indicator_widget.dart';
import 'package:flutter/material.dart';

import 'golden_utils.dart';

/// Golden references for the variation indicator (issue #35). The three signs
/// drive three different colours and arrows, so each is captured — in light and
/// dark. The arrows are real icon glyphs (only text is obscured), so a wrong
/// arrow or colour is caught.
void main() {
  lightDarkGoldenTest(
    'PerformanceIndicatorWidget',
    'performance_indicator',
    () => GoldenTestGroup(
      columns: 3,
      children: [
        GoldenTestScenario(
          name: 'positive',
          child: goldenScenarioSurface(
            const Center(child: PerformanceIndicatorWidget(value: 2.4567)),
            width: 280,
          ),
        ),
        GoldenTestScenario(
          name: 'negative',
          child: goldenScenarioSurface(
            const Center(child: PerformanceIndicatorWidget(value: -1.8321)),
            width: 280,
          ),
        ),
        GoldenTestScenario(
          name: 'zero',
          child: goldenScenarioSurface(
            const Center(child: PerformanceIndicatorWidget(value: 0)),
            width: 280,
          ),
        ),
      ],
    ),
  );
}
