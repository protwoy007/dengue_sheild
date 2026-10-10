import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import "providers/app_provider.dart";
import "theme/app_theme.dart";
import "screens/splash_screen.dart";
import "screens/main_shell.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const _App(),
    ),
  );
}

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) {
    final mode = context.select<AppProvider, ThemeMode>((p) => p.themeMode);
    return MaterialApp(
      title: "DengueShield BD",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(false),
      darkTheme: AppTheme.build(true),
      themeMode: mode,
      builder: (context, child) => _ThemeSync(child: child ?? const SizedBox.shrink()),
      initialRoute: "/",
      routes: {
        "/": (_) => const SplashScreen(),
        "/home": (_) => const MainShell(),
      },
    );
  }
}

/// Keeps [AppColors.dark] in sync with the effective brightness and forces the
/// whole widget tree to rebuild when it flips (many widgets read AppColors
/// directly, so they would not otherwise notice a theme change).
class _ThemeSync extends StatefulWidget {
  final Widget child;
  const _ThemeSync({required this.child});
  @override
  State<_ThemeSync> createState() => _ThemeSyncState();
}

class _ThemeSyncState extends State<_ThemeSync> {
  bool? _lastDark;

  void _rebuildAll() {
    if (!mounted) return;
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AppProvider>().themeMode;
    final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final dark = mode == ThemeMode.dark || (mode == ThemeMode.system && systemDark);

    AppColors.dark = dark; // set before the subtree below builds
    if (_lastDark != null && _lastDark != dark) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll());
    }
    _lastDark = dark;
    return widget.child;
  }
}
