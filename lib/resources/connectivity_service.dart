import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final connectivityStreamController = StreamController<ConnectivityResult>();

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen(
      (result) {
        final res = result.last;
        connectivityStreamController.add(res);
      },
    );
  }

  void dispose() {
    connectivityStreamController.close();
  }
}
