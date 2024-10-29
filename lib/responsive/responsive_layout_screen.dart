import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_method.dart';
import 'package:instagram_clone/resources/connectivity_service.dart';
import 'package:instagram_clone/resources/firestore_method.dart';
import 'package:instagram_clone/resources/messaging_method.dart';
import 'package:instagram_clone/utils/global_variables.dart';

class ResponsiveLayout extends ConsumerStatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout({
    super.key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  ConsumerState<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends ConsumerState<ResponsiveLayout> {
  final _connectivityService = ConnectivityService();
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();

    _subscription =
        _connectivityService.connectivityStreamController.stream.listen(
      (result) {
        setState(() {
          _hasInternet = (result != ConnectivityResult.none);
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        addData();
      },
    );

    MessagingMethod.requestNotificationPermission();
    MessagingMethod.firebaseInit(context);
    MessagingMethod.setupInteractMessage(context);
  }

  void addData() async {
    final user = await AuthMethod.getUserDetail();
    final token = await MessagingMethod.deviceToken;

    //* token not matched with current device token
    if (token != null && user.deviceToken != token) {
      //* update token
      FirestoreMethod.updateDeviceToken(user.uid, token);
      user.setDeviceToken = token;
    }

    if (!mounted) return;
    ref.read(userProvider.notifier).setUser(user);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasInternet
        ? LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > webScreenSize) {
                //* web screen
                return widget.webScreenLayout;
              }
              //* mobile screen
              return widget.mobileScreenLayout;
            },
          )
        : _buildOfflineScreen();
  }

  Widget _buildOfflineScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 100,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 24,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
