import 'package:core_clean_architecture/src/controller.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

/// Clean Architecture App instance
class CleanArchitectureApp {
  /// Retrieves a Controller from the widget tree if one exists
  /// Can be used in widgets that exist in pages and need
  /// to use the same controller
  static AnyController controller<AnyController extends Controller>(
    BuildContext context, {
    bool listen = true,
  }) =>
      Provider.of<AnyController>(context, listen: listen);

  /// Enable customize default view breakpoints.
  /// To do so, just call it before `runApp`.
  ///
  /// ```dart
  /// void main() {
  //    App.setDefaultViewBreakpoints(
  //      desktopBreakpointMinimumWidth: 1000,
  //      tabletBreakpointMinimumWidth: 700,
  //      watchBreakpointMinimumWidth: 250,
  //    );
  //    runApp(MyApp());
  //  }
  /// ```
  static void setDefaultViewBreakpoints({
    required double desktopBreakpointMinimumWidth,
    required double tabletBreakpointMinimumWidth,
    required double watchBreakpointMinimumWidth,
  }) {
    ResponsiveSizingConfig.instance.setCustomBreakpoints(
      ScreenBreakpoints(
          desktop: desktopBreakpointMinimumWidth,
          tablet: tabletBreakpointMinimumWidth,
          watch: watchBreakpointMinimumWidth),
    );
  }

  /// Enables logging inside the `CoreCleanArchitecture` package,
  static void debugModeOn() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.loggerName}: ${record.level.name}: ${record.message} ');
      if (record.error != null) {
        print(record.error.toString());
      }
    });

    Logger.root.info('Logger initialized.');
  }
}
