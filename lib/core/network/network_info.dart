import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

abstract class NetworkInfo {
  bool get isConnected;
  RxBool get isConnectedRx;
  Stream<bool> get onConnectivityChanged;
  void setSimulatedOffline(bool offline);
  bool get isSimulatedOffline;
  void toggleOffline();
}

class NetworkInfoImpl extends GetxService implements NetworkInfo {
  final Connectivity _connectivity;
  final RxBool _isDeviceOnline = true.obs;
  final RxBool _isSimulatedOffline = false.obs;

  @override
  final RxBool isConnectedRx = true.obs;

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
      _handleConnectivityResults(results);
    } catch (_) {
      // In tests or mock environments without platform channel
      _syncStatus();
    }

    _subscription = _connectivity.onConnectivityChanged.listen(_handleConnectivityResults);
  }

  void _handleConnectivityResults(List<ConnectivityResult> results) {
    final hasActiveNetwork = results.isNotEmpty &&
        results.any((result) => result != ConnectivityResult.none);

    _isDeviceOnline.value = hasActiveNetwork;
    _syncStatus();
  }

  void _syncStatus() {
    final connected = _isDeviceOnline.value && !_isSimulatedOffline.value;
    isConnectedRx.value = connected;
  }

  @override
  bool get isSimulatedOffline => _isSimulatedOffline.value;

  @override
  bool get isConnected => isConnectedRx.value;

  @override
  Stream<bool> get onConnectivityChanged => isConnectedRx.stream;

  @override
  void setSimulatedOffline(bool offline) {
    _isSimulatedOffline.value = offline;
    _syncStatus();
  }

  @override
  void toggleOffline() {
    _isSimulatedOffline.value = !_isSimulatedOffline.value;
    _syncStatus();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
