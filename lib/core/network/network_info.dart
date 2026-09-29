import 'dart:io';

/// Abstraction for checking network connectivity.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

/// Default implementation checking address resolution.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}
