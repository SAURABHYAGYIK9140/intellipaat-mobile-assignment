import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

abstract class NetworkInfo {
  bool get isConnected;
  Stream<bool> get onConnectivityChanged;
  void setSimulatedOffline(bool offline);
  bool get isSimulatedOffline;
  void toggleOffline();
}

class NetworkInfoImpl extends GetxService implements NetworkInfo {
  final Connectivity _connectivity;
  final RxBool _isDeviceOnline = true.obs;
  final RxBool _isSimulatedOffline = false.obs;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionState(results);
    } catch (_) {
      // In testing environments or unsupported platforms, assume connected
      _isDeviceOnline.value = true;
      _connectivityController.add(isConnected);
    }

    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionState);
  }

  void _updateConnectionState(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );

    _isDeviceOnline.value = hasConnection;
    _connectivityController.add(isConnected);
  }

  @override
  bool get isSimulatedOffline => _isSimulatedOffline.value;

  @override
  bool get isConnected => _isDeviceOnline.value && !_isSimulatedOffline.value;

  @override
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  @override
  void setSimulatedOffline(bool offline) {
    _isSimulatedOffline.value = offline;
    _connectivityController.add(isConnected);
  }

  @override
  void toggleOffline() {
    _isSimulatedOffline.value = !_isSimulatedOffline.value;
    _connectivityController.add(isConnected);
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _connectivityController.close();
    super.onClose();
  }
}
