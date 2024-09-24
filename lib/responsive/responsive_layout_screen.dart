import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_method.dart';
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
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        addData();
      },
    );
  }

  void addData() async {
    final user = await AuthMethod().getUserDetail();
    ref.read(userProvider.notifier).setUser(user);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenSize) {
          //* web screen
          return widget.webScreenLayout;
        }
        //* mobile screen
        return widget.mobileScreenLayout;
      },
    );
  }
}
