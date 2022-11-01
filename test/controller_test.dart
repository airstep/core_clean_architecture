import 'package:core_clean_architecture/core_clean_architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GlobalKey snackBar = GlobalKey();
GlobalKey inc = GlobalKey();

void main() {
  var stateInitialized = false;
  var viewDidChangeViewDependenciesTriggered = false;
  var stateDeactivated = false;
  var numberOfWidgetBuilds = 0;
  var numberOfUncontrolledWidgetBuilds = 0;
  var numberOfControlledWidgetBuilds = 0;

  testWidgets('Controller can change data and refresh View',
      (WidgetTester tester) async {
    final binding = tester.binding;
    await binding.delayed(const Duration(seconds: 3));
    await tester.pumpWidget(MaterialApp(
      home: CounterPage(
        onWidgetBuild: () {
          numberOfWidgetBuilds++;
        },
        onUncontrolledWidgetBuild: () {
          numberOfUncontrolledWidgetBuilds++;
        },
        onControlledWidgetBuild: () {
          numberOfControlledWidgetBuilds++;
        },
        controller: CounterController(
          onViewDeactivated: () {
            stateDeactivated = true;
          },
          onViewDidChangeDependencies: () {
            viewDidChangeViewDependenciesTriggered = true;
          },
          onViewInitState: () {
            stateInitialized = true;
          },
        ),
      ),
    ));

    expect(stateInitialized, isTrue);
    expect(viewDidChangeViewDependenciesTriggered, isTrue);
    // Create our Finders
    var counterFinder = find.text('0');
    expect(counterFinder, findsOneWidget);

    await tester.tap(find.byKey(inc));
    await tester.pump();

    expect(counterFinder, findsNothing);
    counterFinder = find.text('1');
    expect(counterFinder, findsOneWidget);

    await tester.tap(find.byKey(inc));
    await tester.pump();

    expect(counterFinder, findsNothing);
    counterFinder = find.text('2');
    expect(counterFinder, findsOneWidget);

    await tester.tap(find.byKey(snackBar));
    await tester.pump();
    expect(find.text('Hi'), findsOneWidget);

    expect(numberOfWidgetBuilds, equals(1));
    expect(numberOfUncontrolledWidgetBuilds, equals(1));
    expect(numberOfControlledWidgetBuilds, equals(3));

    // To remove page from tree
    await tester.pumpWidget(Container());
    expect(stateDeactivated, isTrue);
  });
}

class CounterController extends Controller {
  CounterController(
      {required this.onViewDidChangeDependencies,
      required this.onViewInitState,
      required this.onViewDeactivated});

  final Function onViewDidChangeDependencies;
  final Function onViewInitState;
  final Function onViewDeactivated;

  late int counter;

  void increment() {
    counter++;
    shake();
  }

  void showSnackBar() {
    final scaffoldState = getState() as ScaffoldState;
    ScaffoldMessenger.of(scaffoldState.context)
        .showSnackBar(const SnackBar(content: Text('Hi')));
  }

  @override
  void initListeners() {
    // No presenter needed for controller test
  }

  @override
  void onInitState() {
    onViewInitState();
  }

  @override
  void onDidChangeDependencies() {
    onViewDidChangeDependencies();
    counter = 0;
  }

  @override
  void onDeactivated() {
    onViewDeactivated();
  }
}

class CounterPage extends View {
  const CounterPage(
      {required this.onWidgetBuild,
      required this.onUncontrolledWidgetBuild,
      required this.onControlledWidgetBuild,
      required this.controller});
  final CounterController controller;
  final Function onWidgetBuild;
  final Function onControlledWidgetBuild;
  final Function onUncontrolledWidgetBuild;

  @override
  State<StatefulWidget> createState() => CounterState(controller: controller);
}

class CounterState extends ViewState<CounterPage, CounterController> {
  CounterState({required CounterController controller}) : super(controller);

  @override
  Widget get view {
    widget.onWidgetBuild();

    return Scaffold(
      key: globalKey,
      body: Column(
        children: <Widget>[
          Center(
            child: Builder(
              builder: (BuildContext context) {
                widget.onUncontrolledWidgetBuild();

                return const Text('Uncontrolled text');
              },
            ),
          ),
          Center(
            child: ControlledWidgetBuilder<CounterController>(
              builder: (ctx, controller) {
                widget.onControlledWidgetBuild();

                return Text(controller.counter.toString());
              },
            ),
          ),
          ControlledWidgetBuilder<CounterController>(
            builder: (ctx, controller) => MaterialButton(
                key: inc, onPressed: () => controller.increment()),
          ),
          ControlledWidgetBuilder<CounterController>(
            builder: (ctx, controller) => MaterialButton(
                key: snackBar, onPressed: () => controller.showSnackBar()),
          ),
        ],
      ),
    );
  }
}
