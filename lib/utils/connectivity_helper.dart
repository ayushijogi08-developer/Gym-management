import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();

  static Stream<ConnectivityResult> get onConnectivityChanged => 
      _connectivity.onConnectivityChanged;

  static Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}