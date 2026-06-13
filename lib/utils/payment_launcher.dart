import 'payment_launcher_stub.dart'
    if (dart.library.html) 'payment_launcher_web.dart';

class PaymentLauncher {
  static bool isMobileBrowser() => isMobileBrowserImpl();

  static Future<void> launchUpi({
    required Function(String) onError,
    required Function() onDesktopWarning,
  }) =>
      launchUpiImpl(onError: onError, onDesktopWarning: onDesktopWarning);

  static Future<void> launchAaniPay({
    required Function(String) onAppNotInstalled,
    required Function(String) onError,
  }) =>
      launchAaniPayImpl(onAppNotInstalled: onAppNotInstalled, onError: onError);
}
