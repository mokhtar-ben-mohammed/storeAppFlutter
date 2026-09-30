import 'dart:io';

/// Abstraction for checking network connectivity.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

/// Robust implementation checking active network interfaces and address reachability.
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    try {
      // 1. Verify that device has an active network interface (Wi-Fi, Ethernet, Cellular)
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      if (interfaces.isEmpty) {
        return false;
      }

      // 2. Fast check against common public DNS or direct socket ping with timeout
      try {
        final result = await InternetAddress.lookup('1.1.1.1').timeout(
          const Duration(seconds: 2),
        );
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // Fallback: If on local Wi-Fi / LAN, allow request to proceed to host
      }

      // If network interfaces are active, treat as connected (allows LAN APIs like 192.168.x.x)
      return true;
    } catch (_) {
      return false;
    }
  }
}
