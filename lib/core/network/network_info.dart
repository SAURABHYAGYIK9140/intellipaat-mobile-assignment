import 'package:get/get.dart';

abstract class NetworkInfo {
  bool get isConnected;
  Stream<bool> get onConnectivityChanged;
  void setSimulatedOffline(bool offline);
  bool get isSimulatedOffline;
}

class NetworkInfoImpl extends GetxService implements NetworkInfo {
  final RxBool _isSimulatedOffline = false.obs;

  @override
  bool get isSimulatedOffline => _isSimulatedOffline.value;

  @override
  bool get isConnected => !_isSimulatedOffline.value;

  @override
  Stream<bool> get onConnectivityChanged => _isSimulatedOffline.stream.map((offline) => !offline);

  @override
  void setSimulatedOffline(bool offline) {
    _isSimulatedOffline.value = offline;
  }

  void toggleOffline() {
    _isSimulatedOffline.value = !_isSimulatedOffline.value;
  }
}
