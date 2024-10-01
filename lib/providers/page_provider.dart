import 'package:flutter_riverpod/flutter_riverpod.dart';

class PageNotifier extends StateNotifier<int> {
  PageNotifier() : super(0);

  void setPage(int page) {
    state = page;
  }
}

final pageProvider = StateNotifierProvider(
  (ref) => PageNotifier(),
);
