import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

abstract class NetworkInfo {
  bool get isConnected;
  RxBool get isConnectedRx;
  Stream<bool> get onConnectivityChanged;
  void setSimulatedOffline(bool offline);
  bool get isSimulatedOffline;
  void toggleOffline();
  Future<bool> checkRealConnectivity();
}

class NetworkInfoImpl extends GetxService implements NetworkInfo {
  final Connectivity _connectivity;
  final RxBool _isDeviceOnline = true.obs;
  final RxBool _isSimulatedOffline = false.obs;

  @override
  final RxBool isConnectedRx = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollingTimer;

  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  void _startMonitoring() {
    // 1. Initial immediate check
    checkRealConnectivity();

    // 2. Listen to OS-level connectivity events
    try {
      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        final hasActiveInterface = results.isNotEmpty &&
            results.any((result) => result != ConnectivityResult.none);
        
        if (!hasActiveInterface) {
          _isDeviceOnline.value = false;
          _syncStatus();
        } else {
          // Verify actual internet reachability
          checkRealConnectivity();
        }
      });
    } catch (_) {}

    // 3. Periodic lightweight heartbeat check every 2.5 seconds
    // Guarantees auto-detection even when OS broadcasts fail or when Wi-Fi has no internet
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!_isSimulatedOffline.value) {
        checkRealConnectivity();
      }
    });
  }

  @override
  Future<bool> checkRealConnectivity() async {
    bool hasRealInternet = false;

    // Check actual internet reachability via DNS lookup with quick timeout
    try {
      final lookupResults = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 1500));
      hasRealInternet = lookupResults.isNotEmpty && lookupResults[0].rawAddress.isNotEmpty;
    } catch (_) {
      try {
        final backupResults = await InternetAddress.lookup('cloudflare.com')
            .timeout(const Duration(milliseconds: 1500));
        hasRealInternet = backupResults.isNotEmpty && backupResults[0].rawAddress.isNotEmpty;
      } catch (_) {
        hasRealInternet = false;
      }
    }

    if (_isDeviceOnline.value != hasRealInternet) {
      _isDeviceOnline.value = hasRealInternet;
      _syncStatus();
    }

    return isConnected;
  }

  void _syncStatus() {
    final connected = _isDeviceOnline.value && !_isSimulatedOffline.value;
    if (isConnectedRx.value != connected) {
      isConnectedRx.value = connected;
    }
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
    _pollingTimer?.cancel();
    super.onClose();
  }
}
