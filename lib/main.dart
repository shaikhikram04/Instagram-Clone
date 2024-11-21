import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/responsive/mobile_screen_layout.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/responsive/web_screen_layout.dart';
import 'package:instagram_clone/screens/authentication/authentication_screen.dart';
import 'package:instagram_clone/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  try {
    if (kIsWeb) {
      print('Initializing Firebase for Web');
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyAJh7L-6GM5H5drP6NFPKZnXGI5qplX_fk",
          authDomain: "instagram-clone-a88dc.firebaseapp.com",
          projectId: "instagram-clone-a88dc",
          storageBucket: "instagram-clone-a88dc.appspot.com",
          messagingSenderId: "192984819589",
          appId: "1:192984819589:web:b554929c5132929396c6ec",
        ),
        name: '[DEFAULT]',
      );
      print('Firebase Web Initialization Successful');
    } else {
      await Firebase.initializeApp();
    }
  } catch (e, stackTrace) {
    print('Firebase Initialization Error: $e');
    print('Stack Trace: $stackTrace');
    rethrow;
  }

  FirebaseMessaging.onBackgroundMessage(
    _backgroungMessagingHandler,
  );

  runApp(const ProviderScope(
    child: MyApp(),
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
