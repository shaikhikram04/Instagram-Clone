import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/authentication/authentication_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

import 'firebase_options.dart';

void main() async {
  await dotenv.load(); //* Load the .env file

  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  FirebaseMessaging.onBackgroundMessage(
    _backgroungMessagingHandler,
  );

  runApp(DevicePreview(
    backgroundColor: Colors.white,

    // Enable preview by default for web demo
    enabled: true,

    // Start with Galaxy A50 as it's a common Android device
    defaultDevice: Devices.android.samsungGalaxyS20,

    // Show toolbar to let users test different devices
    isToolbarVisible: true,

    // Keep English only to avoid confusion in demos
    availableLocales: const [Locale('en', 'US')],

    // Customize preview controls
    tools: const [
      // Device selection controls
      DeviceSection(
        model: true, // Option to change device model to fit your needs
        orientation: false, // Lock to portrait for consistent demo
        frameVisibility: false, // Hide frame options
        virtualKeyboard: false, // Hide keyboard
      ),

      // Theme switching section
      // SystemSection(
      //   locale: false, // Hide language options - we're keeping it English only
      //   theme: false, // Show theme switcher if your app has dark/light modes
      // ),

      // Disable accessibility for demo simplicity
      // AccessibilitySection(
      //   boldText: false,
      //   invertColors: false,
      //   textScalingFactor: false,
      //   accessibleNavigation: false,
      // ),

      // Hide extra settings to keep demo focused
      // SettingsSection(
      //   backgroundTheme: false,
      //   toolsTheme: false,
      // ),
    ],

    // Curated list of devices for comprehensive preview
    devices: [
      // ... Devices.all, // uncomment to see all devices

      // Popular Android Devices
      Devices.android.samsungGalaxyA50, // Mid-range
      Devices.android.samsungGalaxyNote20, // Large screen
      Devices.android.samsungGalaxyS20, // Flagship
      Devices.android.samsungGalaxyNote20Ultra, // Premium
      Devices.android.onePlus8Pro, // Different aspect ratio
      Devices.android.sonyXperia1II, // Tall screen
      Devices.android.onePlus8Pro,
      Devices.android.mediumPhone,
      Devices.android.smallPhone,

      // Popular iOS Devices
      Devices.ios.iPhoneSE, // Small screen
      Devices.ios.iPhone12, // Standard size
      Devices.ios.iPhone12Mini, // Compact
      Devices.ios.iPhone12ProMax, // Large
      Devices.ios.iPhone13, // Latest standard
      Devices.ios.iPhone13ProMax, // Latest large
      Devices.ios.iPhone13Mini, // Latest compact
      Devices.ios.iPhoneSE, // Budget option
    ],
    builder: (BuildContext context) => const ProviderScope(child: MyApp()),
  ));
}

@pragma('vm:entry-point')
Future<void> _backgroungMessagingHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram Clone',
      locale: DevicePreview.locale(context), // add this line
      builder: DevicePreview.appBuilder, // add this line
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
        colorScheme: const ColorScheme.dark(primary: blueColor),
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: mobileBackgroundColor,
          foregroundColor: primaryColor,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return const ResponsiveLayout(
                webScreenLayout: WebScreenLayout(),
                mobileScreenLayout: MobileScreenLayout(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return const AuthenticationScreen();
        },
      ),
    );
  }
}
