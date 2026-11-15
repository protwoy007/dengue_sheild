import "package:flutter/gestures.dart";
import "package:flutter/material.dart";

/// Layout breakpoints. Phones keep the original mobile layout untouched.
class Responsive {
  static const double tablet = 700;
  static const double desktop = 1000;

  static bool isTablet(BuildContext c) => MediaQuery.sizeOf(c).width >= tablet;
  static bool isDesktop(BuildContext c) => MediaQuery.sizeOf(c).width >= desktop;

  /// Horizontal padding that centres a [maxWidth] column inside [width].
  static double sidePad(double width, double maxWidth) =>
      width > maxWidth ? (width - maxWidth) / 2 : 0;
}

/// Drop-in replacement for [Scaffold] on text/list screens: the app bar stays
/// full width but the body is centred in a readable column on wide screens.
class ResponsiveScaffold extends StatelessWidget {
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final double maxWidth;
  const ResponsiveScaffold({
    super.key,
    this.backgroundColor,
    this.appBar,
    required this.body,
    this.maxWidth = 820,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar,
        body: Center(
          child: SizedBox(width: maxWidth, height: double.infinity, child: body),
        ),
      );
}

/// Lets mouse / trackpad drag-scroll and pull-to-refresh work on web & desktop.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
