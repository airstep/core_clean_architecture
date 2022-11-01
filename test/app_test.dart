import 'package:core_clean_architecture/core_clean_architecture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:responsive_builder/responsive_builder.dart';

void main() {
  testWidgets('Clean Architecture App init', (WidgetTester tester) async {
    // final binding = tester.binding;
    expect(Logger.root.level, Level.INFO);
    CleanArchitectureApp.debugModeOn();
    expect(Logger.root.level, Level.ALL);

    expect(ResponsiveSizingConfig.instance.breakpoints.desktop == 1000, false);
    expect(ResponsiveSizingConfig.instance.breakpoints.tablet == 700, false);
    expect(ResponsiveSizingConfig.instance.breakpoints.tablet == 250, false);

    CleanArchitectureApp.setDefaultViewBreakpoints(
      desktopBreakpointMinimumWidth: 1000,
      tabletBreakpointMinimumWidth: 700,
      watchBreakpointMinimumWidth: 250,
    );

    expect(ResponsiveSizingConfig.instance.breakpoints.desktop == 1000, true);
    expect(ResponsiveSizingConfig.instance.breakpoints.tablet == 700, true);
    expect(ResponsiveSizingConfig.instance.breakpoints.watch == 250, true);
  });
}
