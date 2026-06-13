import 'package:flutter/foundation.dart';

bool isMobileBrowserImpl() {
  return false;
}

Future<void> launchUpiImpl({
  required Function(String) onError,
  required Function() onDesktopWarning,
}) async {
  onError('UPI payment is only supported in web environments.');
}

Future<void> launchAaniPayImpl({
  required Function(String) onAppNotInstalled,
  required Function(String) onError,
}) async {
  onError('Aani Pay is only supported in web environments.');
}
