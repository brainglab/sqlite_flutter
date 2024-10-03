import 'package:sqlite_flutter/src/custom/library.dart';
import 'package:sqlite_flutter/src/handlers/sqlite_handler.dart';
import 'package:sqlite_flutter/src/pages/splash_page.dart';
import 'package:sqlite_flutter/src/providers/global_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Provides access to the sqlite Store throughout the app.
late SqliteHandler mSqliteHandler;

Future<void> main() async {
  // esto requiere para la base de datos
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        navigatorObservers: [mRouteObserver],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashPage());
  }
}
