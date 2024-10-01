import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageControllerNotifier extends StateNotifier<int> {
  PageControllerNotifier() : super(0);

  void navigateTo(int page) {
    state = page;
  }
}

final pageControllerProvider = StateNotifierProvider<PageControllerNotifier, int>(
  (ref) => PageControllerNotifier(),
);
