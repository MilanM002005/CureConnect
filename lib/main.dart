import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/nearby_hospitals_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/blood_availability_screen.dart';
import 'screens/donor_details_screen.dart';
import 'screens/blood_donation_camps_screen.dart';
import 'screens/blood_chart_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Load theme preferences
  final themeProvider = ThemeProvider();
  await themeProvider.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeProvider),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const CureConnectApp(),
    ),
  );
}

class CureConnectApp extends StatelessWidget {
  const CureConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CureConnect',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/nearby': (context) => const NearbyHospitalsScreen(selectedHospital: {},),
        '/emergency': (context) => const EmergencyScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/emergency_contacts': (context) => const EmergencyContactsScreen(),
        '/blood_availability': (context) => const BloodAvailabilityScreen(),
        '/donor_details': (context) {
          final donorArgs = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DonorDetailsScreen(donor: donorArgs['donor'], donorId: donorArgs['donorId']);
        }, // ✅ Corrected passing donor data
        '/blood_camps': (context) => const BloodDonationCampsScreen(),
        '/blood_chart': (context) => const BloodChartScreen(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/donor_details') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DonorDetailsScreen(
              donorId: args['donorId'], // ✅ Ensure donorId is passed
              donor: args['donor'], // ✅ Ensure donor data is passed
            ),
          );
        }
        return null;
      },
    );
  }
}

// ✅ ThemeProvider Class Implementation
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}
