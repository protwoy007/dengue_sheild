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
    return MaterialApp(
      title: "DengueShield BD",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: "/",
      routes: {
        "/": (_) => const SplashScreen(),
        "/home": (_) => const MainShell(),
      },
    );
  }
}
