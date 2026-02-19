import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'firebase_options.dart';

import 'pages/login_page.dart';
import 'layout/main_scaffold.dart';
import 'pages/buy_items_page.dart';
import 'pages/items_basket_page.dart';
import 'pages/user_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}
/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Siu',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: (settings) {
        switch (settings.name) {

          case '/login':
            return MaterialPageRoute(
              builder: (_) => LoginPage(),
            );

          case '/buy-items':
            return MaterialPageRoute(
              builder: (_) => MainScaffold(child: BuyItemsPage()),
            );

          case '/items-basket':
            return MaterialPageRoute(
              builder: (_) => MainScaffold(child: ItemsBasketPage()),
            );

          case '/user-profile':
            return MaterialPageRoute(
              builder: (_) => MainScaffold(child: UserProfilePage()),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => MainScaffold(child: BuyItemsPage()),
            );
        }
      },
    );
  }
}
*/

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Siu',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/login': (_) => LoginPage(),
        '/': (_) => const MainScaffold(),
      },
    );
  }
}