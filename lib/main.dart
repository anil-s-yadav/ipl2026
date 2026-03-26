import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:ipl2026/firebase_options.dart';
import 'package:ipl2026/screens/dashboard_screen.dart';
import 'package:ipl2026/screens/login_screen.dart';
import 'package:ipl2026/services/shared_preferences.dart';
import 'package:ipl2026/providers/app_provider.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line
  await LocalStoragePref.instance!.initPrefBox();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final isLoggedIn = LocalStoragePref.instance?.getLoginBool() ?? false;

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IPL Betting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFFF3D00),
          surface: Color(0xFF1A1F38),
        ),
        fontFamily: 'Roboto', // Default fallback, but sets a clean vibe
      ),
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

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF00E5FF).withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF00E5FF),
              );
            }
            return const TextStyle(color: Colors.white54);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF00E5FF), size: 28);
            }
            return const IconThemeData(color: Colors.white54, size: 24);
          }),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF14192A),
          elevation: 0,
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
      ),
    );
  }
}
