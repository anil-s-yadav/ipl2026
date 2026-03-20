import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ipl2026/firebase_options.dart';
import 'package:ipl2026/screens/dashboard_screen.dart';
import 'package:ipl2026/screens/login_screen.dart';
import 'package:ipl2026/services/shared_preferences.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  await LocalStoragePref.instance!.initPrefBox();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final isLoggedIn = LocalStoragePref.instance?.getLoginBool() ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPL Betting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final pages = [const HomeScreen(), const DashboardScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_cricket),
            label: "Matches",
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
        ],
      ),
    );
  }
}
